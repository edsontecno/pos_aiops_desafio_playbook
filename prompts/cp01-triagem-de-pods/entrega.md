# Entrega — Checkpoint 01: Triagem de pods Kubernetes

## Modelo

| Campo            | Valor      |
| ---------------- | ---------- |
| Provedor         | Claude     |
| Modelo           | Sonnet 5   |
| Data da execução | 18/09/2026 |

---

## Execução

### Entrada 1 — pod reiniciando (CrashLoopBackOff / OOM)

**Snapshot usado:**

```
$ kubectl get pods -n sentinel-prod
NAME                            READY   STATUS             RESTARTS       AGE
sentinel-api-7d9c8b6f4-2xk9p    1/1     Running            0              6d
sentinel-api-7d9c8b6f4-h4m2t    0/1     CrashLoopBackOff   14 (90s ago)   42m
sentinel-worker-5b8f9c8d-jq7rs  1/1     Running            0              6d
sentinel-scheduler-6c4d7f-nn8vx 1/1     Running            0              6d
$ kubectl describe pod sentinel-api-7d9c8b6f4-h4m2t -n sentinel-prod
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
    Limits:         memory: 512Mi
    Requests:       memory: 256Mi
Events:
  Type     Reason   Age                 From     Message
  ----     ------   ----                ----     -------
  Warning  BackOff  2m (x18 over 40m)   kubelet  Back-off restarting failed container api
$ kubectl logs sentinel-api-7d9c8b6f4-h4m2t -n sentinel-prod --previous
2026-05-13 10:14:02 [INFO]  [api] startup complete, version 2.9.1
2026-05-13 10:14:48 [INFO]  [cache] loading 6h alert cache (heap 410Mi/512Mi)
2026-05-13 10:15:10 [WARN]  [runtime] high GC pressure, heap 498Mi/512Mi
2026-05-13 10:15:12 [FATAL] [runtime] out of memory, shutting down process
```

**Output do modelo:**

### Resumo executivo

- **Namespace:** sentinel-prod
- **Status geral:** ATENÇÃO
- **Pods problemáticos:** 1
- **Veredito:** Um dos dois pods do serviço `sentinel-api` está em CrashLoopBackOff ativo por OOMKilled, mas o outro réplica segue saudável, mantendo o serviço parcialmente disponível.

### Pods problemáticos

#### sentinel-prod/sentinel-api-7d9c8b6f4-h4m2t

- **Status:** CrashLoopBackOff (0/1 Ready), 14 restarts nos últimos 90s, evento de BackOff recorrente (x18 em 40min)
- **Causa provável:** O container está excedendo o limite de memória (512Mi) durante a operação normal de carregamento de cache. Os logs mostram progressão clara: heap em 410Mi logo após o carregamento do cache de alertas, subindo para 498Mi com aviso de alta pressão de GC, culminando em OOM e finalização do processo (exit code 137, confirmado pelo describe como `OOMKilled`). Isso indica que o limite de memória configurado é insuficiente para o footprint real da aplicação nesta versão (2.9.1), não uma falha transitória.
- **Evidências:**
  - Log: `loading 6h alert cache (heap 410Mi/512Mi)` — já consumindo 80% do limite logo na inicialização
  - Log: `high GC pressure, heap 498Mi/512Mi` seguido por `out of memory, shutting down process`
  - Describe: `Last State: Terminated, Reason: OOMKilled, Exit Code: 137`
  - Describe: `Limits: memory: 512Mi` / `Requests: memory: 256Mi` — gap grande entre request e limit, e limit próximo do consumo observado
  - Evento: `Back-off restarting failed container api` (x18 em 40min) — ciclo de crash ativo, não isolado
- **Próxima ação:** Aumentar o limite de memória do container `api` (ex.: de 512Mi para 1Gi) como mitigação imediata para estabilizar o pod, e abrir um follow-up com o time de desenvolvimento do Sentinel para investigar se o cache de 6h de alertas está com uso de memória desproporcional na versão 2.9.1 (possível regressão ou necessidade de paginação/streaming do cache).

### Considerações finais

- O pod `sentinel-api-7d9c8b6f4-2xk9p` está `1/1 Running`, sem restarts, há 6 dias — não há indício de instabilidade nele; o problema parece isolado à réplica específica, embora ambas rodem a mesma versão/imagem, o que sugere que a segunda réplica pode entrar em OOM sob carga equivalente (ex.: se também acumular 6h de cache).
- `sentinel-worker` e `sentinel-scheduler` estão saudáveis (1/1 Running, 0 restarts, 6d), sem dados no snapshot que indiquem risco.
- Risco de propagação: como o `sentinel-api` está rodando com apenas 1 de 2 réplicas saudáveis, uma falha ou pico de carga na réplica restante (`2xk9p`) deixaria o serviço API totalmente indisponível — recomenda-se tratar a correção do OOM como prioritária, não apenas informativa.
- Dado faltante no snapshot: não há informação sobre HPA, resource requests reais de CPU, nem métricas de tráfego/carga que expliquem por que apenas uma réplica está afetada — útil para o follow-up com o time de desenvolvimento.

