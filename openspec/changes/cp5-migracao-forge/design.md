## Context

CP05 — prompt chaining para migração Forge. Convenções CP01–CP06.

## Goals / Non-Goals

**Goals:** 3 templates encadeados; fixture de cenário; entrega.md estruturada por elo.

**Non-Goals:** Executar cadeia, registry, monolito.

## Decisions

### 1. Layout

```
prompts/cp05-migracao-forge/
  prompt-diagnostico.md    {{estado_forge}}
  prompt-plano.md          {{estado_forge}} + {{diagnostico_anterior}}
  prompt-fase-1.md         {{plano_anterior}} + {{estado_forge}}
  entrega.md
  fixtures/forge-cenario.yaml   (opcional)
```

### 2. Nomes alinhados ao registry futuro (CP07)

Slugs previstos: `migracao-forge-diagnostico`, `migracao-forge-plano`, `migracao-forge-fase-1`.

### 3. README inline no entrega.md

Documentar ordem de uso da cadeia: 1→2→3 manualmente.

## Migration Plan

Commit: `feat(prompts): adiciona template CP05 migracao forge (cadeia)`
