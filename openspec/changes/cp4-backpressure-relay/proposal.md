## Why

Picos de telemetry saturam o Relay e atrasam alerting no Sentinel. O Checkpoint 04 exige prompt parametrizável que receba cenário + restrições e **compare múltiplas estratégias de backpressure** antes de recomendar — raciocínio importa tanto quanto a decisão.

## What Changes

- Template `prompts/cp04-backpressure-relay/prompt.md` com `{{cenario}}`.
- `entrega.md` com **cenário Relay** do enunciado já colado; output e curadoria para preenchimento manual.
- Sem execução, sem API keys, sem registry.

## Capabilities

### New Capabilities

- `devops/backpressure-relay`: Template de prompt de decisão arquitetural sobre backpressure no barramento Relay.

### Modified Capabilities

- _(nenhuma)_

## Impact

- **Arquivos novos:** `prompts/cp04-backpressure-relay/prompt.md`, `entrega.md`
- **Saída aberta** — testada por julgamento (CP09 estende rubrica futura ou curadoria manual)
