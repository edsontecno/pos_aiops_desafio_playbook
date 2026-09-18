## Purpose

Automatiza execução da suíte promptfoo em pull requests e pushes via GitHub Actions, bloqueando merge quando prompts regredem conforme política de gate documentada.

## ADDED Requirements

### Requirement: Workflow GitHub Actions

SHALL existir `.github/workflows/prompt-eval.yml` disparando em `pull_request` e `push` (branch principal), com working-directory `registry/` e invocação da suíte promptfoo.

#### Scenario: Workflow presente

- **WHEN** CP10 implementado
- **THEN** arquivo workflow existe na raiz do repositório em `.github/workflows/`

#### Scenario: Secrets configurados via GitHub

- **WHEN** workflow executa no GitHub
- **THEN** usa secrets `OPENAI_API_KEY` e `ANTHROPIC_API_KEY` (documentados, não no git)

### Requirement: Cobertura promptfoo para todos os prompts

Cada um dos 9 prompts em `registry/devops/` SHALL ter `promptfooconfig.yaml`:

| Slug | Tipo de teste |
|------|----------------|
| triagem-de-pods | determinístico (CP08) |
| nota-de-triagem | determinístico (CP08) |
| networkpolicy-sentinel | determinístico (CP08) |
| causa-raiz-cerebro | LLM-as-judge (CP09) |
| backpressure-relay | smoke (vars = cenário CP04 de checkpoints-plataforma.md) |
| migracao-forge-diagnostico | smoke (vars = estado Forge CP05) |
| migracao-forge-plano | smoke |
| migracao-forge-fase-1 | smoke |
| networkpolicy-sentinel-verificacao | smoke (vars = inputs CP06) |

#### Scenario: Nove configs

- **WHEN** CP10 implementado
- **THEN** cada pasta listada contém promptfooconfig.yaml

### Requirement: Gate de regressão documentado

`registry/docs/estrategia-gate-ci.md` SHALL documentar explicitamente:

1. O que **falha o build** (determinísticos + juiz vs smoke report-only)
2. **Suíte inteira vs prompts alterados** — ≥2 alternativas comparadas
3. **Juiz LLM no CI** — threshold, flakiness, retry — ≥2 alternativas
4. **Secrets e custo de tokens** — ≥2 alternativas

#### Scenario: Decisões com alternativas

- **WHEN** documento inspecionado
- **THEN** cada uma das 4 decisões acima inclui pelo menos duas opções com prós/contras

### Requirement: Evidências de CI (manual)

`registry/docs/cp10-ci-evidencias.md` SHALL existir como template para operador registrar:

- Execução CI bem-sucedida
- Execução CI com falha provocada (prompt regredido)
- Links ou descrição das runs GitHub Actions

#### Scenario: Template evidências vazio

- **WHEN** CP10 apply concluído
- **THEN** template existe sem evidências preenchidas por automação

### Requirement: Apply não dispara CI

Implementação MUST NOT executar GitHub Actions nem commitar secrets.

#### Scenario: Sem execução no apply

- **WHEN** CP10 apply concluído
- **THEN** apenas arquivos de workflow e docs foram criados localmente
