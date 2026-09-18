## Context

CP04 — decisão de backpressure. Saída aberta. Convenções CP01–CP06.

## Goals / Non-Goals

**Goals:** Template que força comparação multi-caminho + recomendação fundamentada.

**Non-Goals:** Execução, registry, promptfoo determinístico.

## Decisions

### 1. Parâmetro `{{cenario}}`

Texto livre: capacidade Relay + restrições + contexto orçamentário.

### 2. Estrutura de saída no prompt

1. Restrições resumidas
2. Opções consideradas (tabela ou bullets: prós/contras/custo/risco)
3. Recomendação (simples ou combinada)
4. Riscos residuais e próximos passos

### 3. Opções do enunciado como guia, não lista fechada

Prompt menciona caminhos possíveis mas permite combinação.

## Migration Plan

Commit: `feat(prompts): adiciona template CP04 backpressure relay`
