---
nome: Migração Forge — Diagnóstico
descricao: Diagnostica estado batch atual do Forge e riscos antes da migração event-driven
versao: 1.0.0
tags: [forge, migração, batch, diagnóstico, dados]
inputs:
  - nome: estado_forge
    descricao: Estado atual do pipeline Forge (ingestão, transformação, destino, dependentes)
---

## Objetivo

Mapear gargalos, dependentes e riscos da arquitetura batch do Forge — elo 1 da cadeia de migração.

## Casos de uso

- Avaliar margem operacional do cron 60min vs 40min Spark
- Identificar efeito cascata por falha de lote
- Antecipar riscos batch→event-driven

## Exemplo de uso

**Entrada:** Estado Forge: cron 60min, 14 etapas Spark, dependentes Sentinel/Cerebro/billing.

**Saída esperada:** Resumo, componentes, dependentes, riscos batch e antecipados na migração.

Referência completa de entradas fixas: `prompts/cp05-migracao-forge/entrega.md`.

## Limitações conhecidas

- Diagnóstico apenas — não propõe plano de migração
- Declara premissas e limites dos dados
