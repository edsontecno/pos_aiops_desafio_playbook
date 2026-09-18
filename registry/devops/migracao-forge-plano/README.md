---
nome: Migração Forge — Plano
descricao: Elabora plano incremental batch→event-driven com fases reversíveis
versao: 1.0.0
tags: [forge, migração, event-driven, plano, dados]
inputs:
  - nome: estado_forge
    descricao: Estado atual do pipeline Forge (ingestão, transformação, destino, dependentes)
  - nome: diagnostico_anterior
    descricao: Saída completa do elo 1 (prompt-diagnostico)
---

## Objetivo

Propor plano anti big-bang em fases reversíveis — elo 2 da cadeia, consumindo diagnóstico do elo 1.

## Casos de uso

- Definir fases com critério de sucesso e rollback
- Proteger Sentinel, Cerebro e billing durante transição
- Destacar escopo da Fase 1 para o elo 3

## Exemplo de uso

**Entrada:** Estado Forge + output completo do prompt-diagnostico.

**Saída esperada:** Objetivo, fases numeradas, ordem de execução, destaque Fase 1.

Referência completa de entradas fixas: `prompts/cp05-migracao-forge/entrega.md`.

## Limitações conhecidas

- Não detalha passos executáveis da Fase 1
- Sem big-bang ou janela única de corte
