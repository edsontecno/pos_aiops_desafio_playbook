# Entrega — Checkpoint 05: Migração Forge batch → event-driven

## Modelo

| Campo            | Valor                |
| ---------------- | -------------------- |
| Provedor         | _(preencher manual)_ |
| Modelo           | _(preencher manual)_ |
| Data da execução | _(preencher manual)_ |

---

## Ordem da cadeia

1. **Elo 1** — `prompt-diagnostico.md` → cola `{{estado_forge}}`
2. **Elo 2** — `prompt-plano.md` → cola `{{estado_forge}}` + output do elo 1 em `{{diagnostico_anterior}}`
3. **Elo 3** — `prompt-fase-1.md` → cola output do elo 2 em `{{plano_anterior}}` + `{{estado_forge}}`

---

## Execução

### Estado Forge usado (entrada do elo 1)

```
Forge hoje:
- ingestão: um job em cron acorda a cada 60min (o "forge-batch-ingest")
- transformação: 14 etapas de processamento encadeadas (em Spark), ~40min no total
- destino: grava em tabelas no data warehouse, particionadas por hora
- ponto frágil: se um lote falha, o próximo acumula o dobro de volume
- quem depende do Forge: Sentinel (lê as tabelas agregadas), Cerebro (indexa
  os eventos transformados) e os relatórios de billing da Pepper (rodam de madrugada)
```

### Elo 1 — Diagnóstico

**Output do modelo:**

### Resumo do estado atual

- **Modo de operação:** batch (cron 60min)
- **Gargalo principal:** o encadeamento de 14 etapas de transformação em Spark, consumindo ~40min de uma janela de 60min — margem operacional apertada mesmo em condições normais.
- **Ponto frágil crítico:** ausência de mecanismo de recuperação para falhas de lote, que gera acúmulo (dobro de volume) no ciclo seguinte, criando risco de efeito cascata.

### Componentes e fluxo

- **Ingestão:** job em cron (`forge-batch-ingest`) desperta a cada 60 minutos — não há indicação de ingestão contínua ou baseada em eventos.
- **Transformação:** 14 etapas de processamento encadeadas em Spark, com duração total aproximada de 40 minutos. O encadeamento sugere dependência sequencial entre etapas, mas o texto não detalha se há paralelismo interno.
- **Destino:** gravação em tabelas do data warehouse, particionadas por hora — a granularidade horária das partições está alinhada ao ciclo de ingestão, mas não necessariamente ao tempo real de disponibilização dos dados.

### Dependentes e impacto

| Dependente       | O que consome do Forge          | Sensibilidade a atraso                                                                                                                                         |
| ---------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sentinel         | Lê as tabelas agregadas         | Não especificada no texto; presume-se consumo periódico, mas frequência de leitura do Sentinel não é informada                                                 |
| Cerebro          | Indexa os eventos transformados | Não especificada; depende da cadência de indexação do Cerebro, que não consta no estado descrito                                                               |
| Billing (Pepper) | Roda relatórios de madrugada    | Potencialmente alta — relatórios noturnos sugerem uma janela fixa de execução, tornando esse dependente sensível a atrasos acumulados ao longo do dia anterior |

### Riscos identificados (batch atual)

- **Margem de tempo insuficiente:** 40min de processamento dentro de um ciclo de 60min deixa apenas ~20min de folga; qualquer degradação de performance pode fazer o processamento ultrapassar o próximo disparo do cron.
- **Efeito cascata de falhas:** o ponto frágil descrito (dobro de volume no lote seguinte após falha) é um mecanismo de acúmulo sem limite explícito — se falhas ocorrerem em sequência, o volume pode crescer de forma composta, não apenas linear.
- **Ausência de descrição de idempotência ou reprocessamento:** o texto não menciona como o sistema trata reexecuções, o que é relevante dado o comportamento de acúmulo descrito.
- **Concentração de risco no billing:** por rodar "de madrugada" e depender de tabelas particionadas por hora, um atraso ou falha ao longo do dia anterior pode comprometer a completude dos dados disponíveis no horário do relatório — mas o texto não confirma se há corte de segurança (cutoff) para isso.
- **Falta de visibilidade sobre monitoramento:** não há menção a alertas, retries automáticos ou observabilidade sobre o estado dos lotes.

