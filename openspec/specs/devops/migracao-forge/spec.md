# migracao-forge Specification

## Purpose

Decompõe migração complexa do pipeline Forge (batch → event-driven) em etapas encadeadas de prompts, evitando respostas rasas de prompt monolítico.

## Requirements

### Requirement: Cadeia de três prompts parametrizáveis

A entrega SHALL consistir em três templates distintos, não um prompt único:

1. **Diagnóstico** — analisa estado atual (`{{estado_forge}}`)
2. **Plano** — propõe migração em fases reversíveis (`{{estado_forge}}`, `{{diagnostico_anterior}}`)
3. **Fase 1** — detalha primeiro passo executável (`{{plano_anterior}}`, opcionalmente `{{estado_forge}}`)

#### Scenario: Três arquivos de prompt

- **WHEN** implementação CP05 concluída
- **THEN** existem três arquivos `prompt-*.md` em `prompts/cp05-migracao-forge/`

### Requirement: Encadeamento explícito

Cada prompt após o diagnóstico SHALL documentar que recebe saída do elo anterior como entrada parametrizada.

#### Scenario: Plano depende de diagnóstico

- **WHEN** operador usa elo 2
- **THEN** cola output manual do elo 1 em `{{diagnostico_anterior}}`

### Requirement: Restrições de migração no template

Templates MUST instruir: consumo contínuo do Relay, dependentes funcionando (Sentinel, Cerebro, billing), sem big-bang, rollback possível.

#### Scenario: Anti big-bang

- **WHEN** prompt de plano é aplicado
- **THEN** instruções exigem fases incrementais com reversão

### Requirement: Entrega com estado Forge fixo e cadeia manual

MUST NOT executar cadeia nem configurar API keys. O `entrega.md` SHALL incluir o **estado atual do Forge** copiado de `checkpoints-plataforma.md` (Checkpoint 05) em **Estado Forge usado** (entrada do elo 1). Seções por elo (1–3) SHALL documentar ordem da cadeia; **outputs** dos elos 1–2 e output final do elo 3 permanecem placeholders para preenchimento manual.

#### Scenario: Estado Forge pré-preenchido

- **WHEN** implementação CP05 concluída
- **THEN** `entrega.md` contém bloco "Forge hoje" do enunciado como entrada fixa do diagnóstico

#### Scenario: Outputs da cadeia manuais

- **WHEN** apply concluído
- **THEN** nenhum output de elo da cadeia foi gerado por automação
