# Entrega — Checkpoint 04: Backpressure do Relay

## Modelo

| Campo            | Valor                |
| ---------------- | -------------------- |
| Provedor         | _(preencher manual)_ |
| Modelo           | _(preencher manual)_ |
| Data da execução | _(preencher manual)_ |

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

_(preencher manualmente após executar o prompt com o cenário acima)_

---

## Justificativa do método

**Role + zero-shot estrutural + comparação forçada:** a persona de engenheiro de plataforma e as seis regras (fonte única, ≥2 estratégias, restrições invioláveis, caminhos como guia, honestidade epistêmica, raciocínio explícito) impedem recomendação única sem trade-offs; o template (Restrições → Opções → Recomendação → Riscos → Limites) exige análise comparativa antes da decisão.

---

## Curadoria

### Ajustes feitos no prompt (se houver)

_(preencher manualmente)_
