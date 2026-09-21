# Estratégia de gate CI — CP10

Documento de decisão para o pipeline GitHub Actions de eval promptfoo. Referência: `.github/workflows/prompt-eval.yml` e `registry/scripts/run-*-evals.sh`.

## 1. O que falha o build

**Decisão adotada (A):** o build **falha** se qualquer teste **determinístico (CP08)** ou **juiz causa-raiz (CP09)** falhar. Smoke tests (prompts de saída aberta) rodam em job separado e são **non-blocking** (`continue-on-error: true`).

| Alternativa | Prós | Contras |
|-------------|------|---------|
| **A: Gate strict det+juiz, smoke advisory** | CI confiável; menos flake em PRs | Cobertura bloqueante parcial (5 prompts só reportam) |
| **B: Tudo blocking incluindo smoke** | Cobertura máxima na suíte | Smoke frágil (`output.length > 100`) quebra merge sem sinal de regressão real |
| **C: Só determinístico, juiz manual** | Zero flake do juiz | RCA sem gate automático; CP09 perde valor operacional |

**Rationale:** prompts abertos (backpressure, migração Forge, verificação de policy) não têm resposta única — smoke garante que o prompt responde dentro de latência/custo, mas não julga qualidade. Gate bloqueante cobre formato (CP08) e qualidade calibrada (CP09).

**Configs bloqueantes (4):**

- `devops/nota-de-triagem/promptfooconfig.yaml`
- `devops/triagem-de-pods/promptfooconfig.yaml`
- `devops/networkpolicy-sentinel/promptfooconfig.yaml`
- `devops/causa-raiz-cerebro/promptfooconfig.yaml`

**Configs advisory (5):**

- `devops/backpressure-relay/promptfooconfig.yaml`
- `devops/migracao-forge-diagnostico/promptfooconfig.yaml`
- `devops/migracao-forge-plano/promptfooconfig.yaml`
- `devops/migracao-forge-fase-1/promptfooconfig.yaml`
- `devops/networkpolicy-sentinel-verificacao/promptfooconfig.yaml`

---

## 2. Suíte inteira vs prompts alterados

**Decisão adotada (A):** suíte **inteira** (`npm run eval:gate` + `npm run eval:smoke`) em todo PR e push para `main`/`master`.

| Alternativa | Prós | Contras |
|-------------|------|---------|
| **A: Suíte completa** | Regressão cruzada não escapa | Mais tokens e tempo por PR |
| **B: Só configs alterados (path filter)** | Barato e rápido | Mudança em `prompt.md` de um slug pode quebrar elo encadeado de outro |
| **C: Full no main, incremental no PR** | Meio-termo de custo | Lógica extra no workflow; PR pode passar e main falhar depois |

**Rationale:** biblioteca pequena (9 prompts); custo de suíte completa aceitável; encadeamento CP05 torna path filter arriscado.

---

## 3. Juiz LLM no CI

**Decisão adotada:** juiz causa-raiz **blocking**, com **1 retry** automático no job gate se a primeira execução falhar.

| Alternativa | Prós | Contras |
|-------------|------|---------|
| **Juiz blocking + 1 retry** | Reduz flake pontual do juiz | Até 2× tokens no pior caso |
| **Juiz scheduled nightly only** | PR barato | Regressão RCA só aparece no dia seguinte |
| **Juiz blocking sem retry** | Workflow simples | Flake calibrado no CP09 ainda pode bloquear merge |

**Parâmetros do juiz (CP09):**

- Rubrica: `registry/docs/cp09-rubrica-causa-raiz.md`
- Threshold: `llm-rubric` ≥ 0.75 (total ≥6/8 sem critério zerado)
- Calibração humana: `registry/docs/cp09-calibracao-juiz.md` (operador preenche)

---

## 4. Secrets e custo de tokens

**Decisão adotada (A):** secrets de repositório `OPENAI_API_KEY` e `ANTHROPIC_API_KEY` (documentados em `registry/.env.example`).

| Alternativa | Prós | Contras |
|-------------|------|---------|
| **A: Repo secrets** | Padrão GHA; setup simples | Forks e PRs externos não recebem secrets — eval falha ou fica incompleto |
| **B: Environment protection + approval** | Controle de gasto por ambiente | Fricção no fluxo; overkill para biblioteca didática |
| **C: Secrets só no main, skip eval em PR de fork** | Seguro para repo público | Contribuidores externos não validam localmente no CI |

**Custo estimado por PR (ordem de grandeza):**

- Gate: ~4 configs × 1–3 testes × gpt-4o-mini + 1 juiz gpt-4o
- Smoke: 5 configs × 1 teste × gpt-4o-mini
- Retry do gate: até 2× no pior caso

**Mitigações:** modelos mini/haiku nos providers; smoke non-blocking evita re-run por flake de saída aberta; documentar que operador monitora uso no dashboard do provedor.

**Forks:** PRs de forks não têm acesso aos secrets do repositório upstream. Esperado: workflow falha no gate por falta de chave — documentado no README para operador configurar secrets no repo publicado.

---

## Referências

- Workflow: `.github/workflows/prompt-eval.yml`
- Scripts: `registry/scripts/run-gate-evals.sh`, `run-smoke-evals.sh`, `run-all-evals.sh`
- Evidências (preencher manualmente): `registry/docs/cp10-ci-evidencias.md`
