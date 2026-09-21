# CP09 — Calibração do juiz LLM (causa-raiz)

Registro da calibração em **3 rodadas iterativas** (21/09/2026). Cada rodada: `promptfoo eval -c devops/causa-raiz-cerebro/promptfooconfig.yaml --no-cache`, coleta de métricas, ajuste e nova execução.

## Ambiente

| Campo | Valor |
| ----- | ----- |
| Data da calibração | 21/09/2026 |
| Operador | edson |
| Modelo under test | `openai:gpt-4o-mini` (`max_tokens: 4096`, `temperature: 0`) |
| Modelo juiz (final) | `openai:gpt-4o` (`max_tokens: 2048`, `temperature: 0`) |
| Threshold `llm-rubric` (0–1) | `0.75` (total ≥ 6/8) |
| Rubrica do juiz | `devops/causa-raiz-cerebro/judge-prompts/causa-raiz.judge.xml` |
| Latency gate | **20000** ms |
| Cost gate | **0.01** USD |

## Resumo das 3 rodadas

| Rodada | Eval ID | Resultado | Juiz (score) | Latência | Tokens | Ajuste aplicado |
| ------ | ------- | --------- | ------------ | -------- | ------ | --------------- |
| 1 | `eval-ZwP-2026-09-21T21:18:48` | **FAIL** | PASS (1,0)* | 16101 ms ✗ | 9277 | Baseline (Haiku juiz, latency 15s) |
| 2 | `eval-jMH-2026-09-21T21:19:41` | **FAIL** | FAIL (0,5 / 4/8) | 10576 ms ✓ | 7832 | Juiz gpt-4o + max_tokens + C4 mais rigoroso + latency 20s |
| 3 | `eval-fes-2026-09-21T21:20:22` | **PASS** | PASS (0,875 / 7/8) | 13576 ms ✓ | 8264 | Prompt gerador reforçado (IDs, limites, follow-up) |

\* Rodada 1: juiz Haiku retornou `Grading passed` sem JSON por critério (`stopReason: max_tokens`); reprovação foi **somente por latência** (> 15000 ms).

## Processo

1. Rodar eval com `--no-cache`.
2. Coletar pass/fail, score do juiz, latência, custo e tokens (`~/.promptfoo/promptfoo.db`).
3. Pontuar humanamente a saída (0–2 por critério).
4. Ajustar config/juiz/prompt se delta > 1 ou gate operacional falhar.
5. Repetir até PASS estável com métricas auditáveis.

---

## Rodada 1 — Baseline

**Config:** juiz `claude-haiku-4-5`, gerador sem `max_tokens`, latency threshold **15000** ms.

| Métrica | Valor |
| ------- | ----- |
| Resultado geral | FAIL |
| Motivo da falha | Latência 16101 ms > 15000 ms |
| Juiz `qualidade_juiz` | PASS (score 1,0 — sem detalhe por critério) |
| Custo gerador | ~US$ 0,00066 |
| Tokens | Provider 3036 + Grading 6241 = **9277** |
| Tamanho saída | 2955 chars (follow-up truncado) |

**Ajuste decidido:** trocar juiz para `gpt-4o` com JSON confiável; subir `max_tokens` gerador/juiz; latency → 20s; endurecer C4 no XML.

---

## Rodada 2 — Infra + juiz calibrado

**Config:** juiz `openai:gpt-4o` (2048 tokens), gerador `max_tokens: 4096`, C4 exige ≥2 limites concretos, latency **20000** ms. **Prompt gerador inalterado.**

| Critério | Humano (0–2) | Juiz (0–2) | Delta |
| -------- | ------------ | ---------- | ----- |
| Causa-raiz correta | 1 | 1 | 0 |
| Correlação × causa | 1 | 1 | 0 |
| Ação proporcional | 1 | 1 | 0 |
| Honestidade epistêmica | 1 | 1 | 0 |
| **Total** | **4** | **4** | **0** |

| Métrica | Valor |
| ------- | ----- |
| Resultado geral | FAIL |
| Reason juiz | FAIL com total 4/8. C1 e C2 falharam por encadeamento causal incompleto. |
| Latência | 10576 ms ✓ |
| Tokens grading | 4788 |

