## Context

CP07 — biblioteca vira código. Template prompt-registry já em `registry/`. Prompts rascunho em `prompts/cp01-*` … `cp06-*` após apply dos changes CP1–CP6. Layout: `registry/` como subpasta do repo (paths promptfoo futuros: `registry/devops/...`).

## Goals / Non-Goals

**Goals:**

- Migrar 9 prompts para `registry/devops/`
- Frontmatter v1.0.0, índices, `docs/mapeamento-playbook.md`
- `triagem-de-pods` como exemplo canônico completo
- Preservar corpo dos prompts de `prompts/` (placeholders intactos)

**Non-Goals:**

- Executar prompts ou preencher execuções do `entrega.md`
- promptfoo (CP08), GitHub Actions (CP10), API keys
- Remover pasta `prompts/` (mantém histórico)

## Decisions

### 1. registry/ na raiz do repo (subpasta)

**Escolha:** Catálogo em `registry/` separado de `prompts/` e `checkpoints-plataforma.md`.

**Rationale:** Repo do desafio agrega enunciado + rascunhos + biblioteca. CP08 usará paths `file://registry/devops/.../prompt.md`.

### 2. Conteúdo README derivado de entrega.md

**Escolha:** README humano baseado em objetivo/limitações; seção "Exemplo" usa **entradas** já presentes em `entrega.md` (snapshots/alertas/artefatos de `checkpoints-plataforma.md`); output de exemplo placeholder até operador preencher.

**Alternativa:** Copiar outputs de entrega.md quando operador completar execução manual.

**Rationale:** Entradas fixas no enunciado; migração CP7 preserva coerência entre entrega.md e exemplos no README.

### 3. Migração CP05 — três slugs separados

Cadeia vira três pastas independentes (não subpasta aninhada), alinhado ao template "um prompt por pasta".

### 4. CP06 — dois prompts

`networkpolicy-sentinel` (geração) e `networkpolicy-sentinel-verificacao` (checklist revisor).

### 5. Commits semânticos por lote ou por prompt

```
feat(devops): migra prompts CP01-CP06 para registry
```

Ou commits individuais: `feat(devops): adiciona prompt triagem-de-pods` — preferir um commit de migração + doc no apply.

### 6. mapeamento-playbook.md

Seções: visão geral, tabela CP→slug, relação `prompts/` vs `registry/`, convenção de versão, próximos passos (CP08).

## Risks / Trade-offs

| Risco | Mitigação |
|-------|-----------|
| CP1–6 não aplicados | Documentar pré-requisito; apply CP7 falha checklist se `prompts/` vazio |
| Frontmatter divergente | Gerar inputs a partir de regex `{{...}}` no corpo |
| README genérico demais | triagem-de-pods como referência rica; revisar demais |

## Migration Plan

1. Verificar `prompts/cp01-*` … `cp06-*` existem
2. Para cada slug: copiar corpo → `prompt.md` + frontmatter; escrever README
3. Atualizar índices registry
4. Criar `registry/docs/mapeamento-playbook.md`
5. Commit: `feat(devops): migra playbook CP01-CP06 para registry`

## Open Questions

- Link GitHub público — operador fornece na entrega final do curso, não bloqueia estrutura local.
