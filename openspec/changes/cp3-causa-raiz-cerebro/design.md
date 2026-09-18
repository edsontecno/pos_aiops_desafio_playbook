## Context

CP03 — RCA no Cerebro. Convenções CP01–CP06: `prompts/`, templates only, execução manual, registry no CP07. Ground truth: reindexação travada → heap 8g → circuit breaker → buscas parciais.

## Goals / Non-Goals

**Goals:** Template RCA multi-artefato; artefatos CP03 colados em entrega.md; fixtures espelhando entrega; sanitização manual.

**Non-Goals:** Execução, LLM-as-judge (CP09), registry, promptfoo determinístico.

## Decisions

### 1. Parâmetro único `{{artefatos}}`

Bloco com três seções marcadas: Config, Métricas, Logs — alternativa a 3 placeholders separados.

### 2. Estrutura de saída sugerida no prompt

- Linha do tempo da degradação
- Causa-raiz (com evidências cruzadas)
- Efeitos colaterais (sintomas)
- Ação recomendada
- O que os dados não provam

### 3. Fixtures opcionais

`fixtures/cerebro-artefatos.yaml` ou `.md` com dados do enunciado — operador copia para teste manual.

### 4. Sanitização

Documentar em entrega.md: hostnames, nomes de índice, nós internos.

## Migration Plan

Commit: `feat(prompts): adiciona template CP03 causa-raiz cerebro`