### Riscos antecipados na migração

- **Mudança de contrato de consumo:** Sentinel, Cerebro e o billing da Pepper foram descritos como consumidores de um artefato batch (tabelas particionadas por hora). Uma migração para event-driven muda a natureza desse contrato (de "tabela pronta" para "fluxo de eventos"), e o texto não indica se esses três consumidores estão preparados para consumir eventos em vez de tabelas.
- **Dependência do billing em janelas fechadas:** relatórios de madrugada sugerem lógica de corte temporal (ex.: "dados até tal hora"). Um modelo event-driven, por natureza, não tem cortes discretos naturais — isso é um ponto de atrito arquitetural relevante para esse dependente específico.
- **As 14 etapas encadeadas como unidade:** o texto descreve as etapas de transformação como uma cadeia única, não como estágios independentes. Não há informação suficiente para saber se cada etapa pode operar sobre eventos individuais ou se depende de agregações que só fazem sentido sobre um lote completo.
- **Comportamento de falha desconhecido em modo evento:** o ponto frágil atual (acúmulo por falha) é uma característica do modelo batch; não é possível inferir do texto como uma falha equivalente se comportaria em um pipeline orientado a eventos, pois isso depende de decisões de design ainda não descritas.

### Premissas e limites

O que **não** pode ser afirmado com os dados disponíveis:

- Frequência ou padrão real de leitura do Sentinel e do Cerebro sobre as tabelas do Forge.
- Se há SLA formal para o Sentinel, o Cerebro ou o billing da Pepper.
- Volume de dados absoluto processado por ciclo (apenas o comportamento relativo de "dobro" em caso de falha é conhecido).
- Se as 14 etapas de transformação são paralelizáveis ou estritamente sequenciais.
- Se existe algum mecanismo de retry, alerta ou monitoramento já em operação.
- Se há um limite superior para o acúmulo de volume em falhas consecutivas, ou se o crescimento é ilimitado.
- Infraestrutura, custo ou tecnologia de mensageria disponível para uma eventual migração — nenhum desses dados foi fornecido no estado atual.

---

### Elo 2 — Plano de migração

**Output do modelo:**

### Objetivo da migração

- **De:** batch (cron 60min, lote de 1h, encadeamento de 14 etapas em Spark, ~40min de processamento)
- **Para:** event-driven (consumo contínuo do Relay, em pequenos blocos)
- **Restrições invioláveis:** sem big-bang; Sentinel, Cerebro e billing (Pepper) permanecem operacionais durante toda a transição; cada fase deve ser reversível

---

### Fases da migração

#### Fase 1 — Instrumentação e paralelismo observacional

- **Objetivo:** Introduzir a captura de eventos do Relay em paralelo ao pipeline batch existente, sem alterar o caminho de produção que alimenta Sentinel, Cerebro e billing.
- **Escopo:** Consumo do Relay em modo "shadow" (somente leitura/gravação em destino paralelo, ex.: tabela ou tópico de staging), sem substituir as tabelas do data warehouse já consumidas pelos dependentes. O pipeline batch cron continua rodando normalmente como fonte oficial.
- **Dependentes afetados:** Nenhum diretamente — Sentinel, Cerebro e billing continuam lendo exclusivamente do fluxo batch atual.
- **Critério de sucesso:** O fluxo shadow consegue ingerir eventos do Relay de forma estável, e uma comparação entre o volume/conteúdo do shadow e o do batch mostra paridade dentro de uma margem aceitável (a definir com dados reais, ainda não disponíveis no estado atual).
- **Rollback:** Desligar o consumo shadow do Relay; nenhum impacto no fluxo de produção, pois este não depende do shadow em nenhum ponto.
- **Duração estimada:** Não pode ser precisada com os dados disponíveis (depende de infraestrutura de mensageria ainda não descrita no estado atual).
- **Riscos:** Divergência entre o modelo de dados do Relay e o formato esperado pelas 14 etapas de transformação, já que não há informação sobre se essas etapas foram desenhadas para operar por evento ou apenas por lote agregado.

#### Fase 2 — Migração incremental das etapas de transformação

