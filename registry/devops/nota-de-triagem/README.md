---
nome: Nota de triagem
descricao: Converte alerta cru em nota padronizada de handoff entre plantonistas
versao: 1.0.0
tags: [sre, alerta, triagem, handoff, aegis]
inputs:
  - nome: alerta_cru
    descricao: Texto bruto do alerta (timestamp, sistema, métricas, tenant)
---

## Objetivo

Padronizar alertas brutos do Sentinel/Relay/Forge em nota de triagem concisa (≤8 linhas) para passagem de turno.

## Casos de uso

- Autoscaler no limite com fila crescendo
- Taxa de rejeição elevada após deploy
- Consumer lag crescente com impacto downstream

## Exemplo de uso

**Entrada:** Alerta UTC com sistema, métricas e tenant (ex.: autoscaler 60/60, fila Relay +2k/min).

**Saída esperada:** Cinco linhas: ALERTA, IMPACTO, HIPÓTESE INICIAL, AÇÃO IMEDIATA, ESCALAR PARA.

Referência completa de entradas fixas: `prompts/cp02-nota-de-triagem/entrega.md`.

## Limitações conhecidas

- Nota MUST NOT exceder 8 linhas incluindo rótulos
- Exatamente cinco rótulos na ordem fixa
- ESCALAR PARA exige handle @time-ou-canal
