# Mapeamento playbook → registry

Nota de referência para o Checkpoint 07: como os checkpoints do desafio Aegis, a pasta `prompts/` (rascunho/entrega) e os slugs do `registry/` se relacionam.

## Visão geral

| Área | Papel |
| ---- | ----- |
| `checkpoints-plataforma.md` | Enunciado do desafio — snapshots, alertas e artefatos fixos |
| `prompts/cpNN-*` | Templates de trabalho + `entrega.md` com entradas coladas e outputs opcionais |
| `registry/devops/<slug>/` | Biblioteca versionada (prompt-registry): `prompt.md` + `README.md` com frontmatter semver |

A migração CP07 **copia o corpo** dos prompts para o registry, preserva `prompts/` como histórico e não remove `entrega.md`.

## Tabela CP → slug

| Checkpoint | Origem em `prompts/` | Slug em `registry/devops/` |
| ---------- | -------------------- | --------------------------- |
| CP01 | `cp01-triagem-de-pods/prompt.md` | `triagem-de-pods` |
| CP02 | `cp02-nota-de-triagem/prompt.md` | `nota-de-triagem` |
| CP03 | `cp03-causa-raiz-cerebro/prompt.md` | `causa-raiz-cerebro` |
| CP04 | `cp04-backpressure-relay/prompt.md` | `backpressure-relay` |
| CP05 elo 1 | `cp05-migracao-forge/prompt-diagnostico.md` | `migracao-forge-diagnostico` |
| CP05 elo 2 | `cp05-migracao-forge/prompt-plano.md` | `migracao-forge-plano` |
| CP05 elo 3 | `cp05-migracao-forge/prompt-fase-1.md` | `migracao-forge-fase-1` |
| CP06 geração | `cp6-networkpolicy-sentinel/prompt.md` | `networkpolicy-sentinel` |
| CP06 verificação | `cp6-networkpolicy-sentinel/prompt-verificacao.md` | `networkpolicy-sentinel-verificacao` |

**Total:** 9 prompts no catálogo DevOps.

## Relação `prompts/` vs `registry/`

- **`prompt.md` (registry):** frontmatter YAML (`versao: 1.0.0`, `inputs`) + corpo com `{{placeholders}}` — pronto para ferramentas e CP08 (promptfoo).
- **`README.md` (registry):** mesmo frontmatter + objetivo, casos de uso, exemplo e limitações.
- **`entrega.md` (prompts):** execuções manuais do operador; entradas fixas do enunciado; outputs preenchidos quando o modelo for executado. O README do registry **referencia** essas entradas, não as duplica integralmente.
- **Exemplo canônico:** `registry/devops/triagem-de-pods/` — referência completa de convenções (`registry/CLAUDE.md`).

## Convenção de versão

- Versão inicial de todos os prompts migrados: **`1.0.0`** (semver).
- Incrementar `versao` no frontmatter ao evoluir o prompt; manter `prompt.md` e `README.md` sincronizados.

## Próximos passos (fora do CP07)

| Checkpoint | Escopo |
| ---------- | ------ |
| CP08 | `promptfooconfig.yaml` por prompt, asserts determinísticos |
| CP09 | LLM-as-judge (rubrica) |
| CP10 | Gate CI (GitHub Actions) |

O CP07 **não** adiciona promptfoo, API keys nem execução de modelos.