- **Objetivo:** Adaptar progressivamente as 14 etapas encadeadas do Spark para operar sobre pequenos blocos de eventos do Relay, em vez de sobre o lote horário completo, começando pelas etapas menos dependentes de agregação (quando identificáveis).
- **Escopo:** Conversão etapa a etapa (ou em pequenos grupos de etapas) do processamento batch para processamento incremental/streaming, mantendo a saída ainda direcionada às mesmas tabelas particionadas por hora que os dependentes já consomem.
- **Dependentes afetados:** Sentinel, Cerebro e billing continuam lendo as tabelas por hora normalmente; a mudança é interna ao pipeline, não ao contrato de consumo.
- **Critério de sucesso:** As etapas migradas produzem resultados equivalentes aos da via batch (validação por comparação), com processamento em blocos pequenos e cadência mais frequente que 60min, sem quebrar a granularidade horária esperada pelos dependentes.
- **Rollback:** Reverter etapa(s) específica(s) para o modo batch original, mantendo o restante da cadeia como estava; como a migração é etapa a etapa, o rollback é localizado e não afeta o pipeline inteiro.
- **Duração estimada:** Não pode ser precisada — depende de quantas das 14 etapas são paralelizáveis ou possuem dependência estrita de agregação em lote, o que o estado atual não esclarece.
- **Riscos:** Etapas que dependem de agregações que só fazem sentido sobre um lote completo podem não ser convertíveis diretamente para modo evento sem redesenho; risco de comportamento de falha ainda não mapeado em modo streaming (o mecanismo de acúmulo por falha do batch pode não ter equivalente definido).

#### Fase 3 — Corte gradual do contrato de consumo pelos dependentes

- **Objetivo:** Migrar Sentinel, Cerebro e billing, um de cada vez, do modelo de leitura de "tabela pronta por hora" para consumo de fluxo contínuo (ou uma abstração que preserve a semântica de corte temporal onde necessário).
- **Escopo:** Início pelo dependente de menor sensibilidade a atraso identificada no diagnóstico anterior (Sentinel ou Cerebro, cuja frequência de leitura não está definida), deixando o billing por último dado que ele foi identificado como o de maior sensibilidade potencial (relatórios de madrugada, possível dependência de corte temporal fechado).
- **Dependentes afetados:** Um dependente por vez; os demais continuam no contrato batch (tabela por hora) até sua respectiva migração.
- **Critério de sucesso:** O dependente migrado opera corretamente sobre o novo contrato de consumo, sem lacunas de dados nem duplicidade, e sem quebrar sua cadência original (mesmo que essa cadência não esteja formalmente descrita).
- **Rollback:** Reverter o dependente migrado para leitura das tabelas particionadas por hora, que continuam sendo geradas até que todos os dependentes tenham migrado.
- **Duração estimada:** Não pode ser precisada — depende de decisões de design ainda não tomadas para lidar com a lógica de corte temporal do billing em modelo event-driven.
- **Riscos:** O billing, por depender de uma janela fechada ("dados até tal hora"), é o ponto de maior atrito arquitetural: um modelo event-driven não tem cortes discretos naturais, e não há no estado atual confirmação de que existe (ou não) um cutoff de segurança a preservar.

#### Fase 4 — Descontinuação do batch e consolidação do modelo event-driven

- **Objetivo:** Desativar o cron `forge-batch-ingest` e o caminho de escrita batch nas tabelas particionadas por hora, uma vez que todos os dependentes protegidos estejam operando de forma estável sobre o consumo contínuo do Relay.
- **Escopo:** Remoção do agendamento cron e do código de ingestão batch; manutenção do pipeline event-driven como única fonte de verdade.
- **Dependentes afetados:** Sentinel, Cerebro e billing — mas apenas depois que a Fase 3 já os tiver migrado individualmente e validado; nesta fase eles já não dependem mais do caminho batch.
- **Critério de sucesso:** Nenhum dos três dependentes lê mais das tabelas geradas pelo batch; o pipeline event-driven sustenta a operação sem regressões observadas nas fases anteriores.
- **Rollback:** Reativar o cron `forge-batch-ingest` e o caminho de escrita batch; como as tabelas por hora só devem ser desativadas ao final desta fase, a reativação é tecnicamente possível enquanto o código batch não for removido definitivamente (apenas desligado).
- **Duração estimada:** Não pode ser precisada com os dados disponíveis.
- **Riscos:** Perda do mecanismo de rollback caso o código/infraestrutura batch seja removido prematuramente antes da estabilização completa do modelo novo; ausência de dados sobre monitoramento/alertas (apontada no diagnóstico anterior) aumenta o risco de uma falha silenciosa nesta fase final.

