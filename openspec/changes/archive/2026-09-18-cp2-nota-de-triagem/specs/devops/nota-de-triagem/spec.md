## Purpose

Padroniza notas de triagem de incidentes a partir de alertas crus do Sentinel e sistemas Aegis, garantindo formato uniforme para passagem de turno entre plantonistas.

## ADDED Requirements

### Requirement: Prompt parametrizável com alerta cru

O prompt de nota de triagem SHALL aceitar exatamente um parâmetro `alerta_cru` contendo o texto do alerta sem formatação padronizada. O prompt MUST NOT depender de agentes, tools externas ou dados além do alerta fornecido.

#### Scenario: Alerta cru fornecido

- **WHEN** o operador substitui `{{alerta_cru}}` pelo texto do alerta e envia ao modelo
- **THEN** o modelo produz nota no formato padronizado usando apenas informações inferíveis do alerta

### Requirement: Formato de saída com cinco rótulos fixos

A saída SHALL conter exatamente estes rótulos, nesta ordem, cada um em linha própria:

1. `ALERTA:`
2. `IMPACTO:`
3. `HIPÓTESE INICIAL:`
4. `AÇÃO IMEDIATA:`
5. `ESCALAR PARA:`

#### Scenario: Estrutura completa presente

- **WHEN** o prompt é executado com alerta cru válido
- **THEN** a saída contém os cinco rótulos acima

#### Scenario: Concisão da nota

- **WHEN** o prompt é executado
- **THEN** a nota completa MUST NOT exceder 8 linhas

### Requirement: Escalonamento com handle

O campo `ESCALAR PARA:` SHALL incluir um handle no formato `@palavra` indicando time ou canal de escalação.

#### Scenario: Handle de escalação presente

- **WHEN** a nota é gerada
- **THEN** a linha `ESCALAR PARA:` contém pelo menos um handle `@` seguido de identificador alfanumérico

### Requirement: Separação entre referência de formato e entradas de teste

O template e a documentação MUST NOT confundir exemplos de **formato de saída** (notas prontas de referência) com **entradas de teste** (alertas crus). Referências de formato SHALL ficar documentadas separadamente das entradas usadas em execução manual.

#### Scenario: Template documenta distinção

- **WHEN** a implementação do CP02 é concluída
- **THEN** `prompt.md` ou comentário adjacente deixa claro que exemplos de nota pronta são referência de formato, não input do prompt

### Requirement: Armazenamento em prompts/ durante checkpoints 01–06

O template SHALL ser salvo em `prompts/cp02-nota-de-triagem/`. MUST NOT ser publicado em `registry/` antes do Checkpoint 07.

#### Scenario: Template do CP02 em prompts/

- **WHEN** a implementação do CP02 é concluída
- **THEN** existe `prompts/cp02-nota-de-triagem/prompt.md` com `{{alerta_cru}}` documentado

### Requirement: Entrega com alertas fixos e execução manual

A implementação MUST NOT executar prompts, MUST NOT invocar APIs de LLM e MUST NOT configurar API keys. O `entrega.md` SHALL incluir os **três alertas crus** copiados de `checkpoints-plataforma.md` (Checkpoint 02, Entradas 1–3), um por seção de execução — **não** os exemplos de nota pronta (formato de saída). Modelo e **outputs** permanecem para preenchimento manual pelo operador.

#### Scenario: Alertas crus pré-preenchidos

- **WHEN** a implementação do CP02 é concluída
- **THEN** `entrega.md` contém os três alertas crus (Sentinel autoscaler, Relay reject rate, Forge consumer lag) em **Alerta usado**

#### Scenario: Formato vs entrada separados

- **WHEN** implementação concluída
- **THEN** exemplos de nota padronizada (formato) ficam apenas no `prompt.md` como referência estática, não misturados com as entradas de teste no `entrega.md`

#### Scenario: Sem API key até CP06

- **WHEN** checkpoints 01 a 06 estão em implementação
- **THEN** o repositório MUST NOT conter configuração de API key de provedor LLM

### Requirement: Justificativa do método concisa com sugestão pré-preenchida

O `entrega.md` SHALL incluir a seção **Justificativa do método** com **uma sugestão já preenchida** pelo apply: **no máximo 3 linhas** (idealmente uma frase) que nomeie a técnica usada em `prompt.md` e explique brevemente por que foi escolhida. O operador MAY ajustar após executar o prompt nos três alertas crus.

#### Scenario: Sugestão alinhada ao prompt.md

- **WHEN** a implementação do CP02 é concluída
- **THEN** a justificativa sugerida descreve o método efetivamente implementado em `prompt.md` (ex.: role + zero-shot estrutural + referência de formato estática)

#### Scenario: Concisão da justificativa

- **WHEN** a implementação do CP02 é concluída
- **THEN** a seção Justificativa do método tem no máximo 3 linhas de texto sugerido

#### Scenario: Não é placeholder vazio

- **WHEN** a implementação do CP02 é concluída via apply
- **THEN** a seção contém frase de sugestão redigida — MUST NOT ser apenas `[preencher]` ou instrução genérica sem conteúdo
