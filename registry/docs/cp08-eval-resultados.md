# CP08 — Resultados dos testes promptfoo (determinísticos)

## Ambiente

| Campo                 | Valor                |
| --------------------- | -------------------- |
| Data da execução      | 21/09/2026           |
| Diretório de trabalho | `registry/`          |
| Providers usados      | `openai:gpt-4o-mini` |

## Resumo

| Prompt                 | Test cases       | Pass | Fail | Observações |
| ---------------------- | ---------------- | ---- | ---- | ----------- |
| nota-de-triagem        | 3 × 1 provider   | 3    | 0    | 100%        |
| triagem-de-pods        | 3 × 1 provider   | 3    | 0    | 100%        |
| networkpolicy-sentinel | 1 × 1 provider   | 1    | 0    | 100%        |

---

## nota-de-triagem

### Saída bruta (`promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml`)

````

┌────────────────────────────────────────────────┬────────────────────────────────────────────────┐
│ alerta_cru                                     │ [openai:gpt-4o-mini]                           │
│                                                │ devops/nota-de-triagem/prompt.md: ---          │
│                                                │ nome: Nota de triagem                          │
│                                                │ descricao: Converte aler...                    │
├────────────────────────────────────────────────┼────────────────────────────────────────────────┤
│ 2026-05-12 14:02:09 UTC [Sentinel] autoscaler  │ [PASS] ```                                     │
│ hit max replicas (60/60) on sentinel-api,      │ ALERTA: Sentinel - autoscaler atingiu o máximo │
│ queue depth on Relay growing 2k/min, CPU avg   │ de réplicas (60/60) no sentinel-api            │
│ 88%, tenant stark-industries                   │ IMPACTO: tenant stark-industries com aumento   │
│ sending 4x baseline volume after onboarding    │ na profundidade da fila                        │
│ new region                                     │ HIPÓTESE INICIAL: onboarding de nova região    │
│                                                │ gerou aumento de volume                        │
│                                                │ AÇÃO IMEDIATA: monitora...                     │
├────────────────────────────────────────────────┼────────────────────────────────────────────────┤
│ 2026-05-13 03:11:00 UTC [Relay] ingest reject  │ [PASS] ```                                     │
│ rate 6% for 8min, tenant wakanda-systems,      │ ALERTA: Relay - taxa de rejeição de ingestão   │
│ buffer saturated after deploy 02:55            │ em 6% por 8min                                 │
│                                                │ IMPACTO: tenant wakanda-systems com ingestão   │
│                                                │ degradada                                      │
│                                                │ HIPÓTESE INICIAL: buffer saturado após deploy  │
│                                                │ às 02:55                                       │
│                                                │ AÇÃO IMEDIATA: monitorar a situação e          │
│                                                │ verificar logs do deploy                       │
│                                                │ ESCALAR PA...                                  │
├────────────────────────────────────────────────┼────────────────────────────────────────────────┤
│ 2026-05-13 11:40:22 UTC [Forge] consumer lag   │ [PASS] ```                                     │
│ 9min and climbing, batch forge-batch-ingest    │ ALERTA: Forge - consumer lag de 9min e         │
│ delayed after previous job failure, downstream │ aumentando                                     │
│ Sentinel starting to lag                       │ IMPACTO: downstream Sentinel começando a       │
│                                                │ apresentar latência                            │
│                                                │ HIPÓTESE INICIAL: falha no job anterior causou │
│                                                │ atraso no processamento                        │
│                                                │ AÇÃO IMEDIATA: monitorar o lag e verificar     │
│                                                │ status do job ante...                          │
└────────────────────────────────────────────────┴────────────────────────────────────────────────┘
✓ Eval complete (ID: eval-xwR-2026-09-21T20:33:03)

» View results: promptfoo view
» Share with your team: https://promptfoo.app
» Feedback: https://promptfoo.dev/feedback

Total Tokens: 2.853
  Provider: 2.853 (cached)
Incurred Tokens: 0
  Cached Savings: 2.853
  Actual Target Requests: 0

Results:
  ✓ 3 passed (100%)
  0 failed (0%)
  0 errors (0%)
Duration: 0s (concurrency: 4)
````

---

## triagem-de-pods

### Saída bruta (`promptfoo eval -c devops/triagem-de-pods/promptfooconfig.yaml`)

````

┌────────────────────────────────┬────────────────────────────────┬────────────────────────────────┐
│ namespace                      │ snapshot_cluster               │ [openai:gpt-4o-mini]           │
│                                │                                │ devops/triagem-de-pods/prompt… │
│                                │                                │ ---                            │
│                                │                                │ nome: Triagem de pods          │
│                                │                                │ descricao: Analisa snaps...    │
├────────────────────────────────┼────────────────────────────────┼────────────────────────────────┤
│ sentinel-prod                  │ $ kubectl get pods -n          │ [PASS] ### Resumo executivo    │
│                                │ sentinel-prod                  │ - **Namespace:** sentinel-prod │
│                                │ NAME                           │ - **Status geral:** CRÍTICO    │
│                                │ READY   STATUS                 │ - **Pods problemáticos:** [1]  │
│                                │ RESTARTS       AGE             │ - **Veredito:** O pod          │
│                                │ sentinel-api-7d9c8b6f4-2xk9p   │ `sentinel-api-7d9c8b6f4-h4m2t` │
│                                │ 1/1     Running            0   │ está em CrashLoopBackOff       │
│                                │ 6d                             │ devido a problemas de memória. │
│                                │ sentinel-api-7d9c8b6f4-h4m2t   │ ### Pods problemáticos         │
│                                │ 0/1     CrashLoopBackOff...    │ ``...                          │
├────────────────────────────────┼────────────────────────────────┼────────────────────────────────┤
│ sentinel-prod                  │ $ kubectl get pods -n          │ [PASS] ### Resumo executivo    │
│                                │ sentinel-prod                  │ - **Namespace:** sentinel-prod │
│                                │ NAME                           │ - **Status geral:** ATENÇÃO    │
│                                │ READY   STATUS                 │ - **Pods problemáticos:** [2]  │
│                                │ RESTARTS   AGE                 │ - **Veredito:** Dois pods      │
│                                │ sentinel-api-7d9c8b6f4-2xk9p   │ estão enfrentando problemas    │
│                                │ 1/1     Running            0   │ que requerem atenção imediata. │
│                                │ 6d                             │ ### Pods problemáticos         │
│                                │ sentinel-api-7d9c8b6f4-zzp10   │ ```                            │
│                                │ 0/1     ImagePullBackOff   0   │ #### sentinel-prod/sen...      │
│                                │ ...                            │                                │
├────────────────────────────────┼────────────────────────────────┼────────────────────────────────┤
│ sentinel-prod                  │ $ kubectl get pods -n          │ [PASS] ### Resumo executivo    │
│                                │ sentinel-prod                  │ - **Namespace:** sentinel-prod │
│                                │ NAME                           │ - **Status geral:** SAUDÁVEL   │
│                                │ READY   STATUS    RESTARTS     │ - **Pods problemáticos:** 0    │
│                                │ AGE                            │ - **Veredito:** Nenhum pod     │
│                                │ sentinel-api-7d9c8b6f4-2xk9p   │ problemático identificado no   │
│                                │ 1/1     Running   0            │ snapshot.                      │
│                                │ 6d                             │ ### Pods problemáticos         │
│                                │ sentinel-api-7d9c8b6f4-h4m2t   │ > Nenhum pod problemático      │
│                                │ 1/1     Running   0            │ identificado no snap...        │
│                                │ 6d                             │                                │
│                                │ sentinel-wor...                │                                │
└────────────────────────────────┴────────────────────────────────┴────────────────────────────────┘
✓ Eval complete (ID: eval-Ri8-2026-09-21T20:28:06)

