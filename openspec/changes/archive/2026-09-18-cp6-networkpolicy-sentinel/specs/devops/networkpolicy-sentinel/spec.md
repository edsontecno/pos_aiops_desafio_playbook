## Purpose

Gera e verifica NetworkPolicies Kubernetes endurecidas para o Sentinel, substituindo manifestos allow-all por default-deny com fluxos legítimos documentados.

## ADDED Requirements

### Requirement: Prompt de geração parametrizável

O prompt principal SHALL aceitar:

- `manifesto_permissivo` — YAML barrado
- `regras_padrao` — requisitos Aegis (ingress Relay+gateway, egress Forge/Cerebro/DNS, comentários)
- `mapa_servicos` — namespaces, labels e portas

#### Scenario: Três parâmetros documentados

- **WHEN** template implementado
- **THEN** `prompt.md` declara `{{manifesto_permissivo}}`, `{{regras_padrao}}`, `{{mapa_servicos}}`

### Requirement: NetworkPolicy endurecida na saída esperada

Saída esperada (validação manual/CP08) SHALL ser YAML com `kind: NetworkPolicy`, `policyTypes` Ingress+Egress, sem regras `- {}`, ingress Relay (`app: relay`), egress portas 5432 e 9200, comentários `#` por regra.

#### Scenario: Sem allow-all

- **WHEN** operador executa prompt manualmente
- **THEN** output MUST NOT conter `- {}` em ingress ou egress

### Requirement: Prompt de verificação separado

SHALL existir `prompt-verificacao.md` que recebe NetworkPolicy candidata e aplica checklist de revisor de segurança (perguntas + gaps).

#### Scenario: Template de verificação

- **WHEN** implementação CP06 concluída
- **THEN** existe `prompt-verificacao.md` com placeholder para policy candidata

### Requirement: Entrega com inputs fixos e iterações manuais

O `entrega.md` SHALL incluir de `checkpoints-plataforma.md` (Checkpoint 06): **manifesto permissivo** barrado, **regras do padrão Aegis** e **mapa de serviços** (namespaces, labels, portas) — em seção **Inputs usados**. Seções v1, feedback verificação, v2 e v3 opcional permanecem para outputs do operador; MUST NOT ser preenchidas por automação.

#### Scenario: Inputs CP06 pré-preenchidos

- **WHEN** implementação CP06 concluída
- **THEN** `entrega.md` contém YAML sentinel-allow, regras default-deny e mapa Sentinel/Relay/Forge/Cerebro/DNS

#### Scenario: Iterações documentadas manualmente

- **WHEN** operador completa execução manual
- **THEN** entrega.md registra ciclo v1→verificação→v2 com outputs colados pelo operador

### Requirement: Armazenamento em prompts/ sem automação

MUST NOT executar prompts nem configurar API keys até CP06 concluído (convenção geral).

#### Scenario: Template CP06

- **WHEN** implementação apply concluída
- **THEN** pasta `prompts/cp6-networkpolicy-sentinel/` com templates only
