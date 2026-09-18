# triagem-de-pods Specification

## Purpose

Permite que plantonistas SRE triem rapidamente a saúde de pods Kubernetes no namespace do Sentinel a partir de um snapshot pré-coletado, com diagnóstico acionável e formato consistente para o playbook de IA operacional da Aegis.

## Requirements

### Requirement: Prompt parametrizável com snapshot de entrada

O prompt de triagem de pods SHALL aceitar exatamente um parâmetro `snapshot_cluster` contendo a saída combinada de `kubectl get pods`, `kubectl describe pod` e `kubectl logs` já coletados. O prompt MUST NOT depender de agentes, tools externas ou coleta adicional de dados em runtime.

#### Scenario: Snapshot completo fornecido

- **WHEN** o operador substitui `{{snapshot_cluster}}` pelo texto do snapshot e envia ao modelo
- **THEN** o modelo analisa apenas os dados presentes no snapshot, sem solicitar novos comandos kubectl

### Requirement: Identificação de pods problemáticos

O prompt SHALL identificar pods em estado problemático, incluindo mas não limitado a CrashLoopBackOff, ImagePullBackOff, Pending, Error ou reinícios anormais em andamento.

#### Scenario: Pod em CrashLoopBackOff

- **WHEN** o snapshot contém pod com STATUS CrashLoopBackOff e eventos de BackOff
- **THEN** a saída lista esse pod na seção de pods problemáticos com seu nome completo

#### Scenario: Cluster saudável

- **WHEN** todos os pods no snapshot estão Running e Ready sem incidente ativo
- **THEN** a saída declara explicitamente que não há pods problemáticos identificados

#### Scenario: Restart antigo estabilizado

- **WHEN** um pod está Running 1/1 com restart ocorrido dias atrás e sem falha ativa
- **THEN** a saída MUST NOT classificar esse pod como problemático

### Requirement: Causa provável com evidências

Para cada pod problemático, o prompt SHALL inferir causa provável cruzando STATUS, eventos do describe e logs — MUST NOT repetir apenas o STATUS como causa.

#### Scenario: OOMKilled com logs de memória

- **WHEN** describe indica Last State Reason OOMKilled e logs mostram out of memory ou heap no limite
- **THEN** a saída cita OOM ou estouro de memória como causa provável com evidências do snapshot

#### Scenario: ImagePullBackOff com manifest unknown

- **WHEN** eventos indicam Failed to pull image e manifest unknown para uma tag específica
- **THEN** a saída identifica imagem inexistente ou tag inválida no registry como causa provável

#### Scenario: Pending por Insufficient cpu

- **WHEN** eventos de FailedScheduling indicam Insufficient cpu
- **THEN** a saída identifica falta de capacidade de CPU no cluster como causa provável

### Requirement: Próxima ação para o plantão

Para cada pod problemático, o prompt SHALL recomendar uma próxima ação concreta e acionável (correção de configuração, rollback, escala, ou escalação).

#### Scenario: Ação após diagnóstico OOM

- **WHEN** causa provável é estouro de memória
- **THEN** a saída inclui ação como ajuste de memory limit/request ou redução de cache

### Requirement: Formato de saída legível

A saída SHALL ser estruturada em seções fixas (resumo, pods problemáticos, considerações finais) e MUST NOT ser um dump cru do snapshot.

#### Scenario: Estrutura mínima presente

- **WHEN** o prompt é executado com qualquer snapshot válido
- **THEN** a resposta contém seção de resumo executivo e seção de pods problemáticos ou declaração de ausência de problemas

### Requirement: Armazenamento em prompts/ durante checkpoints 01–06

Até o Checkpoint 06 inclusive, o template do prompt SHALL ser salvo em `prompts/` na raiz do repositório, em subpasta nomeada por checkpoint (`prompts/cp01-triagem-de-pods/` para o CP01). O prompt MUST NOT ser publicado em `registry/` antes do Checkpoint 07.

#### Scenario: Template do CP01 em prompts/

- **WHEN** a implementação do CP01 é concluída
- **THEN** existe `prompts/cp01-triagem-de-pods/prompt.md` contendo o prompt parametrizável com `{{snapshot_cluster}}` documentado

#### Scenario: Registry vazio até CP07

- **WHEN** checkpoints 01 a 06 estão em andamento
- **THEN** nenhum prompt do playbook Aegis é adicionado a `registry/devops/` — apenas o template base permanece

### Requirement: Entrega com entradas fixas e execução manual

A implementação MUST NOT executar prompts, MUST NOT invocar APIs de LLM e MUST NOT configurar API keys no repositório. O arquivo `entrega.md` SHALL incluir as **três entradas completas** (snapshots) copiadas de `checkpoints-plataforma.md` (Checkpoint 01, Entradas 1–3), uma por seção de execução. Modelo, **outputs** e curadoria permanecem para preenchimento manual pelo operador.

#### Scenario: Snapshots pré-preenchidos no entrega.md

- **WHEN** a implementação do CP01 é concluída
- **THEN** `prompts/cp01-triagem-de-pods/entrega.md` contém os três snapshots kubectl (CrashLoop/OOM, ImagePull+Pending, cluster saudável) já colados em **Snapshot usado**, com seções de output vazias ou placeholder

#### Scenario: Outputs não gerados por automação

- **WHEN** a implementação do CP01 é concluída via apply
- **THEN** nenhum output de modelo está preenchido por automação — apenas as entradas do enunciado

#### Scenario: Sem API key até CP06

- **WHEN** checkpoints 01 a 06 estão em implementação
- **THEN** o repositório MUST NOT conter `.env`, secrets de provedor LLM ou configuração de API key — configuração prevista a partir do CP07/CP08
