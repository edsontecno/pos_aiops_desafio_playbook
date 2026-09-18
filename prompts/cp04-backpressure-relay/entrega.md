# Entrega — Checkpoint 04: Backpressure do Relay

## Modelo

| Campo            | Valor      |
| ---------------- | ---------- |
| Provedor         | Claude     |
| Modelo           | Sonnet 5   |
| Data da execução | 18/09/2026 |

---

## Execução

### Cenário usado

```
Relay (barramento de eventos):
- throughput sustentado: 180k msgs/s
- pico observado no incidente da semana passada: 320k msgs/s por 25min
- retenção atual: 4h
- consumidores: Forge (ingestão), Sentinel (alerting em tempo real)

Restrições do time:
- alerting do Sentinel não pode atrasar mais que 60s (SLA com cliente)
- ingestão do Forge pode atrasar até 15min sem violar SLA
- orçamento de infra do trimestre já está 8% acima do previsto
- Steve Rogers lembra que o barramento antigo perdia mensagens sob pico,
  e perda de telemetry é inaceitável para um produto de observabilidade
```

**Output do modelo:**

### Restrições resumidas

- **SLA Sentinel (alerting):** atraso máximo tolerável de **60s** — não pode ser violado.
- **SLA Forge (ingestão):** atraso tolerável até **15min** — folga significativamente maior que Sentinel.
- **Zero perda de telemetry:** requisito inviolável, mesmo sob pico (histórico do barramento antigo perdendo mensagens sob pico é citado como precedente inaceitável).
- **Orçamento:** já 8% acima do previsto no trimestre — qualquer solução que exija infra adicional relevante deve ser justificada com parcimônia.
- **Capacidade vs pico:** throughput sustentado (180k msgs/s) é bem inferior ao pico observado (320k msgs/s por 25min) — gap de ~78% que o sistema precisa absorver sem descartar mensagens.
- **Retenção atual:** 4h — dado relevante para replay/reprocessamento, mas o cenário não informa se essa retenção é suficiente para cobrir cenários de backlog prolongado combinados com falhas de consumidor.

---

### Opções consideradas

#### Priorização Sentinel vs Forge (particionamento por prioridade/multi-fila)

- **Descrição:** Separar o fluxo de eventos em filas/tópicos distintos (ou lanes) por consumidor, garantindo que Sentinel tenha um caminho dedicado com prioridade de consumo sobre Forge durante picos.
- **Prós:** Não exige capacidade adicional de throughput bruto — apenas reordena a fila de atendimento. Protege diretamente o SLA mais apertado (Sentinel) sem tocar em infraestrutura.
- **Contras:** Sozinha, não resolve o problema de origem (o Relay precisa absorver 320k msgs/s sem perder nada); apenas define quem sofre o atraso primeiro. Se o pico persistir além da capacidade de buffer do Forge, o SLA de 15min do Forge pode ser violado.
- **Impacto no SLA Sentinel (≤60s):** Positivo — ao isolar o lane de Sentinel, o atraso dele fica dissociado do volume de Forge, favorecendo o cumprimento do SLA mesmo sob pico.
- **Impacto no SLA Forge (≤15min):** Neutro a levemente negativo — Forge absorve o atraso residual; dentro da janela de 25min observada no incidente, ainda cabe dentro dos 15min _se_ o backlog for processado logo após o pico, mas não há garantia disso sem capacidade extra.
- **Custo/risco infra:** Baixo — mudança arquitetural/lógica (particionamento), não necessariamente requer mais hardware.
- **Risco de perda de telemetry:** **NENHUM**, desde que nenhuma mensagem seja descartada nas filas — apenas reordenadas.
- **Veredito preliminar:** VIÁVEL COM RESSALVAS (resolve prioridade, não resolve capacidade agregada sob pico sustentado).

