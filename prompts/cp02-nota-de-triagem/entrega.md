# Entrega — Checkpoint 02: Nota de triagem

## Modelo

| Campo            | Valor |
| ---------------- | ----- |
| Provedor         |       |
| Modelo           |       |
| Data da execução |       |

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

_(preencher após execução manual)_

---

### Entrada 2 — Relay taxa de rejeição elevada

**Alerta usado:**

```
2026-05-13 03:11:00 UTC [Relay] ingest reject rate 6% for 8min, tenant wakanda-systems,
buffer saturated after deploy 02:55
```

**Output do modelo:**

_(preencher após execução manual)_

---

### Entrada 3 — Forge consumer lag crescente

**Alerta usado:**

```
2026-05-13 11:40:22 UTC [Forge] consumer lag 9min and climbing, batch forge-batch-ingest
delayed after previous job failure, downstream Sentinel starting to lag
```

**Output do modelo:**

_(preencher após execução manual)_

---

## Curadoria

### Ajustes feitos no prompt (se houver)

_(preencher após execução manual)_

---

## Justificativa do método

_(Documente a escolha de método para ensinar o formato ao modelo — ex.: zero-shot estrutural, few-shot, role + constraints — e compare prós/contras das alternativas consideradas.)_
