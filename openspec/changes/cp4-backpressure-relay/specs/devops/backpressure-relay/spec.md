## Purpose

Apoia decisão de engenharia sobre estratégias de backpressure no Relay da Aegis, pesando SLAs, custo e zero perda de telemetry.

## ADDED Requirements

### Requirement: Prompt parametrizável com cenário

O prompt SHALL aceitar `cenario` descrevendo estado do Relay (throughput, pico, retenção, consumidores) e restrições do time (SLA Sentinel 60s, Forge 15min, orçamento, zero perda).

#### Scenario: Cenário Relay fornecido

- **WHEN** operador substitui `{{cenario}}` pelo bloco do enunciado
- **THEN** modelo analisa dentro das restrições declaradas

### Requirement: Comparação de múltiplos caminhos

A saída SHALL apresentar pelo menos duas estratégias (ex.: priorização Sentinel vs Forge, DLQ, isolamento por tenant, auto-scaling) com prós e contras antes de recomendação final.

#### Scenario: Análise comparativa

- **WHEN** prompt executado
- **THEN** saída inclui comparação explícita, não apenas uma recomendação única sem raciocínio

### Requirement: Respeito a restrições invioláveis

Recomendação MUST NOT propor perda de telemetry. MUST considerar SLA Sentinel ≤60s e lag Forge até 15min.

#### Scenario: Zero perda de mensagens

- **WHEN** estratégia avaliada descarta telemetry sob pico
- **THEN** saída rejeita ou qualifica como inaceitável para produto de observabilidade

### Requirement: Entrega com cenário fixo e execução manual

Artefatos em `prompts/cp04-backpressure-relay/`. MUST NOT executar prompts nem configurar API keys. O `entrega.md` SHALL incluir o **cenário Relay completo** (capacidade, pico, retenção, consumidores e restrições) copiado de `checkpoints-plataforma.md` (Checkpoint 04) em **Cenário usado**. Modelo, **output** comparativo e curadoria permanecem manuais.

#### Scenario: Cenário pré-preenchido

- **WHEN** implementação CP04 concluída
- **THEN** `entrega.md` contém bloco do cenário Relay do enunciado, sem output de modelo
