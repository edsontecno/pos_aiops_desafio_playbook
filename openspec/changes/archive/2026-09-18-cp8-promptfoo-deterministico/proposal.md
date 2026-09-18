## Why

Prompts no registry sem teste não são confiáveis. O Checkpoint 08 adiciona **testes determinísticos com promptfoo** aos três prompts de saída estruturada (CP01, CP02, CP06), com asserts de formato, latência e custo — base para o gate de CI no CP10.

## What Changes

- Adicionar `promptfooconfig.yaml` em:
  - `registry/devops/nota-de-triagem/`
  - `registry/devops/triagem-de-pods/`
  - `registry/devops/networkpolicy-sentinel/`
- Configurar tooling: `registry/package.json` (promptfoo), `registry/scripts/run-all-evals.sh`
- Documentar variáveis de ambiente em `registry/.env.example` (sem secrets commitados)
- Criar `registry/docs/cp08-eval-resultados.md` — **template vazio** para o operador registrar saída de `promptfoo eval` (pass/fail) e curadoria
- **Não** executar `promptfoo eval` no apply — execução manual pelo operador (consistente com CP01–CP07)
- **Não** cobrir CP03/CP04/CP05 (saída aberta → CP09 LLM-as-judge)
- **Não** adicionar GitHub Actions (CP10)

## Capabilities

### New Capabilities

- `devops/promptfoo-eval`: Suíte determinística promptfoo para prompts estruturados do playbook, com limites operacionais de latência e custo.

### Modified Capabilities

- `devops/prompt-registry`: Prompts testáveis passam a incluir `promptfooconfig.yaml` colocalizado.

## Impact

- **Pré-requisito:** CP7 aplicado (prompts em `registry/devops/`)
- **API keys:** `.env.example` documenta chaves; operador configura localmente para eval manual
- **Dois provedores** por config (ex.: OpenAI + Anthropic)
- **Paths:** evals rodam com `cwd=registry/` e `file://devops/<slug>/prompt.md`
