## Context

CP09 — camada de julgamento sobre CP08. Alvo: `causa-raiz-cerebro` (slug CP7; enunciado menciona `causa-raiz` — usamos slug do registry). Execução e calibração manuais, alinhado ao fluxo CP01–CP08.

## Goals / Non-Goals

**Goals:**

- Rubrica em markdown (fonte de verdade)
- promptfooconfig com llm-rubric
- Template calibração
- run-all-evals.sh estendido

**Non-Goals:**

- Juiz para backpressure/migracao-forge (sem rubrica no enunciado CP09)
- CI GitHub Actions (CP10)
- Executar eval no apply

## Decisions

### 1. Grader: `llm-rubric`

**Escolha:** `llm-rubric` com rubrica copiada de `cp09-rubrica-causa-raiz.md` no campo `value`/`rubric`.

**Alternativa:** `model-graded-closedqa` — válido se rubrica couber; documentar escolha na calibração.

**Rationale:** Enunciado cita ambos; llm-rubric mapeia naturalmente escala 0–2 × 4 critérios.

### 2. Modelo do juiz

Juiz separado do modelo under test — ex.: provider under test `gpt-4o-mini`, juiz `openai:gpt-4o` ou `anthropic:claude-sonnet-4` para estabilidade.

Documentar em calibração; não hardcodear secret.

### 3. Estrutura promptfooconfig

```yaml
prompts:
  - file://devops/causa-raiz-cerebro/prompt.md
providers:
  - openai:gpt-4o-mini
tests:
  - vars:
      artefatos: |
        [config + métricas + logs CP03]
    assert:
      - type: llm-rubric
        value: |
          [rubrica 4 critérios, aprovação ≥6, nenhum 0]
        threshold: 0.75  # calibrar manualmente — documentar
```

Threshold numérico do llm-rubric mapeia aprovação — operador ajusta na calibração.

### 4. Calibração — processo manual

1. Gerar 2–3 saídas manualmente (prompt CP03 + artefatos)
2. Pontuar humano 0–2 por critério
3. Rodar juiz, comparar, ajustar texto da rubrica no config
4. Registrar em `cp09-calibracao-juiz.md`

Meta: delta ≤ 1 ponto por critério.

### 5. Latency/cost no CP9

Enunciado CP9 não repete latency/cost — **opcional** incluir asserts CP08 no mesmo test para consistência operacional. **Escolha:** incluir latency ≤5s e cost ≤0.01 no test de causa-raiz também.

## Risks / Trade-offs

| Risco | Mitigação |
|-------|-----------|
| Juiz não-determinístico flutua | Calibração; CP10 discute threshold vs flaky builds |
| Rubrica longa aumenta tokens | Referenciar doc + versão enxuta no config |
| Threshold llm-rubric opaco | Documentar mapeamento score→aprovado na calibração |

## Migration Plan

1. Criar cp09-rubrica-causa-raiz.md
2. Criar promptfooconfig.yaml
3. Criar cp09-calibracao-juiz.md (template)
4. Atualizar run-all-evals.sh + package.json script eval:rca
5. Commit: `feat(devops): adiciona LLM-as-judge CP09 causa-raiz`

## Open Questions

- Threshold exato do llm-rubric após calibração — operador define na execução manual.
