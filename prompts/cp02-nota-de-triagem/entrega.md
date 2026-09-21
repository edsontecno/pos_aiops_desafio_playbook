# Entrega — Checkpoint 02: Nota de triagem

## Modelo

| Campo            | Valor      |
| ---------------- | ---------- |
| Provedor         | Claude     |
| Modelo           | Sonnet 5   |
| Data da execução | 18/09/2026 |

---

## Execução

### Entrada 1 — Sentinel autoscaler no limite

**Alerta usado:**

```
2026-05-12 14:02:09 UTC [Sentinel] autoscaler hit max replicas (60/60) on sentinel-api,
queue depth on Relay growing 2k/min, CPU avg 88%, tenant stark-industries
sending 4x baseline volume after onboarding new region
```

**Output do modelo:**

ALERTA: Sentinel-api atinge limite máximo de réplicas (60/60) no autoscaler
IMPACTO: fila do Relay crescendo 2k/min, CPU média 88%, risco de degradação para tenant stark-industries
HIPÓTESE INICIAL: nova região onboarded gera 4x volume baseline do tenant stark-industries, saturando capacidade
AÇÃO IMEDIATA: avaliar aumento do limite máximo de réplicas do sentinel-api e monitorar profundidade da fila do Relay
ESCALAR PARA: @sentinel-core se fila do Relay continuar crescendo por mais de 15min

---

### Entrada 2 — Relay taxa de rejeição elevada

**Alerta usado:**

```
2026-05-13 03:11:00 UTC [Relay] ingest reject rate 6% for 8min, tenant wakanda-systems,
buffer saturated after deploy 02:55
```

**Output do modelo:**

ALERTA: Relay - taxa de rejeição de ingestão em 6% por 8min
IMPACTO: ingestão do tenant wakanda-systems degradada
HIPÓTESE INICIAL: deploy às 02:55 saturou o buffer de ingestão
AÇÃO IMEDIATA: avaliar rollback do deploy das 02:55
ESCALAR PARA: @relay-core se a rejeição não cair em 10min

---

### Entrada 3 — Forge consumer lag crescente

**Alerta usado:**

```
2026-05-13 11:40:22 UTC [Forge] consumer lag 9min and climbing, batch forge-batch-ingest
delayed after previous job failure, downstream Sentinel starting to lag
```

**Output do modelo:**

ALERTA: Forge - lag do consumer em 9min e subindo, batch forge-batch-ingest atrasado
IMPACTO: downstream Sentinel começando a apresentar lag
HIPÓTESE INICIAL: falha do job anterior atrasou o batch forge-batch-ingest
AÇÃO IMEDIATA: verificar status do job anterior e reprocessar/reiniciar o batch forge-batch-ingest
ESCALAR PARA: @data-platform se o lag ultrapassar 15min ou continuar subindo

---

---

## Justificativa do método

**Role + zero-shot estrutural + referência de formato estática:** os cinco rótulos e constraints ensinam o esquema e os limites (≤8 linhas, `@`), e as notas Relay/Forge/Cerebro no prompt fixam o padrão visual sem confundir com `{{alerta_cru}}`.
Few-shot com alerta pareado foi descartado — mistura formato e entrada, o que o enunciado proíbe.
