# CP09 — Rubrica de causa-raiz (Cerebro)

Avaliação da saída do prompt `causa-raiz-cerebro` via LLM-as-judge. Fonte de verdade para o gate em `devops/causa-raiz-cerebro/promptfooconfig.yaml`.

## Escala

Cada critério recebe **0, 1 ou 2**:

| Pontuação | Significado |
| --------- | ----------- |
| 0         | Não atende  |
| 1         | Parcial     |
| 2         | Atende      |

**Total:** 0–8 (soma dos quatro critérios).

## Critérios

### 1. Causa-raiz correta (0–2)

Aponta a **causa real** — a reindexação travada saturando o heap, levando a circuit breaker, timeouts de busca e queda do cache — e **não apenas os sintomas** (latência alta, cache hit baixo, filas cheias isoladas).

**Exemplo que atende (2):** identifica reindex task 88123 prolongada além da janela esperada (~90 min / ~03:30) como origem da pressão de heap e encadeamento até circuit breaker.

**Exemplo que não atende (0):** lista apenas "latência alta" ou "cache hit caindo" como causa sem encadeamento causal.

### 2. Correlação × causa (0–2)

Separa o que é **causa** do que é **consequência** — por exemplo, cache hit caindo é **efeito** da disputa por memória, não causa independente.

**Exemplo que atende (2):** seção de efeitos colaterais trata queda de cache hit, GC prolongado e filas saturadas como consequências da reindexação/heap.

**Exemplo que não atende (0):** trata queda de cache hit ou timeouts como causas independentes sem vínculo com reindexação/heap.

### 3. Ação proporcional (0–2)

Propõe ação **coerente** com o diagnóstico — conter ou reagendar a reindexação, revisar heap/limites — sem sobre- nem subdimensionar.

**Exemplo que atende (2):** pausar/cancelar reindex task 88123 como mitigação imediata; follow-up para investigar por que a reindexação estagnou e revisar `jvm_heap` / `refresh_interval`.

**Exemplo que não atende (0):** playbook genérico (ex.: "reiniciar cluster") desconectado dos artefatos, ou apenas monitorar sem ação imediata diante de circuit breaker rompido.

### 4. Honestidade epistêmica (0–2)

Reconhece o que os dados **não permitem** concluir, em vez de fabricar certeza.

**Exemplo que atende (2):** declara que os artefatos não explicam por que a reindexação ficou tão mais lenta que a média histórica; não afirma causa do atraso sem evidência.

**Exemplo que não atende (0):** afirma com certeza a causa do atraso da reindexação ou generaliza para todo o cluster sem ressalvas.

## Critério de aprovação (gate)

A saída **aprovada** exige **simultaneamente**:

1. **Nota total ≥ 6** (de 8)
2. **Nenhum critério com pontuação 0**

Reprova quando total &lt; 6 **ou** qualquer critério zerado.

## Referência

Enunciado: `checkpoints-plataforma.md` (Checkpoint 09). Artefatos de teste: `prompts/cp03-causa-raiz-cerebro/entrega.md`.
