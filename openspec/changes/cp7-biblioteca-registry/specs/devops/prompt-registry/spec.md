## Purpose

Organiza o playbook de IA operacional da Aegis como catálogo versionado de prompts DevOps, migrando templates de `prompts/` para a estrutura prompt-registry com metadados, índices e convenções de commit semântico.

## ADDED Requirements

### Requirement: Estrutura prompt-registry por prompt

Cada prompt migrado SHALL residir em `registry/devops/<slug>/` com exatamente `prompt.md` e `README.md` compartilhando frontmatter idêntico.

#### Scenario: Par de arquivos por prompt

- **WHEN** um prompt do CP01–CP06 é migrado
- **THEN** a pasta contém `prompt.md` e `README.md` com o mesmo bloco YAML inicial

### Requirement: Frontmatter obrigatório

Todo prompt migrado SHALL incluir frontmatter com `nome`, `descricao`, `versao: 1.0.0`, `tags` e `inputs` listando cada `{{placeholder}}` do corpo.

#### Scenario: inputs alinhados aos placeholders

- **WHEN** `prompt.md` contém `{{snapshot_cluster}}`
- **THEN** frontmatter `inputs` inclui item `nome: snapshot_cluster` com descrição

### Requirement: README documentação humana

Cada `README.md` SHALL conter, abaixo do frontmatter: objetivo, casos de uso, exemplo de uso/saída, limitações conhecidas.

#### Scenario: README completo

- **WHEN** migração de um prompt concluída
- **THEN** README documenta objetivo e limitações além do texto do prompt

### Requirement: Migração completa CP01–CP06

A biblioteca SHALL incluir todos os prompts produzidos nos checkpoints 01 a 06 conforme mapeamento:

| Origem | Destino `registry/devops/` |
|--------|---------------------------|
| cp01-triagem-de-pods | triagem-de-pods |
| cp02-nota-de-triagem | nota-de-triagem |
| cp03-causa-raiz-cerebro | causa-raiz-cerebro |
| cp04-backpressure-relay | backpressure-relay |
| cp05 prompt-diagnostico | migracao-forge-diagnostico |
| cp05 prompt-plano | migracao-forge-plano |
| cp05 prompt-fase-1 | migracao-forge-fase-1 |
| cp06 prompt | networkpolicy-sentinel |
| cp06 prompt-verificacao | networkpolicy-sentinel-verificacao |

#### Scenario: Nove entradas no catálogo devops

- **WHEN** CP07 implementado
- **THEN** existem 9 pastas de prompt listadas em `registry/devops/README.md`

### Requirement: Índices atualizados

`registry/README.md` e `registry/devops/README.md` SHALL listar todos os prompts migrados com link e descrição de uma linha.

#### Scenario: Índice devops populado

- **WHEN** migração concluída
- **THEN** `registry/devops/README.md` substitui "Nenhum prompt cadastrado" pela lista de slugs

### Requirement: Preservar entrega.md com entradas fixas

A pasta `prompts/cpNN-*/` SHALL manter `entrega.md` com entradas já coladas de `checkpoints-plataforma.md` após migração. README no registry referencia essas entradas; outputs de execução permanecem opcionais/manuais.

#### Scenario: entrega.md intacto pós-migração

- **WHEN** CP07 implementado
- **THEN** `prompts/` ainda contém entrega.md com snapshots/alertas/artefatos do enunciado, não removidos

### Requirement: Documento de mapeamento

SHALL existir `registry/docs/mapeamento-playbook.md` explicando como checkpoints, pasta `prompts/` (entrega com entradas fixas) e slugs do registry se relacionam.

#### Scenario: Nota de mapeamento

- **WHEN** CP07 entregue
- **THEN** documento descreve origem CP0N → slug registry e convenções de nomenclatura

### Requirement: Exemplo canônico completo

Pelo menos `registry/devops/triagem-de-pods/` SHALL servir de referência completa (frontmatter, placeholders, README rico) para os demais prompts.

#### Scenario: Referência triagem-de-pods

- **WHEN** revisor consulta exemplo do enunciado
- **THEN** `triagem-de-pods/` atende 100% das convenções CLAUDE.md

### Requirement: Sem execução nem testes neste checkpoint

Migração SHALL NOT executar prompts, SHALL NOT adicionar `promptfooconfig.yaml` e SHALL NOT configurar API keys (reservado ao CP08).

#### Scenario: Ausência de promptfoo

- **WHEN** CP07 implementado
- **THEN** nenhuma pasta devops contém `promptfooconfig.yaml`