---

### Ordem de execução e dependências entre fases

```
Fase 1 → Fase 2 → Fase 3 → Fase 4
```

- **Fase 1 antes de Fase 2:** não é seguro alterar as etapas de transformação para operar sobre eventos sem antes validar, em modo shadow, que o Relay entrega dados equivalentes ao batch atual.
- **Fase 2 antes de Fase 3:** os dependentes só podem ser migrados para consumo contínuo depois que o pipeline de transformação já produz saídas corretas a partir de blocos pequenos — caso contrário, estariam consumindo um contrato inconsistente.
- **Fase 3 antes de Fase 4:** o batch só pode ser desligado depois que todos os três dependentes protegidos já não dependem mais dele, respeitando a regra de que eles devem continuar funcionando durante toda a transição.
- Essa ordem é a única que preserva, em cada etapa, um caminho de rollback ativo e evita qualquer corte único ("big-bang").

---

### Fase 1 (destaque para o elo 3)

O elo 3 deve detalhar, para a Fase 1 (Instrumentação e paralelismo observacional):

- Como configurar tecnicamente o consumo "shadow" do Relay sem impacto no pipeline batch em produção.
- Quais métricas ou critérios concretos de comparação (volume, latência, integridade) serão usados para validar paridade entre shadow e batch, já que o estado atual não define esses números.
- Como estruturar o destino de staging do shadow (tabela paralela, tópico, etc.) de forma que não interfira nas tabelas particionadas por hora já usadas por Sentinel, Cerebro e billing.
- Um plano de verificação para identificar, já nesta fase, quais das 14 etapas de transformação parecem compatíveis com processamento por evento — informação necessária antes de iniciar a Fase 2.
- O sinal de abort explícito da Fase 1 (ex.: divergência persistente entre shadow e batch acima de um limiar) e o procedimento imediato de desligamento do consumo shadow.

---

### Riscos residuais do plano

- O maior ponto de atrito arquitetural permanece sem solução definida neste plano: a lógica de corte temporal do billing (relatórios de madrugada) em um modelo sem cortes discretos naturais — isso precisará de decisão de design específica antes ou durante a Fase 3.
- O comportamento de falha em modo evento é desconhecido; o mecanismo atual de acúmulo (dobro de volume por falha) é uma característica do modelo batch e não há garantia de que um equivalente seguro exista no modelo novo até que seja desenhado.
- A ausência de monitoramento, alertas e retries automáticos, já identificada no estado atual, é um risco transversal a todas as fases — sem isso, falhas podem passar despercebidas durante a transição.
- Não há informação sobre se as 14 etapas são paralelizáveis, o que pode limitar a granularidade real de migração incremental na Fase 2.

---

### Premissas e limites

- Este plano assume que existe (ou existirá) infraestrutura de mensageria/streaming compatível com o Relay para sustentar consumo contínuo — o estado atual não fornece esse dado.
- Não é possível afirmar a frequência real de leitura do Sentinel e do Cerebro; a ordem sugerida na Fase 3 (migrá-los antes do billing) é uma inferência baseada na ausência de sensibilidade documentada, não em SLA confirmado.
- Não há confirmação de SLA formal para nenhum dos três dependentes.
- Não é possível estimar durações de fase com precisão, pois o estado atual não fornece volume absoluto de dados, custo de infraestrutura, nem tecnologia de mensageria disponível.
- Não se sabe se existe um limite superior para o acúmulo de volume em falhas consecutivas no modelo batch atual, o que impede avaliar com precisão o risco de se manter o batch ativo em paralelo durante as Fases 1 a 3.
- O diagnóstico anterior (elo 1) não foi fornecido com conteúdo neste turno; a análise acima baseia-se integralmente no documento de estado do Forge disponibilizado.

