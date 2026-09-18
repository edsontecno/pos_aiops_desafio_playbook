## Why

O Cerebro (Elasticsearch da Aegis) apresenta buscas lentas e resultados incompletos. O Checkpoint 03 exige um prompt parametrizável de **análise de causa-raiz** que receba config, métricas e logs como pacote único e conduza raciocínio até a causa real — não apenas sintomas.

## What Changes

- Template em `prompts/cp03-causa-raiz-cerebro/prompt.md` com parâmetro `{{artefatos}}` (config YAML + métricas + logs).
- `entrega.md` com **três artefatos** do enunciado já colados (config, métricas, logs); output RCA, curadoria e sanitização para preenchimento manual.
- Fixtures opcionais em `fixtures/` espelhando o mesmo conteúdo do `entrega.md` (para promptfoo CP08/09).
- Sem execução, sem API keys, sem `registry/` (convenção CP01–CP06).

## Capabilities

### New Capabilities

- `devops/causa-raiz-cerebro`: Template de prompt de RCA multi-artefato para degradação Elasticsearch/Cerebro.

### Modified Capabilities

- _(nenhuma)_

## Impact

- **Arquivos novos:** `prompts/cp03-causa-raiz-cerebro/prompt.md`, `entrega.md`, opcional `fixtures/cerebro-artefatos.yaml`
- **Relacionado:** CP09 adicionará LLM-as-judge (saída aberta, sem regex)
