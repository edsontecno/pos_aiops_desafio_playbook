## Why

NetworkPolicy permissiva no Sentinel foi barrada por segurança. O Checkpoint 06 exige prompt que endureça manifesto + **processo de verificação/refino iterativo** (v1 → verificação → v2). Entrega inclui registro de iterações — preenchido manualmente pelo operador.

## What Changes

- `prompts/cp6-networkpolicy-sentinel/prompt.md` — parâmetros `{{manifesto_permissivo}}`, `{{regras_padrao}}`, `{{mapa_servicos}}`
- `prompt-verificacao.md` — template para IA criticar NetworkPolicy gerada (revisor de segurança)
- `entrega.md` com **manifesto, regras e mapa de serviços** do enunciado já colados; iterações v1→v2 e curadoria para preenchimento manual
- Fixture opcional `fixtures/networkpolicy-cenario.yaml`
- Sem execução automatizada, sem API keys, sem registry.

## Capabilities

### New Capabilities

- `devops/networkpolicy-sentinel`: Templates de geração e verificação de NetworkPolicy endurecida para namespace sentinel-prod.

### Modified Capabilities

- _(nenhuma)_

## Impact

- **Arquivos novos:** 2 prompts + entrega.md (+ fixture)
- **Relacionado:** CP08 testará `networkpolicy-sentinel` com asserts YAML determinísticos
