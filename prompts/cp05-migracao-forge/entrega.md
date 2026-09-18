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

_(preencher manualmente após executar prompt-diagnostico.md)_

---

### Elo 2 — Plano de migração

**Output do modelo:**

_(preencher manualmente após executar prompt-plano.md com output do elo 1)_

---

### Elo 3 — Fase 1 executável

**Output do modelo:**

_(preencher manualmente após executar prompt-fase-1.md com output do elo 2)_

---

## Justificativa do método

**Prompt chaining (3 elos):** migração complexa decomposta em diagnóstico → plano incremental → runbook da Fase 1; cada elo recebe saída do anterior como parâmetro, evitando resposta rasa de prompt monolítico. Restrições anti-big-bang, proteção de dependentes e rollback explícito estão embutidas nos elos 2 e 3.

---

## Curadoria

### Ajustes feitos nos prompts (se houver)

_(preencher manualmente)_
