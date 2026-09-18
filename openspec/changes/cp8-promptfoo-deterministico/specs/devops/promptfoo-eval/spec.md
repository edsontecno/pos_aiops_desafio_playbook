## Purpose

Garante qualidade determinística dos prompts de saída estruturada do playbook Aegis via promptfoo, validando formato, conteúdo esperado, latência máxima e custo por chamada.

## ADDED Requirements

### Requirement: Config colocalizado por prompt estruturado

Os prompts `nota-de-triagem`, `triagem-de-pods` e `networkpolicy-sentinel` SHALL each have `promptfooconfig.yaml` na mesma pasta que `prompt.md`.

#### Scenario: Três configs presentes

- **WHEN** CP08 implementado
- **THEN** existem três arquivos `promptfooconfig.yaml` sob `registry/devops/`

### Requirement: Dois provedores distintos

Cada `promptfooconfig.yaml` SHALL declarar pelo menos dois providers de fornecedores diferentes (ex.: `openai:gpt-4o-mini` e `anthropic:claude-3-5-haiku-latest`).

#### Scenario: Multi-provider

- **WHEN** config é inspecionado
- **THEN** lista `providers` contém ≥2 entradas de vendors distintos

### Requirement: Limites operacionais globais

Todo test case SHALL incluir asserts de latência ≤ 5000ms e custo ≤ US$ 0,01 por chamada.

#### Scenario: Asserts latency e cost

- **WHEN** qualquer teste roda via promptfoo
- **THEN** config inclui `type: latency` max 5000 e `type: cost` max 0.01

### Requirement: Asserts nota-de-triagem

Config `nota-de-triagem` SHALL rodar 3 testes com alertas crus do CP02 e asserts:

- contém rótulos `ALERTA:`, `IMPACTO:`, `HIPÓTESE INICIAL:`, `AÇÃO IMEDIATA:`, `ESCALAR PARA:`
- regex `ESCALAR PARA:.*@\w+`
- saída ≤ 8 linhas (javascript ou equivalente)

#### Scenario: Três alertas CP02

- **WHEN** config inspecionado
- **THEN** três entradas `vars.alerta_cru` correspondem aos alertas do enunciado CP02

### Requirement: Asserts triagem-de-pods

Config `triagem-de-pods` SHALL rodar 3 testes com snapshots CP01:

- Entrada 1: cita pod `sentinel-api-7d9c8b6f4-h4m2t` e `OOMKilled` ou `memória`
- Entrada 2: cita ImagePull/`2.9.2` e `Insufficient` cpu
- Entrada 3: indica ausência de pod problemático; MUST NOT classificar falha em pods saudáveis

#### Scenario: Três snapshots CP01

- **WHEN** config inspecionado
- **THEN** três test cases com `vars.snapshot_cluster` do enunciado CP01

### Requirement: Asserts networkpolicy-sentinel

Config `networkpolicy-sentinel` SHALL testar manifesto permissivo + regras + mapa CP06 com asserts:

- YAML contém `kind: NetworkPolicy` e `policyTypes` com Ingress e Egress
- `not-contains` ou javascript rejeita `- {}`
- egress portas 5432 e 9200; ingress Relay `app: relay`
- comentários `#` presentes nas regras

#### Scenario: Cenário CP06 como vars

- **WHEN** config inspecionado
- **THEN** vars incluem manifesto barrado, regras Aegis e mapa de serviços

### Requirement: Vars alinhadas a checkpoints-plataforma.md e entrega.md

Os `vars` de cada `promptfooconfig.yaml` SHALL usar o **mesmo texto** das entradas em `checkpoints-plataforma.md` e em `prompts/cpNN-*/entrega.md` (snapshots CP01, alertas CP02, inputs CP06) — fonte única, sem paráfrase.

#### Scenario: Consistência entrega ↔ promptfoo

- **WHEN** CP08 implementado após CP01–CP06
- **THEN** cada test case vars reproduz verbatim o bloco correspondente do enunciado

### Requirement: Tooling e execução manual

SHALL existir `registry/package.json` com script eval e `registry/scripts/run-all-evals.sh`. Implementação MUST NOT executar eval automaticamente; operador registra resultados em `registry/docs/cp08-eval-resultados.md`.

#### Scenario: Template de resultados vazio

- **WHEN** CP08 apply concluído
- **THEN** `cp08-eval-resultados.md` existe com seções pass/fail por prompt, sem output preenchido por automação

### Requirement: Prompts abertos excluídos

CP03, CP04 e CP05 MUST NOT receber `promptfooconfig.yaml` determinístico neste checkpoint.

#### Scenario: Sem config nos prompts abertos

- **WHEN** CP08 implementado
- **THEN** pastas causa-raiz-cerebro, backpressure-relay e migracao-forge-* não contêm promptfooconfig
