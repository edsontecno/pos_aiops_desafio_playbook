# Playbook de IA Operacional — Desafio Aegis

Repositório do desafio técnico **IAOps** da pós-graduação em AIOps e IA na Engenharia de Cloud ([pos.veronez.io/pos-aiops](https://pos.veronez.io/pos-aiops/)).

## Contexto

A **Aegis** é uma empresa fictícia de observabilidade e resposta a incidentes. Quatro sistemas sustentam a plataforma:

- **Relay** — ingestão e barramento de eventos
- **Forge** — pipeline de dados e data warehouse
- **Sentinel** — observabilidade e alerting (produto core)
- **Cerebro** — indexação e busca de logs

O desafio pede a construção de um **playbook de IA operacional**: uma biblioteca de prompts parametrizáveis, versionados e testados como código — substituindo prompts ad-hoc no histórico do chat por ativos confiáveis que qualquer engenheiro do time possa usar.

Ao longo de **10 checkpoints**, a complexidade cresce: dos primeiros prompts de triagem até um pipeline CI com evals determinísticos e LLM-as-judge. Cada checkpoint tem sua entrega documentada na tabela abaixo.

## Estrutura do repositório

| Pasta / arquivo | Papel |
| --------------- | ----- |
| [`prompts/`](./prompts/) | Rascunhos e entregas dos CPs 01–06 (`prompt.md` + `entrega.md`) |
| [`registry/`](./registry/) | Biblioteca versionada (CP07+) — prompts com frontmatter, README e testes promptfoo |
| [`fixtures/`](./fixtures/) | Dados de entrada reutilizáveis para evals |
| [`.github/workflows/prompt-eval.yml`](./.github/workflows/prompt-eval.yml) | Pipeline CI de avaliação de prompts (CP10) |

## Checkpoints

| CP | Tema | Entrega |
| -- | ---- | ------- |
| **01** | Triagem de pods Kubernetes | [`prompts/cp01-triagem-de-pods/entrega.md`](./prompts/cp01-triagem-de-pods/entrega.md) |
| **02** | Nota de triagem padronizada | [`prompts/cp02-nota-de-triagem/entrega.md`](./prompts/cp02-nota-de-triagem/entrega.md) |
| **03** | Causa-raiz da degradação no Cerebro | [`prompts/cp03-causa-raiz-cerebro/entrega.md`](./prompts/cp03-causa-raiz-cerebro/entrega.md) |
| **04** | Backpressure no Relay | [`prompts/cp04-backpressure-relay/entrega.md`](./prompts/cp04-backpressure-relay/entrega.md) |
| **05** | Migração do Forge (batch → tempo real) | [`prompts/cp05-migracao-forge/entrega.md`](./prompts/cp05-migracao-forge/entrega.md) |
| **06** | NetworkPolicy do Sentinel | [`prompts/cp6-networkpolicy-sentinel/entrega.md`](./prompts/cp6-networkpolicy-sentinel/entrega.md) |
| **07** | Biblioteca como código (prompt-registry) | [`registry/docs/mapeamento-playbook.md`](./registry/docs/mapeamento-playbook.md) · [`registry/README.md`](./registry/README.md) |
| **08** | Testes determinísticos (promptfoo) | [`registry/docs/cp08-eval-resultados.md`](./registry/docs/cp08-eval-resultados.md) |
| **09** | Gate de qualidade (LLM-as-judge) | [`registry/docs/cp09-rubrica-causa-raiz.md`](./registry/docs/cp09-rubrica-causa-raiz.md) · [`registry/docs/cp09-calibracao-juiz.md`](./registry/docs/cp09-calibracao-juiz.md) |
| **10** | Playbook em produção contínua (CI) | [`registry/docs/estrategia-gate-ci.md`](./registry/docs/estrategia-gate-ci.md) · [`.github/workflows/prompt-eval.yml`](./.github/workflows/prompt-eval.yml) · [`registry/docs/cp10-ci-evidencias.md`](./registry/docs/cp10-ci-evidencias.md) |

## Rodar evals localmente

```bash
cd registry
cp .env.example .env   # preencher OPENAI_API_KEY
npm install
npm run eval           # suíte completa
npm run eval:gate      # determinísticos + juiz (bloqueante no CI)
npm run eval:smoke     # prompts abertos (advisory no CI)
```

Detalhes de secrets, política de gate e convenções do catálogo estão em [`registry/README.md`](./registry/README.md).