---

### Entrada 2 — pods que não sobem (ImagePullBackOff / Pending)

**Snapshot usado:**

```
$ kubectl get pods -n sentinel-prod
NAME                            READY   STATUS             RESTARTS   AGE
sentinel-api-7d9c8b6f4-2xk9p    1/1     Running            0          6d
sentinel-api-7d9c8b6f4-zzp10    0/1     ImagePullBackOff   0          8m
sentinel-ingest-8f7a9c5b-4dkqm  0/1     Pending            0          8m
sentinel-scheduler-6c4d7f-nn8vx 1/1     Running            0          6d
$ kubectl describe pod sentinel-api-7d9c8b6f4-zzp10 -n sentinel-prod
    State:    Waiting
      Reason: ImagePullBackOff
    Image:    registry.aegis.io/sentinel-api:2.9.2
Events:
  Type     Reason   Age   From     Message
  ----     ------   ----  ----     -------
  Warning  Failed   7m    kubelet  Failed to pull image "registry.aegis.io/sentinel-api:2.9.2": manifest unknown
  Warning  Failed   7m    kubelet  Error: ErrImagePull
  Normal   BackOff  6m    kubelet  Back-off pulling image "registry.aegis.io/sentinel-api:2.9.2"
$ kubectl describe pod sentinel-ingest-8f7a9c5b-4dkqm -n sentinel-prod
    State:    Waiting
      Reason: Pending
    Requests: cpu: 2
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  7m    default-scheduler  0/6 nodes are available: 6 Insufficient cpu
```

**Output do modelo:**

### Resumo executivo

- **Namespace:** sentinel-prod
- **Status geral:** CRÍTICO
- **Pods problemáticos:** 2
- **Veredito:** Deploy de nova versão da API falhou por imagem inexistente no registry, e o serviço de ingest está impedido de escalar por falta de CPU no cluster.

### Pods problemáticos

#### sentinel-prod/sentinel-api-7d9c8b6f4-zzp10

- **Status:** ImagePullBackOff (0/1 Ready, 8m de idade)
- **Causa provável:** o kubelet não conseguiu localizar a tag `sentinel-api:2.9.2` no registry (`manifest unknown`), indicando que essa tag nunca foi publicada em `registry.aegis.io` ou foi removida/renomeada — não é um problema de rede ou credencial, e sim de artefato ausente.
- **Evidências:**
  - `Failed to pull image "registry.aegis.io/sentinel-api:2.9.2": manifest unknown`
  - `Error: ErrImagePull` seguido de `BackOff pulling image`, confirmando tentativas repetidas sem sucesso
  - O pod irmão `sentinel-api-7d9c8b6f4-2xk9p` está `1/1 Running` há 6d, sugerindo que este é um rollout novo (ReplicaSet `7d9c8b6f4` com pod recém-criado tentando subir a mesma tag, mas falhando)
- **Próxima ação:** verificar no CI/CD ou no registry se a tag `2.9.2` foi de fato publicada; se não foi, corrigir o pipeline de build/push ou fazer rollback do Deployment para a tag anterior válida (a mesma usada pelo pod `2xk9p`, se distinta) até a imagem correta estar disponível.

#### sentinel-prod/sentinel-ingest-8f7a9c5b-4dkqm

- **Status:** Pending (0/1 Ready, 8m de idade)
- **Causa provável:** o scheduler não conseguiu alocar o pod porque nenhum dos 6 nós do cluster tem CPU disponível suficiente para atender ao request de 2 CPUs definido no pod — trata-se de capacidade insuficiente no cluster, não de erro de configuração do pod em si.
- **Evidências:**
  - `FailedScheduling`: `0/6 nodes are available: 6 Insufficient cpu`
  - `Requests: cpu: 2` — request relativamente alto que nenhum nó consegue comportar no momento
- **Próxima ação:** escalar o cluster (adicionar nós ou acionar autoscaler) ou revisar se o request de 2 CPUs é realmente necessário; se a capacidade não puder ser ampliada rapidamente, escalar para o time de infraestrutura/plataforma responsável pelo node pool.

### Considerações finais

