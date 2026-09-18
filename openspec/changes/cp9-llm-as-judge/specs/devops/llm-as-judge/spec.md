## Purpose

Avalia qualidade da saída de causa-raiz do Cerebro via LLM-as-judge no promptfoo, com rubrica calibrada e critério de aprovação explícito, complementando testes determinísticos do CP08.

## ADDED Requirements

### Requirement: Rubrica documentada com quatro critérios

SHALL existir `registry/docs/cp09-rubrica-causa-raiz.md` descrevendo exatamente:

1. **Causa-raiz correta** (0–2) — reindexação travada saturando heap → circuit breaker, não só sintomas
2. **Correlação × causa** (0–2) — cache hit baixo como efeito, não causa
3. **Ação proporcional** (0–2) — conter/reagendar reindex, revisar heap/limites
4. **Honestidade epistêmica** (0–2) — declarar limites dos dados

Escala 0–2 por critério, total 0–8.

#### Scenario: Rubrica completa no repositório

- **WHEN** CP09 implementado
- **THEN** documento lista os 4 critérios com escala e exemplos do enunciado

### Requirement: Critério de aprovação do gate

Aprovação SHALL exigir nota total ≥ 6 **e** nenhum critério com pontuação 0.

#### Scenario: Gate reprova nota baixa

- **WHEN** juiz atribui total 5 ou qualquer critério 0
- **THEN** assert do promptfoo falha (gate reprova)

### Requirement: promptfooconfig com LLM-as-judge

`registry/devops/causa-raiz-cerebro/promptfooconfig.yaml` SHALL:

- Referenciar `file://devops/causa-raiz-cerebro/prompt.md`
- Incluir teste com vars dos artefatos CP03 — **mesmo texto** de `checkpoints-plataforma.md` / `prompts/cp03-causa-raiz-cerebro/entrega.md`
- Usar `llm-rubric` ou `model-graded-closedqa` embarcando texto integral da rubrica
- Configurar threshold alinhado ao corte ≥ 6

#### Scenario: Config com juiz

- **WHEN** config inspecionado
- **THEN** asserts incluem tipo de grader LLM com rubrica de 4 critérios

### Requirement: Calibração documentada manualmente

SHALL existir `registry/docs/cp09-calibracao-juiz.md` com seções vazias para: pontuação humana de amostras, pontuação do juiz, delta por critério, ajustes no prompt do juiz até delta ≤ 1.

#### Scenario: Template de calibração

- **WHEN** CP09 apply concluído
- **THEN** template de calibração existe sem resultados preenchidos por automação

### Requirement: Integração na suíte eval

`run-all-evals.sh` SHALL incluir eval de `causa-raiz-cerebro/promptfooconfig.yaml` após os três configs determinísticos do CP08.

#### Scenario: Script atualizado

- **WHEN** operador roda `npm run eval` em registry/
- **THEN** causa-raiz-cerebro é executado junto com CP08 (quando operador invoca manualmente)

### Requirement: Sem execução automatizada no apply

Implementação MUST NOT executar juiz nem calibrar automaticamente.

#### Scenario: Apply só entrega configs e docs

- **WHEN** CP09 apply concluído
- **THEN** nenhuma saída de eval ou calibração foi gerada por automação
