## Context

CP06 — NetworkPolicy + verificação iterativa. CP08 assert determinístico no prompt principal. Convenções CP01–CP06.

## Goals / Non-Goals

**Goals:** 2 templates (gerar + verificar); entrega.md com inputs CP06 colados + ciclo de iterações manual; fixture espelhando entrega.

**Non-Goals:** Executar iterações, preencher v1/v2, registry.

## Decisions

### 1. Layout

```
prompts/cp6-networkpolicy-sentinel/
  prompt.md                 # geração
  prompt-verificacao.md     # checklist revisor
  entrega.md                # Iterações v1→v2
  fixtures/networkpolicy-cenario.yaml
```

### 2. Parâmetros do prompt principal

Três placeholders separados (manifesto, regras, mapa) — clareza vs bundle único.

### 3. prompt-verificacao.md

Parâmetro `{{networkpolicy_candidata}}` + checklist estático (allow-all, portas, labels, comentários, default-deny).

### 4. entrega.md — seção Iterações

```markdown
## v1
[preencher YAML]

## Verificação
[preencher feedback do prompt-verificacao]

## v2
[preencher YAML corrigido]
```

## Migration Plan

Commit: `feat(prompts): adiciona template CP06 networkpolicy sentinel`

CP07: `networkpolicy-sentinel/` + `networkpolicy-sentinel-verificacao/` no registry.
