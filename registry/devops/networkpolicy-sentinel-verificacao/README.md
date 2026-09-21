---
nome: NetworkPolicy Sentinel — Verificação
descricao: Revisa NetworkPolicy candidata com checklist de segurança Kubernetes
versao: 1.0.0
tags: [kubernetes, networkpolicy, revisão, segurança, sentinel]
inputs:
  - nome: networkpolicy_candidata
    descricao: YAML da NetworkPolicy gerada para revisão
---

## Objetivo

Aplicar checklist de revisor (Natasha) antes de aprovar policy para produção.

## Casos de uso

- Validar v1/v2/v3 de policy gerada
- Identificar gaps críticos FAIL vs ressalvas WARN

## Exemplo de uso

**Entrada:** YAML da NetworkPolicy gerada (v1, v2, etc.).

**Saída esperada:** Veredito, checklist tabular, gaps, sugestões de correção.

Referência completa de entradas fixas: `prompts/cp6-networkpolicy-sentinel/entrega.md`.

## Limitações conhecidas

- Não gera YAML corrigido completo
- Cita evidências específicas do YAML candidato
