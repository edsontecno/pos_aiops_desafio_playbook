## Context

CP10 — CI contínua. Depende CP7–CP9. Workflow na **raiz** do repo; eval roda em `registry/`. Operador configura secrets no GitHub e registra evidências manualmente.

## Goals / Non-Goals

**Goals:**

- `.github/workflows/prompt-eval.yml`
- Smoke configs para 5 prompts abertos
- `estrategia-gate-ci.md` com decisões comparadas
- Template evidências CI

**Non-Goals:**

- Executar workflow no apply
- Publicar repo (operador fornece URL)

## Decisions

### 1. Gate — o que falha o build (decisão recomendada)

**Escolha (A):** Build **falha** se qualquer teste **determinístico (CP08)** ou **juiz causa-raiz (CP09)** falhar. Smoke tests (prompts abertos) rodam mas são **non-blocking** (continue-on-error ou job separado report-only).

| Alternativa | Prós | Contras |
|-------------|------|---------|
| **A: Gate strict det+juiz, smoke advisory** | CI confiável, menos flake | Cobertura parcial bloqueante |
| **B: Tudo blocking incluindo smoke** | Cobertura máxima | Smoke frágil quebra PRs |
| **C: Só determinístico, juiz manual** | Zero flake do juiz | RCA sem gate automático |

**Rationale:** Enunciado valoriza decisão documentada; A equilibra confiança e custo/flake do juiz calibrado no CP9.

### 2. Escopo da suíte — full vs incremental

**Escolha (A):** Suíte **inteira** (`npm run eval`) em todo PR e push to main.

| Alternativa | Prós | Contras |
|-------------|------|---------|
| **A: Suíte completa** | Não deixa regressão cruzada passar | Mais tokens/tempo |
| **B: Só configs alterados (path filter)** | Barato, rápido | Regressão indireta escapa |
| **C: Full no main, incremental no PR** | Meio-termo | Complexidade no workflow |

**Rationale:** Biblioteca pequena (9 prompts); full suite aceitável; documentar custo.

### 3. Juiz LLM no CI

**Escolha:** Incluir causa-raiz no gate (A acima) com **1 retry** no workflow se primeiro eval falhar (opcional `continue-on-error: false` após retry).

| Alternativa | Prós | Contras |
|-------------|------|---------|
| Juiz blocking + 1 retry | Reduz flake pontual | 2× tokens no pior caso |
| Juiz scheduled nightly only | PR barato | Regressão RCA atrasa |
| Juiz blocking sem retry | Simples | Flake quebra merge |

### 4. Secrets

**Escolha:** GitHub Actions secrets `OPENAI_API_KEY`, `ANTHROPIC_API_KEY` no repositório público (forks não recebem secrets — documentar).

| Alternativa | Prós | Contras |
|-------------|------|---------|
| Repo secrets | Simples, padrão GHA | Fork PRs externos não rodam eval completo |
| Environment protection + approval | Controle gasto | Fricção no fluxo |

### 5. Workflow structure

```yaml
# .github/workflows/prompt-eval.yml
on: [pull_request, push]
jobs:
  prompt-eval:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: registry
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - uses: promptfoo/promptfoo-action@v1  # verificar tag atual na doc
        with:
          command: eval -c ...  # ou npm run eval
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

Ajustar action inputs conforme doc oficial na implementação.

### 6. Smoke tests (prompts abertos)

Config mínimo por prompt:

```yaml
assert:
  - type: javascript
    value: output.length > 100
  - type: latency
    threshold: 5000
  - type: cost
    threshold: 0.01
```

Vars com fixtures/cenários dos CP04–06.

### 7. run-all-evals.sh

Orquestra 9 configs; workflow chama script único. Smoke job pode usar `|| true` se non-blocking — documentar no estrategia.

## Risks / Trade-offs

| Risco | Mitigação |
|-------|-----------|
| Custo tokens por PR | Modelos mini/haiku; documentar |
| Juiz flake | Calibração CP9 + retry |
| Action promptfoo desatualizada | Pin versão; link doc no workflow |
| Frontmatter no prompt.md | Testar strip se eval falhar |

## Migration Plan

1. Adicionar 5 smoke promptfooconfig.yaml
2. Criar workflow GHA
3. Criar estrategia-gate-ci.md + cp10-ci-evidencias.md
4. Atualizar registry README com seção CI/secrets
5. Commit: `feat(devops): adiciona pipeline CI CP10`

## Open Questions

- Tag exata promptfoo-action — resolver na implementação consultando doc.
- URL repo público — operador preenche na entrega final.