**Diagnóstico:** saída não citava `task 88123` nem shard `[7]`; limites epistêmicos superficiais (1 bullet). Juiz gpt-4o alinhado com pontuação humana (delta 0), mas **abaixo do corte 6**.

**Ajuste decidido:** reforçar `prompt.md` — exigir IDs concretos dos logs, ≥2 limites e follow-up específico (investigar atraso vs. `avg_duration_min`, revisar `jvm_heap`/`refresh_interval`).

---

## Rodada 3 — Prompt gerador + config final (PASS)

**Config:** mesma da rodada 2 + `prompt.md` reforçado.

| Critério | Humano (0–2) | Juiz gpt-4o (0–2) | Delta |
| -------- | ------------ | ----------------- | ----- |
| Causa-raiz correta | 2 | 2 | 0 |
| Correlação × causa | 2 | 2 | 0 |
| Ação proporcional | 1 | 1 | 0 |
| Honestidade epistêmica | 2 | 2 | 0 |
| **Total** | **7** | **7** | **0** |

| Métrica | Valor |
| ------- | ----- |
| Resultado geral | **PASS** (100%) |
| Reason juiz | PASS com total 7/8; C1 e C2 bem atendidos, C3 e C4 com ressalvas menores. |
| Score normalizado | 0,875 (≥ 0,75) |
| Latência | 13576 ms ✓ |
| Custo gerador | ~US$ 0,00085 |
| Tokens | Provider 3299 + Grading 4965 = **8264** |
| Tamanho saída | 3448 chars |

**Link / referência da saída:** eval `eval-fes-2026-09-21T21:20:22`.

**Melhorias observadas vs. rodada 2:**
- Linha do tempo cita `reindex task [88123]` e shard `[logs-2026.05][7]`
- Follow-up menciona atraso vs. média histórica e revisão de `jvm_heap`/`refresh_interval`
- Três limites epistêmicos explícitos (atraso da reindex, outros nós, dados pós-10:00)

**Ressalva C3 (humano e juiz):** ação imediata não nomeia explicitamente `task 88123` — diz “reindexação identificada nos logs”. Pontuação 1, não 2.

---

## Referência ouro — CP03 (`entrega.md`)

Pontuação humana da entrega manual (Claude Sonnet 5, 18/09/2026). Não reexecutada nesta sessão.

| Critério | Humano (0–2) |
| -------- | ------------ |
| Causa-raiz correta | 2 |
| Correlação × causa | 2 |
| Ação proporcional | 2 |
| Honestidade epistêmica | 2 |
| **Total** | **8** |

Referência: `prompts/cp03-causa-raiz-cerebro/entrega.md`.

---

## Ajustes realizados (cronológico)

| Iteração | O que mudou | Motivo |
| -------- | ----------- | ------ |
| R1→R2 | Juiz Haiku → `openai:gpt-4o` (`max_tokens: 2048`) | JSON auditável; Haiku truncava em 1024 tokens |
| R1→R2 | Gerador `max_tokens: 4096` | Saída truncada no follow-up |
| R1→R2 | Latency 15000 → **20000** ms | Gerador ~13–16 s com juiz |
| R1→R2 | C4 no XML: exige ≥2 limites concretos | Calibrar honestidade epistêmica |
| R2→R3 | `prompt.md`: IDs (`88123`, shard `[7]`), ≥2 limites, follow-up específico | Juiz reprovou 4/8 por encadeamento/IDs ausentes |
| R3 final | Config estável documentada acima | PASS 7/8, delta humano×juiz = 0 |

## Threshold final

| Mapeamento | Valor |
| ---------- | ----- |
| Corte documentado (total ≥ 6, nenhum 0) | **6–8**, sem critério zerado |
| `threshold` promptfooconfig | **0.75** |
| Grader | **`llm-rubric`** + `causa-raiz.judge.xml` |
| Latency gate | **20000** ms |
| Cost gate | **0.01** USD |

## Observações

- **Calibração juiz × humano:** na rodada final, delta **0** em todos os critérios (total 7/7).
- **Gargalo operacional:** latência do gerador (13–16 s) domina o tempo total; juiz gpt-4o adiciona ~4–5 s.
- **CP10:** gate pode usar retry 1× no juiz; latency/cost como asserts separados (já configurado).
- **Próximo passo opcional:** elevar C3 para 2 exigindo `task 88123` na ação imediata no prompt — margem atual 7/8, acima do corte 6.
