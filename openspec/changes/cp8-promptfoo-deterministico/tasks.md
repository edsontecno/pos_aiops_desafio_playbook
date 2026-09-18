## 1. Tooling promptfoo

- [ ] 1.1 Criar `registry/package.json` com dependência promptfoo e scripts eval por prompt + `eval` (run-all)
- [ ] 1.2 Criar `registry/scripts/run-all-evals.sh` executando os 3 configs em sequência
- [ ] 1.3 Criar `registry/.env.example` com OPENAI_API_KEY e ANTHROPIC_API_KEY (sem valores reais)

## 2. promptfooconfig.yaml — nota-de-triagem

- [ ] 2.1 Criar `registry/devops/nota-de-triagem/promptfooconfig.yaml` com 2 providers, 3 alertas CP02, asserts 5 rótulos + regex @ + ≤8 linhas + latency + cost

## 3. promptfooconfig.yaml — triagem-de-pods

- [ ] 3.1 Criar `registry/devops/triagem-de-pods/promptfooconfig.yaml` com 2 providers, 3 snapshots CP01, asserts específicos por entrada + latency + cost

## 4. promptfooconfig.yaml — networkpolicy-sentinel

- [ ] 4.1 Criar `registry/devops/networkpolicy-sentinel/promptfooconfig.yaml` com vars CP06, asserts YAML/ports/Relay/not `- {}`/comentários + latency + cost

## 5. Documentação e entrega manual

- [ ] 5.1 Criar `registry/docs/cp08-eval-resultados.md` template vazio (pass/fail por prompt, curadoria, ajustes)
- [ ] 5.2 Confirmar CP03–CP05 sem promptfooconfig; não executar eval no apply

## 6. Finalização

- [ ] 6.1 Commit `feat(devops): adiciona testes promptfoo CP08`
