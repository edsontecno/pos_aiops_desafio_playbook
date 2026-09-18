## Why

Com prompts no registry e testes promptfoo (CP08–CP09), falta o fechamento: **CI em GitHub Actions** que rode a suíte a cada PR/push e barre regressões. O Checkpoint 10 transforma o repositório em playbook de produção contínua.

## What Changes

- Criar `.github/workflows/prompt-eval.yml` usando [action oficial promptfoo](https://www.promptfoo.dev/docs/integrations/github-action/).
- Garantir **cobertura promptfoo** para os 9 prompts em `registry/devops/` (4 gates CP08/09 + 5 smoke configs para saídas abertas).
- Criar `registry/docs/estrategia-gate-ci.md` — justificativa estendida com **≥2 alternativas** por decisão de gate (escopo da suíte, o que falha o build, juiz LLM, secrets, custo).
- Criar `registry/docs/cp10-ci-evidencias.md` — **template vazio** para operador registrar execução CI (sucesso + falha provocada).
- Documentar secrets necessários em `registry/.env.example` e README (OPENAI_API_KEY, ANTHROPIC_API_KEY).
- **Não** executar workflow no apply — operador dispara manualmente no GitHub e preenche evidências.

## Capabilities

### New Capabilities

- `devops/ci-pipeline`: Pipeline GitHub Actions para eval promptfoo com gate de regressão documentado.

### Modified Capabilities

- `devops/promptfoo-eval`: Cobertura estendida a todos os prompts; execução automatizada em CI.
- `devops/llm-as-judge`: Juiz causa-raiz integrado ao gate CI (com decisão documentada sobre flakiness).

## Impact

- **Pré-requisitos:** CP7, CP8, CP9 aplicados
- **Secrets:** GitHub repository secrets (não commitados)
- **Custo:** tokens a cada PR — trade-offs documentados em estrategia-gate-ci.md
- **Entrega final:** repositório público GitHub com link documentado
