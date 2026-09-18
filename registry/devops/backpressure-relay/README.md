---
nome: Backpressure Relay
descricao: Compara estratégias de backpressure no Relay respeitando SLAs e zero perda
versao: 1.0.0
tags: [relay, backpressure, mensageria, sla, aegis]
inputs:
  - nome: cenario
    descricao: Estado do Relay e restrições de SLA/orçamento
---

## Objetivo

Recomendar estratégia de backpressure comparando opções com trade-offs explícitos para SLAs Sentinel/Forge.

## Casos de uso

- Pico 320k msgs/s acima da capacidade sustentada
- Orçamento já 8% acima com zero perda exigida
- Priorização entre alerting (≤60s) e ingestão (≤15min)

## Exemplo de uso

**Entrada:** Throughput, pico, retenção, consumidores e restrições de SLA (`prompts/cp04-backpressure-relay/entrega.md`).

**Saída esperada:** Restrições, opções consideradas, recomendação justificada, riscos residuais.

Referência completa de entradas fixas: `prompts/cp04-backpressure-relay/entrega.md`.

## Limitações conhecidas

- Mínimo duas estratégias comparadas antes da recomendação
- Descarte de telemetry é inaceitável
- Não ignora restrição orçamentária
