## 1. Documentação da rubrica

- [ ] 1.1 Criar `registry/docs/cp09-rubrica-causa-raiz.md` com 4 critérios (0–2), total 0–8, corte ≥6 sem critério zerado, exemplos do enunciado

## 2. promptfooconfig LLM-as-judge

- [ ] 2.1 Criar `registry/devops/causa-raiz-cerebro/promptfooconfig.yaml` com provider, vars artefatos CP03, assert `llm-rubric` (ou closedqa) embarcando rubrica
- [ ] 2.2 (Opcional) Incluir asserts latency ≤5s e cost ≤0.01 no mesmo test

## 3. Calibração e suíte

- [ ] 3.1 Criar `registry/docs/cp09-calibracao-juiz.md` template vazio (humano vs juiz, ajustes, threshold final)
- [ ] 3.2 Atualizar `registry/scripts/run-all-evals.sh` e `package.json` para incluir eval causa-raiz-cerebro

## 4. Finalização

- [ ] 4.1 Confirmar que apply não executou eval/calibração
- [ ] 4.2 Commit `feat(devops): adiciona LLM-as-judge CP09 causa-raiz`
