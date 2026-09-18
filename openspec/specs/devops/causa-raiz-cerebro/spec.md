# causa-raiz-cerebro Specification

## Purpose

Suporta análise de causa-raiz de degradação no Cerebro cruzando configuração, métricas temporais e logs Elasticsearch para diagnóstico acionável em incidentes de busca/indexação.

## Requirements

### Requirement: Prompt parametrizável com pacote de artefatos

O prompt SHALL aceitar um parâmetro `artefatos` contendo configuração do cluster, métricas e logs correlacionados temporalmente. MUST NOT usar agentes ou tools externas.

#### Scenario: Artefatos colados na entrada

- **WHEN** o operador substitui `{{artefatos}}` pelo pacote completo
- **THEN** o modelo analisa os três tipos de dado sem solicitar coleta adicional

### Requirement: Raciocínio de causa-raiz, não lista de sintomas

A saída SHALL identificar causa-raiz provável correlacionando evidências (ex.: reindexação travada saturando heap) e MUST distinguir causa de efeito (ex.: queda de cache hit como consequência).

#### Scenario: Reindexação como causa

- **WHEN** logs mostram reindex job em 41% às 10h e heap no teto com circuit breaker
- **THEN** a saída aponta reindexação prolongada como causa-raiz, não apenas "latência alta"

### Requirement: Ação proporcional e honestidade epistêmica

A saída SHALL propor ação coerente com o diagnóstico e MUST declarar incertezas quando os dados não permitirem conclusão definitiva.

#### Scenario: Limites dos dados

- **WHEN** artefatos não cobrem uma hipótese
- **THEN** a saída explicita o que não pode ser concluído

### Requirement: Armazenamento em prompts/ e entrega com artefatos fixos

Template em `prompts/cp03-causa-raiz-cerebro/`. MUST NOT executar prompts nem configurar API keys. O `entrega.md` SHALL incluir o pacote completo de **três artefatos** de `checkpoints-plataforma.md` (Checkpoint 03): `cerebro.yaml`, tabela de métricas e trecho de logs — em **Artefatos usados**. Modelo, **output** de causa-raiz e curadoria permanecem manuais; seção **Sanitização** com placeholder.

#### Scenario: Artefatos pré-preenchidos

- **WHEN** implementação CP03 concluída
- **THEN** `entrega.md` contém config YAML, métricas 08h–10h e logs Elasticsearch do enunciado

#### Scenario: Output RCA manual

- **WHEN** apply concluído
- **THEN** nenhum output de análise de causa-raiz foi gerado por automação
