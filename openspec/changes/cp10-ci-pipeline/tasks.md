## 1. Smoke configs (prompts abertos)

- [ ] 1.1 Criar `promptfooconfig.yaml` smoke em backpressure-relay, migracao-forge-diagnostico, migracao-forge-plano, migracao-forge-fase-1, networkpolicy-sentinel-verificacao (vars CP04–06, assert não-vazio + latency + cost)
- [ ] 1.2 Atualizar `run-all-evals.sh` para os 9 configs

## 2. GitHub Actions

- [ ] 2.1 Criar `.github/workflows/prompt-eval.yml` (PR + push, cwd registry/, secrets, promptfoo action ou npm run eval)
- [ ] 2.2 Implementar gate: determinísticos + juiz blocking; smoke non-blocking (conforme estrategia)

## 3. Documentação

- [ ] 3.1 Criar `registry/docs/estrategia-gate-ci.md` com 4 decisões × ≥2 alternativas (gate, escopo, juiz, secrets/custo)
- [ ] 3.2 Criar `registry/docs/cp10-ci-evidencias.md` template vazio (sucesso + falha provocada)
- [ ] 3.3 Atualizar `registry/README.md` com instruções de secrets GitHub e como rodar CI localmente

## 4. Finalização

- [ ] 4.1 Confirmar apply não executou workflow nem commitou secrets
- [ ] 4.2 Commit `feat(devops): adiciona pipeline CI CP10`