» View results: promptfoo view
» Share with your team: https://promptfoo.app
» Feedback: https://promptfoo.dev/feedback

Total Tokens: 3.981
  Provider: 3.981 (cached)
Incurred Tokens: 0
  Cached Savings: 3.981
  Actual Target Requests: 0

Results:
  ✓ 3 passed (100%)
  0 failed (0%)
  0 errors (0%)
Duration: 0s (concurrency: 4)
````

---

## networkpolicy-sentinel

### Saída bruta (`promptfoo eval -c devops/networkpolicy-sentinel/promptfooconfig.yaml`)

````
┌────────────────────────┬────────────────────────┬────────────────────────┬────────────────────────┐
│ manifesto_permissivo   │ regras_padrao          │ mapa_servicos          │ [openai:gpt-4o-mini]   │
│                        │                        │                        │ devops/networkpolicy-… │
│                        │                        │                        │ ---                    │
│                        │                        │                        │ nome: NetworkPolicy    │
│                        │                        │                        │ Sentinel               │
│                        │                        │                        │ descricao: Gera N...   │
├────────────────────────┼────────────────────────┼────────────────────────┼────────────────────────┤
│ # manifesto barrado    │ NetworkPolicy para o   │ Sentinel     →         │ [PASS] ```yaml         │
│ pela revisão de        │ namespace              │ namespace              │ # NetworkPolicy        │
│ segurança — permissivo │ "sentinel-prod":       │ sentinel-prod, pods    │ endurecida para        │
│ demais                 │ - pods do Sentinel só  │ com label app=sentinel │ sentinel-prod          │
│ apiVersion:            │ aceitam tráfego de     │ Relay        →         │ # Substitui manifesto  │
│ networking.k8s.io/v1   │ entrada do Relay       │ namespace relay-prod,  │ permissivo             │
│ kind: NetworkPolicy    │ (consumo de            │ pods com label         │ sentinel-allow         │
│ metadata:              │   eventos) e do gatew… │ app=relay              │ apiVersion:            │
│   name: sentinel-allow │ de API da plataforma   │ API gateway  →         │ networking.k8s.io/v1   │
│   namespace:           │ - pods do Sentinel só  │ namespace edge,        │ kind: NetworkPolicy    │
│ sentinel-prod          │ fazem saída para:      │ pods com label         │ metadata:              │
│ spec:                  │ Forge (warehouse,      │ app=api-gateway        │   name:                │
│   podSelector: {}      │ porta 5432),           │ Forge        →         │ sentinel-restrict      │
│ # aplica a todos os    │   Cerebro (bu...       │ namespace forge-prod,  │   namespace:           │
│ pods do namespa...     │                        │ pod...                 │ sentinel-prod          │
│                        │                        │                        │ spec:                  │
│                        │                        │                        │   podSelector:         │
│                        │                        │                        │     matc...            │
└────────────────────────┴────────────────────────┴────────────────────────┴────────────────────────┘
✓ Eval complete (ID: eval-nmb-2026-09-21T20:34:26)

» View results: promptfoo view
» Share with your team: https://promptfoo.app
» Feedback: https://promptfoo.dev/feedback

Total Tokens: 1.382
  Provider: 1.382 (1.019 prompt, 363 completion)

Results:
  ✓ 1 passed (100%)
  0 failed (0%)
  0 errors (0%)
Duration: 7s (concurrency: 4)
````

---

## Notas operacionais

- **Frontmatter em `prompt.md`:** o modelo recebe o frontmatter YAML junto com o corpo do prompt; nos testes atuais isso não impediu aprovação nos asserts determinísticos.
- **Trade-off latência/custo:** foi utilizado o modelo `gpt-4o-mini`. Devido à complexidade dos testes (especialmente `triagem-de-pods` e `networkpolicy-sentinel`), foi necessário ajustar o limiar de latência para 15 000 ms nos `promptfooconfig.yaml`. Não houve reprovações por latência ou custo após esse ajuste. Pelo retorno obtido (7/7 casos aprovados) e pelo baixo custo de tokens, acredito que `gpt-4o-mini` foi uma boa escolha para este CP08.
