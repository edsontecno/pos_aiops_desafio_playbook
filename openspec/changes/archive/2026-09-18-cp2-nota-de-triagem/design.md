## Context

Ver `proposal.md` — segundo item do playbook Aegis. Segue convenções estabelecidas no change `cp1-triagem-pods`: templates em `prompts/`, execução manual, sem API keys até CP06, registry no CP07.

Armadilha do enunciado: duas listas de exemplos — **formato de saída** (notas prontas Relay/Forge/Cerebro) vs **entradas de teste** (3 alertas crus Sentinel/Relay/Forge). O template MUST tratar isso explicitamente.

## Goals / Non-Goals

**Goals:**

- Template `prompts/cp02-nota-de-triagem/prompt.md` com `{{alerta_cru}}`
- Saída especificada: 5 rótulos, handle `@`, máx. 8 linhas
- `entrega.md` com alertas crus colados + **Justificativa do método** concisa (1 frase, máx. 3 linhas, sugerida pelo apply)
- Referência de formato embutida no prompt (few-shot de formato) OU via instrução estrutural — decisão documentada na curadoria manual

**Non-Goals:**

- Executar nos 3 alertas crus
- Preencher curadoria ou outputs
- `registry/`, promptfoo (CP08), API keys

## Decisions

### 1. Localização: `prompts/cp02-nota-de-triagem/`

Mesma convenção CP01.

### 2. Layout

```
prompts/cp02-nota-de-triagem/
  prompt.md       # parametrizável + referência de formato (inline ou comentada)
  entrega.md      # 3 alertas crus colados + Modelo/Output manual + Justificativa do método sugerida
```

### 3. Parâmetro: `{{alerta_cru}}`

Texto livre do alerta disparado (timestamp, sistema, métricas, tenant).

### 4. Ensino do formato ao modelo (escolha registrada no template, justificada manualmente)

**Opção recomendada no template (apply):** **Zero-shot estrutural** — listar os 5 rótulos com descrição de cada campo + exemplo de nota pronta como referência (bloco estático no prompt, não confundido com `{{alerta_cru}}`).

**Alternativas para o operador documentar em entrega.md:**

| Método | Prós | Contras |
|--------|------|---------|
| Zero-shot + template explícito | Conciso, barato em tokens | Pode omitir rótulo |
| Few-shot (1 nota exemplo) | Formato muito estável | Mistura risco se mal separado |
| Role + constraints | Tom operacional consistente | Precisa reforçar rótulos |

**Rationale:** Enunciado pede justificativa de método — apply pré-preenche uma frase curta (máx. 3 linhas) em `entrega.md`; operador ajusta se necessário após execução.

### 5. Conteúdo inferido do alerta

Cada campo MUST ser derivado do alerta cru:

- **ALERTA:** resumo do que disparou (sistema + condição)
- **IMPACTO:** quem/o quê é afetado (tenants, downstream)
- **HIPÓTESE INICIAL:** causa provável mencionada ou inferida
- **AÇÃO IMEDIATA:** ação concreta sugerida
- **ESCALAR PARA:** `@time` + condição temporal de escalação

### 6. Referência de formato no prompt (estático)

Incluir bloco comentado ou seção "Exemplo de formato (referência — não é entrada)":

```
ALERTA: ...
IMPACTO: ...
...
```

Separado visualmente de `{{alerta_cru}}`.

## Risks / Trade-offs

| Risco | Mitigação |
|-------|-----------|
| Confundir exemplos formato vs entrada | Seções distintas no prompt; comentário explícito |
| Nota > 8 linhas | Instrução "máximo 8 linhas"; CP08 assert |
| Handle `@` ausente | Instrução explícita em ESCALAR PARA |
| Inventar tenant/sistema não no alerta | Constraint: usar só dados do alerta cru |

## Migration Plan

**CP02 (este change):**

1. Criar `prompts/cp02-nota-de-triagem/prompt.md`
2. Criar `prompts/cp02-nota-de-triagem/entrega.md` (3 alertas crus colados + justificativa do método sugerida + placeholders output/curadoria)
3. Commit: `feat(prompts): adiciona template CP02 nota de triagem`

**Operador (manual):** executar com alertas já em entrega.md; preencher outputs e curadoria.

**CP07:** migrar para `registry/devops/nota-de-triagem/`. **CP08:** promptfooconfig com asserts de formato.

## Open Questions

- Operador pode discordar da sugestão de método e documentar escolha alternativa na curadoria.
