---
nome: Triagem de pods
descricao: Analisa snapshot kubectl e identifica pods problemáticos no namespace Sentinel
versao: 1.0.0
tags: [kubernetes, sre, triagem, sentinel, plantao]
inputs:
  - nome: namespace
    descricao: Namespace Kubernetes analisado (ex. sentinel-prod)
  - nome: snapshot_cluster
    descricao: Saída combinada de kubectl get/describe/logs do namespace Sentinel
---

## Objetivo

Transformar saídas combinadas de `kubectl get/describe/logs` em diagnóstico estruturado de plantão, com pods problemáticos, causas cruzadas e próxima ação.

## Casos de uso

- Pod em CrashLoopBackOff ou OOMKilled durante incidente
- ImagePullBackOff ou Pending por capacidade do cluster
- Verificação de cluster saudável antes de encerrar turno

## Exemplo de uso

Substitua os placeholders e cole o prompt em um modelo de linguagem.

**Variáveis:**

| Placeholder            | Valor de exemplo                                                                                                                                                 |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `{{namespace}}`        | `sentinel-prod`                                                                                                                                                  |
| `{{snapshot_cluster}}` | Saída combinada de `kubectl get pods`, `describe pod` e `logs --previous` (cenário CrashLoopBackOff/OOM em `prompts/cp01-triagem-de-pods/entrega.md`, Entrada 1) |

**Trecho de entrada (snapshot resumido):**

```
$ kubectl get pods -n sentinel-prod
sentinel-api-7d9c8b6f4-h4m2t    0/1     CrashLoopBackOff   14 (90s ago)   42m
...
$ kubectl describe pod sentinel-api-7d9c8b6f4-h4m2t -n sentinel-prod
    Last State:     Terminated
      Reason:       OOMKilled
...
```

**Saída esperada (resumo):**

```
### Resumo executivo
- **Namespace:** sentinel-prod
- **Status geral:** ATENÇÃO
- **Pods problemáticos:** 1
- **Veredito:** Réplica sentinel-api em CrashLoopBackOff por OOMKilled; serviço parcialmente disponível.

### Pods problemáticos
#### sentinel-prod/sentinel-api-7d9c8b6f4-h4m2t
- **Causa provável:** limite 512Mi insuficiente para cache de alertas (evidências em logs + describe)
- **Próxima ação:** aumentar limit de memória e abrir follow-up com time Sentinel
```

Entradas completas (3 cenários) e outputs de referência: `prompts/cp01-triagem-de-pods/entrega.md`.

## Limitações conhecidas

- Analisa apenas o snapshot fornecido — não solicita novos comandos
- Restart antigo estabilizado não é classificado como problemático
- Causa provável exige cruzamento de describe/logs, não apenas STATUS
