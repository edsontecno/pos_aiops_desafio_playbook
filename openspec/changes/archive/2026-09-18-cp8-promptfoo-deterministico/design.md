## Context

CP08 — camada determinística promptfoo. Depende de CP7 (`registry/devops/` populado). CP03–05 ficam para CP09 (LLM-as-judge). Operador executa eval manualmente; apply só entrega configs e tooling.

## Goals / Non-Goals

**Goals:**

- 3 `promptfooconfig.yaml` completos com asserts do enunciado
- package.json + run-all-evals.sh
- `.env.example` para API keys
- Template `cp08-eval-resultados.md` para curadoria manual

**Non-Goals:**

- Rodar `promptfoo eval` no apply
- CI GitHub Actions (CP10)
- promptfoo para causa-raiz/backpressure/migracao-forge

## Decisions

### 1. Working directory = `registry/`

Configs usam paths relativos ao registry:

```yaml
prompts:
  - file://devops/nota-de-triagem/prompt.md
```

Execução: `cd registry && npx promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml`

### 2. Providers padrão

```yaml
providers:
  - openai:gpt-4o-mini
  - anthropic:claude-3-5-haiku-20241022
```

Operador ajusta se modelo indisponível; curadoria documenta trade-off latência/custo.

### 3. Fixtures inline vs arquivos

**Escolha:** vars inline nos configs (snapshots/alertas longos com `>`) — autocontido por prompt.

**Alternativa:** `registry/devops/fixtures/*.yaml` referenciado via `defaultTest` — usar se configs ficarem ilegíveis.

### 4. Asserts networkpolicy — javascript para `- {}`

```javascript
// output must not contain allow-all rule "- {}"
!/- \{\}/.test(output)
```

### 5. Assert triagem Entrada 3 — not-contains + contains

Combinar `contains` "Nenhum pod problemático" (ou similar) com `not-contains` padrões de falha fora de contexto — usar javascript se ambíguo.

### 6. package.json scripts

```json
{
  "scripts": {
    "eval": "bash scripts/run-all-evals.sh",
    "eval:nota": "promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml",
    ...
  }
}
```

### 7. Secrets

- `registry/.env.example`: `OPENAI_API_KEY=`, `ANTHROPIC_API_KEY=`
- `.gitignore` já ignora `.env`
- Sem secrets no repo

## Risks / Trade-offs

| Risco | Mitigação |
|-------|-----------|
| Prompt frontmatter interfere no promptfoo | promptfoo lê arquivo; frontmatter YAML pode precisar strip — testar manualmente; documentar se necessário extrair só corpo |
| Flaky latency/cost | Escolher modelos mini/haiku; curadoria registra falhas |
| Path registry vs enunciado | Documentar cwd em cp08-eval-resultados.md |

## Migration Plan

1. Adicionar package.json + install promptfoo
2. Criar 3 configs
3. Criar run-all-evals.sh + .env.example + cp08-eval-resultados.md
4. Commit: `feat(devops): adiciona testes promptfoo CP08`

## Open Questions

- Strip frontmatter no promptfoo — verificar na execução manual; ajustar prompt.md ou config se falhar.