---

### Elo 3 — Fase 1 executável

**Output do modelo:**

### Fase 1 — Resumo executivo

- **Nome da fase:** Instrumentação e paralelismo observacional (shadow ingestion do Relay)
- **Objetivo em 1 frase:** Validar, em modo shadow e sem tocar no caminho de produção, que o consumo do Relay em pequenos blocos reproduz com paridade aceitável o que o batch horário hoje entrega a Sentinel, Cerebro e billing.
- **Duração estimada:** Não determinável com os dados disponíveis — depende de infraestrutura de mensageria ainda não descrita no estado atual do Forge.
- **Rollback em 1 frase:** Desligar o consumidor shadow do Relay; zero impacto em produção, pois nenhum dependente lê do destino shadow.

---

### Pré-requisitos

- [ ] Confirmar que o cron `forge-batch-ingest` e as 14 etapas Spark continuam rodando sem nenhuma alteração de código ou de agendamento.
- [ ] Definir e provisionar o destino de staging do shadow (tabela ou tópico paralelo), fisicamente separado das tabelas particionadas por hora consumidas por Sentinel, Cerebro e billing.
- [ ] Garantir acesso de leitura ao Relay em modo somente-consumo, sem permissão de escrita em qualquer tabela/tópico de produção.
- [ ] Levantar, junto aos owners de Sentinel, Cerebro e billing, confirmação de que nenhum deles aponta (mesmo acidentalmente) para o destino shadow.
- [ ] Definir previamente o limiar de divergência shadow-vs-batch que caracteriza abort (o plano indica que este número ainda não existe e precisa ser fixado antes do início da coleta).

---

### Passos executáveis

```
1. [Eng. de Dados] — Provisionar destino de staging (tabela/tópico paralelo dedicado ao shadow) — verificar: destino criado, isolado, sem nenhum dependente (Sentinel/Cerebro/billing) apontando para ele.
2. [Eng. de Dados] — Implementar consumidor "shadow" do Relay, somente leitura do Relay e somente escrita no destino de staging — verificar: consumidor sobe sem erros e não realiza nenhuma escrita fora do staging.
3. [Eng. de Dados] — Confirmar que o pipeline batch (cron + 14 etapas Spark) permanece intocado e seguindo seu ciclo normal de 60min — verificar: execuções do cron seguem no horário e SLA histórico, sem alteração de código.
4. [Eng. de Dados] — Iniciar ingestão contínua do Relay em pequenos blocos para o destino shadow — verificar: fluxo de eventos chegando de forma estável, sem gaps perceptíveis.
5. [Eng. de Dados / Analista de Dados] — Rodar comparação periódica entre volume/conteúdo do shadow e do batch (mesma janela horária) — verificar: divergência dentro do limiar definido no pré-requisito.
6. [Eng. de Dados] — Mapear, uma a uma, as 14 etapas do Spark quanto à sua compatibilidade aparente com processamento por evento (agregação estrita em lote vs. operação por registro) — verificar: checklist das 14 etapas preenchido com classificação (compatível / incompatível / indefinido).
7. [Eng. de Dados] — Registrar formalmente o critério de abort e testar o procedimento de desligamento do shadow em ambiente controlado — verificar: desligamento do consumidor shadow executa sem tocar em nenhum recurso de produção.
8. [Eng. de Dados + stakeholders de Sentinel/Cerebro/billing] — Consolidar relatório de paridade shadow-vs-batch e checklist de compatibilidade das 14 etapas — verificar: documento pronto para handoff da Fase 2.
```

---

### Dual-run / transição gradual

- O batch (cron `forge-batch-ingest` + 14 etapas Spark) continua sendo a **única fonte oficial** para Sentinel, Cerebro e billing durante toda a Fase 1 — nenhuma leitura de produção é redirecionada.
- O shadow roda em paralelo, consumindo o Relay em pequenos blocos, mas grava exclusivamente em destino de staging isolado.
- Não há corte, chaveamento ou fallback automático nesta fase: os dois fluxos coexistem de forma totalmente desacoplada, o que torna o rollback trivial (basta desligar o shadow).
- A cadência de comparação (shadow vs. batch) deve ser feita por janela horária, espelhando a granularidade que o batch já entrega, para manter a comparação equivalente.