```
#### Auto-scaling de consumidores

- **Descrição:** Escalar horizontalmente as instâncias de consumo (Forge e/ou Sentinel) dinamicamente com base em métricas de lag/throughput, absorvendo o pico de 320k msgs/s ao aumentar paralelismo de processamento.
- **Prós:** Ataca a causa raiz — capacidade insuficiente para o pico — reduzindo lag para ambos consumidores simultaneamente. Reduz risco de violação de qualquer SLA, incluindo o de Sentinel.
- **Contras:** Custo de infra adicional, mesmo que temporário/elástico, em um trimestre já 8% acima do orçamento previsto. Auto-scaling tem latência de scale-out (cold start, rebalanceamento de partições/consumer groups) que pode não ser instantânea o suficiente para picos curtos e abruptos (o incidente durou 25min — uma janela apertada para scale-out reagir a tempo de proteger o SLA de 60s do Sentinel).
- **Impacto no SLA Sentinel (≤60s):** Risco médio — se o scale-out não for rápido o suficiente (segundos, não minutos), o SLA de 60s pode ser violado durante a rampa de escala.
- **Impacto no SLA Forge (≤15min):** Positivo — a folga de 15min dá tempo suficiente para o auto-scaling reagir e normalizar o backlog.
- **Custo/risco infra:** Alto relativo ao contexto orçamentário — cenário explicita que o orçamento já está estourado; adicionar capacidade elástica (mesmo que sob demanda) pressiona ainda mais esse número, e não há dado sobre quanto custaria escalar de 180k para 320k msgs/s de capacidade.
- **Risco de perda de telemetry:** **NENHUM** diretamente, mas indiretamente **BAIXO** — se o auto-scaling não escalar a tempo e o buffer/fila upstream não tiver capacidade de absorver (não sabemos o tamanho do buffer), há risco de overflow.
- **Veredito preliminar:** VIÁVEL COM RESSALVAS (eficaz para Forge, incerto para proteger Sentinel dentro da janela de 60s, e pressiona orçamento já estourado).
```

#### Dead-letter queue (DLQ) + buffer de absorção de pico

- **Descrição:** Introduzir uma fila de buffer/DLQ que absorve o excedente acima da capacidade sustentada (180k msgs/s) durante picos, retendo mensagens para reprocessamento posterior por Forge, sem tentar processá-las em tempo real.
- **Prós:** Garante zero perda — nada é descartado, apenas desviado para reprocessamento assíncrono. Não exige aumento de capacidade de processamento em tempo real, apenas capacidade de armazenamento temporário (potencialmente mais barato que scale-out de consumidores).
- **Contras:** Só é seguro para Forge (que tolera até 15min de atraso) — inadequado como estratégia isolada para Sentinel, cujo SLA de 60s não permite esse tipo de reprocessamento posterior. DLQ não resolve alerting em tempo real.
- **Impacto no SLA Sentinel (≤60s):** Negativo se aplicada a Sentinel — reprocessamento assíncrono via DLQ inerentemente introduz atraso maior que 60s. Não deve ser usada para o fluxo de Sentinel.
- **Impacto no SLA Forge (≤15min):** Positivo — desde que o tempo entre desvio para DLQ e reprocessamento fique dentro dos 15min, ou que o SLA de Forge seja entendido como "tempo até ingestão completa" (o cenário não detalha exatamente como o SLA de 15min é medido em caso de reprocessamento).
- **Custo/risco infra:** Baixo a moderado — armazenamento de buffer é geralmente mais barato que capacidade de compute adicional, mas ainda é custo incremental num orçamento já estourado.
- **Risco de perda de telemetry:** **NENHUM**, por design (é justamente a estratégia anti-perda).
- **Veredito preliminar:** VIÁVEL COM RESSALVAS — aplicável somente ao fluxo de Forge, não substitui uma solução para Sentinel.

---

### Recomendação

