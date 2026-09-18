## Why

O Forge da Aegis roda em batch horário; Bruce Banner quer migrar para event-driven sem big-bang. O Checkpoint 05 exige **cadeia de prompts encadeados** — não um monolito — cada elo recebendo saída do anterior.

## What Changes

- Templates em `prompts/cp05-migracao-forge/`:
  - `prompt-diagnostico.md` — `{{estado_forge}}`
  - `prompt-plano.md` — `{{estado_forge}}` + `{{diagnostico_anterior}}`
  - `prompt-fase-1.md` — `{{plano_anterior}}` (+ contexto Forge)
- `entrega.md` com **estado Forge** do enunciado já colado; outputs dos três elos e curadoria para preenchimento manual.
- Fixture opcional `fixtures/forge-cenario.yaml` com estado atual do enunciado.
- Sem execução, sem API keys, sem registry.

## Capabilities

### New Capabilities

- `devops/migracao-forge`: Cadeia de três templates de prompt para migração batch→event-driven do Forge.

### Modified Capabilities

- _(nenhuma)_

## Impact

- **Arquivos novos:** 3 prompts + entrega.md (+ fixture opcional)
- **Saída aberta** — curadoria manual; sem promptfoo determinístico no CP08
