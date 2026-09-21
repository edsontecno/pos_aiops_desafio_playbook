---
nome: Migração Forge — Fase 1
descricao: Detalha runbook executável da primeira fase da migração batch→event-driven
versao: 1.0.0
tags: [forge, migração, runbook, fase-1, dados]
inputs:
  - nome: estado_forge
    descricao: Estado atual do pipeline Forge (ingestão, transformação, destino, dependentes)
  - nome: plano_anterior
    descricao: Saída completa do elo 2 (prompt-plano), incluindo destaque Fase 1
---

## Objetivo

Converter plano da Fase 1 em passos executáveis com dual-run, métricas e rollback — elo 3 (final).

## Casos de uso

- Iniciar consumo contínuo do Relay sem desligar batch
- Definir gatilhos de rollback testáveis
- Handoff documentado para Fase 2

## Exemplo de uso

**Entrada:** Output do prompt-plano + estado Forge de referência.

**Saída esperada:** Pré-requisitos, passos numerados, métricas, procedimento de rollback.

Referência completa de entradas fixas: `prompts/cp05-migracao-forge/entrega.md`.

## Limitações conhecidas

- Escopo restrito à Fase 1
- Não desliga batch sem dual-run validado
