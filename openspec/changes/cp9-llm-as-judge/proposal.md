## Why

O CP08 cobre formato e limites operacionais, mas não avalia **qualidade** de saídas abertas. A análise de causa-raiz (CP03) exige julgamento humano — o Checkpoint 09 adiciona **LLM-as-judge** no promptfoo como gate de qualidade para `causa-raiz-cerebro`, com rubrica fixa e calibração documentada.

## What Changes

- Documentar rubrica em `registry/docs/cp09-rubrica-causa-raiz.md` (4 critérios, escala 0–2, corte ≥ 6, nenhum critério zerado).
- Criar `registry/devops/causa-raiz-cerebro/promptfooconfig.yaml` com juiz (`llm-rubric` ou `model-graded-closedqa`) aplicando a rubrica como gate.
- Criar `registry/docs/cp09-calibracao-juiz.md` — **template vazio** para registro da calibração manual (pontuação humana vs juiz, ajustes).
- Atualizar `registry/scripts/run-all-evals.sh` para incluir eval de causa-raiz.
- **Não** executar eval nem calibrar juiz no apply — operador roda manualmente e preenche docs.
- **Não** adicionar CI (CP10).

## Capabilities

### New Capabilities

- `devops/llm-as-judge`: Gate de qualidade promptfoo com rubrica LLM para prompt de causa-raiz Cerebro.

### Modified Capabilities

- `devops/promptfoo-eval`: Suíte estendida com eval de julgamento além dos asserts determinísticos.

## Impact

- **Pré-requisitos:** CP7 (prompt no registry), CP8 (tooling promptfoo)
- **Prompt alvo:** `registry/devops/causa-raiz-cerebro/`
- **Fixture:** artefatos CP03 como vars de teste
- **CP10:** gate reutilizado no pipeline GitHub Actions
