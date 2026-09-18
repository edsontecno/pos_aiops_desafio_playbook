## Why

O time de SRE da Aegis (Sentinel) tria saúde de pods no Kubernetes de forma ad-hoc via prompts soltos no chat — inconsistente e não reutilizável. O Checkpoint 01 exige o primeiro item formal do playbook de IA operacional: um prompt parametrizável que recebe snapshot de cluster (`kubectl get/describe/logs`) e devolve triagem confiável com causa provável e próxima ação, sem agentes ou tools externas.

## What Changes

- Adicionar **apenas o template** do prompt parametrizável em `prompts/cp01-triagem-de-pods/prompt.md` (workspace dos checkpoints 01–06).
- Parâmetro único `{{snapshot_cluster}}` documentado no template.
- Adicionar `prompts/cp01-triagem-de-pods/entrega.md` com os **três snapshots** do enunciado já colados (Entradas 1–3 de `checkpoints-plataforma.md`); modelo, outputs e curadoria para preenchimento manual.
- **Não** executar prompts nem chamar modelos neste change — execução fica a cargo do operador, fora do escopo de implementação automatizada.
- **Não** configurar API keys no repositório até conclusão do Checkpoint 06 (contas/chaves entram a partir do CP07/CP08).
- **Não** publicar em `registry/` neste change — migração para prompt-registry fica reservada ao Checkpoint 07.
- Estabelecer convenção: CP01–CP06 salvam templates em `prompts/`; execução manual; registry só no CP07.

## Capabilities

### New Capabilities

- `devops/triagem-de-pods`: Template de prompt de triagem de pods Kubernetes a partir de snapshot pré-coletado. Comportamento esperado definido na spec; artefato entregue é o template, não outputs de modelo.

### Modified Capabilities

- _(nenhuma — primeiro prompt da biblioteca)_

## Impact

- **Arquivos novos:** `prompts/cp01-triagem-de-pods/prompt.md`, `prompts/cp01-triagem-de-pods/entrega.md` (template)
- **Arquivos não alterados:** `registry/`, `.env`, secrets, configs de API
- **Fora de escopo neste change:** execução contra snapshots, curadoria preenchida, promptfoo (CP08), CI (CP10)
