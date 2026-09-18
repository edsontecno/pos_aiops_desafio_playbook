## Context

Ver `proposal.md` — primeiro item do playbook Aegis. Template prompt-registry em `registry/` aguarda CP07. Operador executará prompts manualmente e preencherá `entrega.md` por conta própria. Sem API keys no repo até conclusão do CP06.

## Goals / Non-Goals

**Goals:**

- Publicar template do prompt em `prompts/cp01-triagem-de-pods/prompt.md`
- Publicar `entrega.md` com snapshots CP01 já colados; outputs e curadoria manual
- Definir comportamento esperado do prompt na spec (para validação manual futura)
- Estabelecer convenção CP02–CP06: templates em `prompts/`, execução manual, sem API key no repo

**Non-Goals:**

- Executar prompt ou gerar outputs de modelo
- Configurar API keys, `.env` ou secrets (até CP06 concluído)
- Preencher curadoria ou execuções
- Publicar em `registry/` (CP07)
- promptfoo (CP08) ou CI (CP10)

## Decisions

### 1. Localização: `prompts/cp01-triagem-de-pods/` (não registry)

Workspace de rascunho CP01–CP06; migração para `registry/devops/` no CP07.

### 2. Layout interno — template only

```
prompts/cp01-triagem-de-pods/
  prompt.md       # prompt parametrizável ({{snapshot_cluster}}) — artefato principal
  entrega.md      # snapshots fixos (enunciado) + outputs/curadoria manual
```

**Rationale:** Snapshots vêm do enunciado (`checkpoints-plataforma.md`) — já em `entrega.md` para copiar/colar no playground. Operador só preenche modelo, outputs e curadoria.

### 3. Execução manual, fora do apply

**Escolha:** Nenhuma tarefa de apply invoca LLM. Snapshots de teste são **copiados integralmente** de `checkpoints-plataforma.md` para `entrega.md` (fonte única de verdade para CP08 vars).

**Alternativa descartada:** Agente executa nos 3 snapshots e preenche outputs.

### 4. API keys adiadas até após CP06

**Escolha:** CP01–CP06 não adicionam secrets, `.env.example` com keys, nem configs promptfoo. Primeira configuração de provedor no repo: CP07 (migração) ou CP08 (promptfoo eval).

### 5. Parâmetro único: `{{snapshot_cluster}}`

Um placeholder com get + describe + logs colados.

### 6. Estrutura do prompt: Role + constraints + output fixo

- Role: SRE plantonista Aegis
- Constraints: não inventar dados; restart antigo ≠ problemático
- Output: Resumo → Pods problemáticos (Evidências) → Considerações finais

### 7. Criação via meta-prompting (apply)

Apply pode usar meta-prompting para **redigir** o template `prompt.md`, mas MUST NOT executar o prompt resultante contra snapshots.

## Risks / Trade-offs

| Risco | Mitigação |
|-------|-----------|
| Template sem validação real | Operador preenche `entrega.md` manualmente; CP08 testa via promptfoo |
| entrega.md esquecido | Template com seções explícitas e placeholders `[preencher]` |
| Confusão spec vs entrega | Spec descreve comportamento esperado; template é o artefato versionado |

## Migration Plan

**CP01 (este change):**

1. Criar `prompts/cp01-triagem-de-pods/prompt.md`
2. Criar `prompts/cp01-triagem-de-pods/entrega.md` (snapshots CP01 colados + placeholders output/curadoria)
3. Commit: `feat(prompts): adiciona template CP01 triagem de pods`

**Operador (manual, anytime):**

1. Executar prompt nos 3 snapshots do enunciado
2. Preencher `entrega.md` com modelo, outputs e curadoria

**CP07+:** migrar templates para `registry/`; CP08+: API keys e promptfoo.

## Open Questions

- CP05 cadeia: layout de múltiplos `prompt.md` — definir no CP05.
- Incluir snapshots em `prompts/cp01-triagem-de-pods/fixtures/` — opcional; operador pode copiar do enunciado.