---

### Métricas de sucesso

| Métrica                                                | Baseline (batch)                            | Target Fase 1                                                                                                                         | Janela de medição        |
| ------------------------------------------------------ | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| Volume de eventos/registros por janela horária         | Volume produzido pelo batch na mesma janela | Divergência dentro do limiar definido previamente (valor exato não especificado no estado atual — deve ser fixado como pré-requisito) | Por hora                 |
| Integridade de conteúdo (paridade de campos/registros) | Saída das 14 etapas via batch               | Paridade "aceitável" com o shadow, conforme limiar a definir                                                                          | Por hora                 |
| Estabilidade do consumidor shadow                      | N/A (não existe hoje)                       | Ingestão contínua sem interrupções não planejadas                                                                                     | Contínua, revisão diária |
| Isolamento de produção                                 | N/A                                         | Zero leituras de Sentinel/Cerebro/billing apontando para o destino shadow                                                             | Contínua                 |

_Observação: o estado atual do Forge não fornece números absolutos de volume, latência ou SLA, portanto os targets numéricos exatos ficam como lacuna a ser preenchida com dados reais coletados durante a própria Fase 1._

---

### Gatilho de rollback

- Divergência persistente (acima do limiar definido) entre volume/conteúdo do shadow e do batch, mantida por mais de uma janela de medição consecutiva.
- Qualquer indício de que o consumidor shadow está impactando o Relay, o batch ou a infraestrutura compartilhada (ex.: contenção de recursos).
- Detecção de qualquer dependente (Sentinel, Cerebro, billing) lendo, mesmo que parcialmente, do destino de staging shadow.
- Instabilidade do próprio consumidor shadow que impeça coleta de dados confiável para a comparação.

---

### Procedimento de rollback

```
1. [Eng. de Dados] — Desligar imediatamente o consumidor shadow do Relay.
2. [Eng. de Dados] — Confirmar que o cron `forge-batch-ingest` e as 14 etapas Spark seguem operando normalmente (nenhuma ação necessária, pois nunca foram alterados).
3. [Eng. de Dados] — Isolar/arquivar os dados já gravados no destino de staging para análise posterior da causa da divergência.
4. [Eng. de Dados] — Registrar o incidente (motivo do abort, métricas no momento do gatilho) para reavaliação antes de nova tentativa de Fase 1.
```

---

### Handoff para Fase 2

- Relatório de paridade shadow-vs-batch, com evidência de estabilidade dentro do limiar definido.
- Checklist das 14 etapas Spark classificadas quanto à compatibilidade com processamento por evento (base para escolher por onde começar a migração incremental).
- Limiar de divergência e procedimento de abort documentados e testados.
- Confirmação de que, durante toda a Fase 1, Sentinel, Cerebro e billing permaneceram lendo exclusivamente do fluxo batch, sem qualquer regressão.

---

### Riscos específicos da Fase 1

- Divergência entre o modelo de dados do Relay e o formato esperado pelas 14 etapas, já que não há confirmação se elas foram desenhadas para operar por evento ou apenas por lote agregado.
- Ausência de um limiar de paridade pré-definido no estado atual, o que exige defini-lo "às cegas" antes de ter dados reais — esse limiar deve ser tratado como provisório e revisado assim que houver dados suficientes.
- Falta de infraestrutura de mensageria/streaming confirmada para sustentar o consumo contínuo do Relay (premissa do plano, não um fato validado).
- Ausência de monitoramento, alertas e retries automáticos (já apontada no diagnóstico anterior) é um risco transversal: sem isso, uma falha silenciosa no shadow pode passar despercebida, comprometendo a qualidade da comparação com o batch.

---

## Justificativa do método

**Prompt chaining (3 elos):** migração complexa decomposta em diagnóstico → plano incremental → runbook da Fase 1; cada elo recebe saída do anterior como parâmetro, evitando resposta rasa de prompt monolítico. Restrições anti-big-bang, proteção de dependentes e rollback explícito estão embutidas nos elos 2 e 3.

---