- O pod `sentinel-api-7d9c8b6f4-2xk9p` (1/1 Running, 6d, 0 restarts) e `sentinel-scheduler-6c4d7f-nn8vx` (1/1 Running, 6d, 0 restarts) estão estáveis e não indicam incidente ativo.
- Risco de propagação: se o ImagePullBackOff afeta um rollout em andamento do `sentinel-api`, vale confirmar se há uma política de rollout (ex.: `maxUnavailable`) que impeça a substituição completa do pod saudável enquanto a nova versão falha — o snapshot não traz o spec do Deployment para confirmar isso.
- Dados faltantes que ajudariam a diagnosticar mais rápido: spec do Deployment/ReplicaSet (para confirmar se é rollout novo), uso atual de CPU dos 6 nós (`kubectl describe nodes` ou `kubectl top nodes`), e histórico de tags publicadas no registry para `sentinel-api`.
- Follow-up recomendado: acompanhar se novos pods do `sentinel-ingest` continuam em Pending após ação de escala, e confirmar junto ao time responsável pelo release se a tag `2.9.2` foi intencional ou erro de digitação/pipeline.

---

### Entrada 3 — cluster saudável

**Snapshot usado:**

```
$ kubectl get pods -n sentinel-prod
NAME                            READY   STATUS    RESTARTS     AGE
sentinel-api-7d9c8b6f4-2xk9p    1/1     Running   0            6d
sentinel-api-7d9c8b6f4-h4m2t    1/1     Running   0            6d
sentinel-worker-5b8f9c8d-jq7rs  1/1     Running   1 (3d ago)   6d
sentinel-scheduler-6c4d7f-nn8vx 1/1     Running   0            6d
$ kubectl logs sentinel-api-7d9c8b6f4-2xk9p -n sentinel-prod --tail=3
2026-05-13 11:02:31 [INFO] [api] health check OK, 0 errors in the last 5min
2026-05-13 11:03:31 [INFO] [api] processed 4.2k alerts/min, p99 latency 120ms
2026-05-13 11:04:31 [INFO] [api] health check OK
```

**Output do modelo:**

```
### Resumo executivo

- **Namespace:** sentinel-prod
- **Status geral:** SAUDÁVEL
- **Pods problemáticos:** 0
- **Veredito:** Todos os pods estão `Running`/`Ready`, sem sinais de falha ativa no snapshot analisado.

### Pods problemáticos

> Nenhum pod problemático identificado no snapshot.

### Considerações finais

- **sentinel-worker-5b8f9c8d-jq7rs** apresenta 1 restart, mas ocorreu há 3 dias, o pod está `1/1 Running` há 6 dias no total e não há evidência (nem em STATUS, nem em logs) de falha ativa recorrente. Conforme a regra de "restart antigo estabilizado", não deve ser classificado como problemático — apenas registrado aqui para conhecimento do plantão.
- O snapshot não contém `kubectl describe` nem logs desse worker, então a causa daquele único restart antigo não pode ser determinada a partir dos dados disponíveis; não há base para especular.
- Os logs do `sentinel-api-7d9c8b6f4-2xk9p` mostram healthchecks OK e throughput/latência normais (4.2k alerts/min, p99 120ms), reforçando o quadro saudável, mas cobrem apenas uma janela curta (3 linhas) e um único pod das duas réplicas do `sentinel-api`.
- **Dados faltantes que limitam a análise:** não há `describe` de nenhum pod, nem logs do `sentinel-worker` e do `sentinel-scheduler`. Se houver suspeita de degradação não visível no `get pods` (ex.: erros silenciosos, lentidão), recomenda-se coletar esses dados antes de fechar o diagnóstico como definitivo.
- **Follow-up sugerido:** se o restart do worker se repetir, puxar `kubectl describe pod sentinel-worker-5b8f9c8d-jq7rs -n sentinel-prod` e os logs anteriores ao último restart (`--previous`) para identificar causa raiz antes que vire um padrão.
```

---

## Justificativa do método

**Role + zero-shot estrutural + schema fixo:** a persona SRE e as seis regras de análise (fonte única, restart antigo ≠ problemático, causa cruzada com evidências) delimitam o raciocínio sobre o snapshot; o template de seções (Resumo executivo → Pods problemáticos → Considerações finais) impõe saída legível e acionável sem dump cru.
Few-shot com snapshot pareado foi descartado — cola caso de teste na instrução e conflita com o parâmetro único `{{snapshot_cluster}}`.

---

## Curadoria

### Ajustes feitos no prompt (se houver)

Necessário ajustar o a seção 'Resumo executivo' para que as informações sejam criadas em formato de tópico facilitando a visualização do resultado desejado.
