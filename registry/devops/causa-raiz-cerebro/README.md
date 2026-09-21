---
nome: Causa-raiz Cerebro
descricao: Diagnostica degradação no Elasticsearch correlacionando config, métricas e logs
versao: 1.0.0
tags: [elasticsearch, cerebro, causa-raiz, sre, incidente]
inputs:
  - nome: artefatos
    descricao: Pacote config + métricas + logs correlacionados do Cerebro
---

## Objetivo

Identificar causa-raiz provável de degradação no Cerebro cruzando configuração, métricas temporais e logs.

## Casos de uso

- Reindexação prolongada pressionando heap
- Circuit breaker e filas cheias com buscas lentas
- Queda de cache hit como sintoma downstream

## Exemplo de uso

**Entrada:** Pacote config + métricas 08:00–10:00 UTC + logs cerebro-node-3 (`prompts/cp03-causa-raiz-cerebro/entrega.md`).

**Saída esperada:** Resumo executivo, linha do tempo, causa-raiz com evidências cruzadas, ação recomendada.

Referência completa de entradas fixas: `prompts/cp03-causa-raiz-cerebro/entrega.md`.

## Limitações conhecidas

- Separa causa-raiz de efeitos colaterais
- Declara explicitamente limites dos dados
- Não reproduz artefatos inteiros na resposta
