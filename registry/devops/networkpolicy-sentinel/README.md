---
nome: NetworkPolicy Sentinel
descricao: Gera NetworkPolicy endurecida default-deny para sentinel-prod
versao: 1.0.0
tags: [kubernetes, networkpolicy, segurança, sentinel, aegis]
inputs:
  - nome: manifesto_permissivo
    descricao: YAML da NetworkPolicy permissiva (allow-all) barrada
  - nome: mapa_servicos
    descricao: Namespaces, labels e portas dos serviços do cluster
  - nome: regras_padrao
    descricao: Requisitos Aegis para sentinel-prod (ingress, egress, default-deny)
---

## Objetivo

Substituir manifesto allow-all por NetworkPolicy default-deny alinhada ao padrão Aegis.

## Casos de uso

- Endurecer policy barrada em revisão de segurança
- Liberar apenas Relay, API gateway, Forge, Cerebro e DNS

## Exemplo de uso

**Entrada:** Manifesto permissivo + regras Aegis + mapa de serviços (`prompts/cp6-networkpolicy-sentinel/entrega.md`).

**Saída esperada:** YAML NetworkPolicy com comentários por fluxo legítimo.

Referência completa de entradas fixas: `prompts/cp6-networkpolicy-sentinel/entrega.md`.

## Limitações conhecidas

- Saída somente YAML — sem explicações fora de comentários #
- Sem `- {}` em ingress ou egress
- Labels/namespaces exatos do mapa de serviços