- **Estratégia recomendada:** **Combinação de priorização Sentinel vs Forge + DLQ/buffer para o excedente de Forge**, com auto-scaling tratado como complemento opcional e limitado (não como pilar central), dado o orçamento já estourado.
- **Justificativa:** A priorização isola o lane de Sentinel do volume total, protegendo diretamente o SLA mais rígido (60s) sem custo de infra adicional. O excedente de mensagens acima da capacidade sustentada (180k msgs/s) — que é o que gera risco de perda sob os 320k msgs/s de pico — é absorvido pela DLQ/buffer, dentro da folga de 15min que Forge já tolera, sem descartar nenhuma mensagem. Essa combinação ataca tanto o requisito de zero perda quanto os dois SLAs, com custo incremental menor (armazenamento de buffer) do que escalar compute em tempo real.
- **Por que não as alternativas:**
  - **Priorização isolada:** não garante retenção total do excedente se o pico ultrapassar a capacidade de buffer de Forge — precisa da DLQ como complemento.
  - **Auto-scaling isolado:** o tempo de rampa de escala é incerto frente à janela de 60s do Sentinel (o cenário não fornece dado sobre velocidade de scale-out), e o custo adicional é o mais sensível ao orçamento já 8% acima do previsto — deveria ser usado de forma seletiva (ex.: apenas para Forge, que tem folga de tempo), não como solução primária para o problema de pico agudo.
  - **DLQ isolada (sem priorização):** não protege Sentinel, que precisa de processamento em tempo real, não de reprocessamento assíncrono.

---

### Riscos residuais e próximos passos

- **Riscos que permanecem após a recomendação:**
  - Não há dado no cenário sobre o tamanho de buffer necessário para absorver 25min de excedente (320k - 180k = 140k msgs/s extras por até 25min ≈ ~210M mensagens excedentes) — se a capacidade de armazenamento da DLQ for insuficiente, ainda há risco de perda.
  - Não se sabe se picos podem durar mais que 25min ou ocorrer com frequência maior — isso afeta diretamente o dimensionamento do buffer e a viabilidade de reprocessamento dentro do SLA de Forge.
  - A retenção de 4h do Relay pode ou não ser suficiente para sustentar o backlog gerado durante o reprocessamento, dependendo da velocidade de drenagem da DLQ.
- **Próximos passos operacionais:**
  - Medir o throughput real de reprocessamento do Forge para validar se o backlog gerado em um pico de 25min é drenado dentro de 15min após o fim do pico.
  - Dimensionar a capacidade de buffer/DLQ com base no volume excedente real observado no incidente (140k msgs/s de excedente).
  - Definir e testar SLOs internos de lag por lane (Sentinel vs Forge) com alarmes antes de estourar os respectivos SLAs.
- **Métricas para validar a estratégia:**
  - Lag (delay) do lane de Sentinel em tempo real, com alarme em limiar bem abaixo de 60s (ex.: 30-40s) para dar margem de reação.
  - Profundidade e idade das mensagens na DLQ/buffer, com alarme se a idade projetada de drenagem ultrapassar 15min.
  - Taxa de crescimento de custo de infra mês a mês, para monitorar impacto no orçamento já estourado.

---

### Limites dos dados

- O cenário **não** informa a capacidade máxima de throughput do Relay em si — apenas o throughput sustentado (180k) e o pico observado (320k) — logo não é possível afirmar com certeza se o sistema tem headroom estrutural para picos ainda maiores que 320k.
- **Não** há dados sobre o tempo de scale-out dos consumidores, o que impede avaliar com confiança se auto-scaling seria rápido o suficiente para proteger o SLA de 60s do Sentinel sozinho.
- **Não** há informação sobre o custo específico de cada estratégia (ex.: custo de armazenamento de buffer vs custo de compute adicional) — a afirmação de que DLQ é "mais barata" é uma inferência qualitativa, não um dado do cenário.
- **Não** é possível determinar se a retenção de 4h é suficiente em todos os cenários de combinação de pico + falha de consumidor, pois o cenário não descreve o comportamento do sistema sob múltiplas falhas simultâneas.
- **Não** há detalhe sobre como o SLA de Forge (15min) é formalmente medido em caso de reprocessamento via DLQ — se é "tempo até ingestão bem-sucedida" ou "tempo até primeira tentativa", isso afeta a viabilidade real da estratégia proposta.

---

## Justificativa do método

**Role + zero-shot estrutural + comparação forçada:** a persona de engenheiro de plataforma e as seis regras (fonte única, ≥2 estratégias, restrições invioláveis, caminhos como guia, honestidade epistêmica, raciocínio explícito) impedem recomendação única sem trade-offs; o template (Restrições → Opções → Recomendação → Riscos → Limites) exige análise comparativa antes da decisão.

---
