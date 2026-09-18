# Entrega — Checkpoint 03: Causa-raiz da degradação no Cerebro

## Modelo

| Campo            | Valor      |
| ---------------- | ---------- |
| Provedor         | Claude     |
| Modelo           | Sonnet 5   |
| Data da execução | 18/09/2026 |

---

## Execução

### Artefatos usados

Pacote completo colado em `{{artefatos}}` (config + métricas + logs do enunciado).

#### Configuração (`cerebro.yaml`)

```yaml
# cerebro.yaml — configuração do cluster Elasticsearch (repositório de infra)
cerebro:
  shards: 12
  replicas_per_shard: 1
  jvm_heap: 8g
  refresh_interval: 1s
  reindex_job:
    schedule: "0 2 * * *" # roda todo dia às 02:00
    avg_duration_min: 90 # normalmente termina ~03:30
  query_cache:
    enabled: true
    size_mb: 512
```

#### Métricas (08:00–10:00 UTC)

```
timestamp              search_p99_ms   indexed_docs_per_s   heap_used_pct   cache_hit_pct
2026-05-13 08:00 UTC   850             4200                 61              74
2026-05-13 08:30 UTC   1100            4100                 68              71
2026-05-13 09:00 UTC   2300            9800                 79              58
2026-05-13 09:30 UTC   4100            11200                88              41
2026-05-13 10:00 UTC   6700            12400                94              29
```

#### Logs (`cerebro-node-3`, janela ~08h–10h UTC)

```
[2026-05-13T08:02:11,540][INFO ][o.e.t.LoggingTaskListener              ][cerebro-node-3] reindex task [88123] (scheduled 02:00) progress, created [3.8M]/[10M] docs (38%)
[2026-05-13T08:14:33,019][WARN ][o.e.m.j.JvmGcMonitorService            ][cerebro-node-3] [gc][young] duration [620ms], collections [1] in [10s], heap [4.9gb]->[3.1gb]/[8gb]
[2026-05-13T08:41:07,222][INFO ][o.e.i.IndexingMemoryController         ][cerebro-node-3] now throttling indexing for shard [logs-2026.05][7]: segment writing can't keep up
[2026-05-13T09:03:55,810][WARN ][o.e.t.ThreadPool                       ][cerebro-node-3] write thread pool queue at [150/200]
[2026-05-13T09:12:48,402][WARN ][o.e.m.j.JvmGcMonitorService            ][cerebro-node-3] [gc][old] duration [1.1s], collections [2] in [60s], heap [6.3gb]->[5.9gb]/[8gb]
[2026-05-13T09:20:02,118][INFO ][o.e.t.LoggingTaskListener              ][cerebro-node-3] reindex task [88123] (scheduled 02:00) progress, created [4.0M]/[10M] docs (40%)
[2026-05-13T09:31:17,653][WARN ][o.e.i.b.HierarchyCircuitBreakerService ][cerebro-node-3] [parent] usage [6.9gb/8gb] (86%), approaching limit
[2026-05-13T09:44:29,901][WARN ][o.e.s.SearchService                    ][cerebro-node-3] slow query on shard [logs-2026.05][7] took [2380ms]
[2026-05-13T09:51:08,377][WARN ][o.e.t.ThreadPool                       ][cerebro-node-3] write thread pool queue at [188/200]
[2026-05-13T09:58:41,102][WARN ][o.e.t.ThreadPool                       ][cerebro-node-3] write thread pool queue full [200/200], rejecting bulk — EsRejectedExecutionException
[2026-05-13T09:58:43,210][WARN ][o.e.m.j.JvmGcMonitorService            ][cerebro-node-3] [gc][old] duration [1.8s], collections [4] in [60s], heap [7.6gb]->[7.4gb]/[8gb]
[2026-05-13T09:58:44,005][INFO ][o.e.t.LoggingTaskListener              ][cerebro-node-3] reindex task [88123] (scheduled 02:00) still running, created [4.1M]/[10M] docs (41%), ETA unknown
[2026-05-13T09:58:45,889][WARN ][o.e.i.IndexingMemoryController         ][cerebro-node-3] indexing buffer above limit, throttling shard [logs-2026.05][7]
[2026-05-13T09:58:46,330][DEBUG][o.e.s.query.QueryPhase                 ][cerebro-node-3] shard [logs-2026.05][7] search took [5031ms] (timeout [5000ms])
[2026-05-13T09:58:46,512][ERROR][o.e.s.SearchService                    ][cerebro-node-3] search returned partial results: 11/12 shards succeeded
[2026-05-13T09:58:46,701][WARN ][o.e.i.b.HierarchyCircuitBreakerService ][cerebro-node-3] [parent] circuit breaker tripped, usage [7.7gb/8gb] (96%) over limit
[2026-05-13T09:58:47,001][WARN ][o.e.i.cache.query.IndicesQueryCache    ][cerebro-node-3] query cache eviction rate spiking, hit_ratio dropped to 0.29
[2026-05-13T10:01:12,778][ERROR][o.e.s.SearchService                    ][cerebro-node-3] CircuitBreakingException: [parent] Data too large, would be [7.9gb/8gb]
[2026-05-13T10:03:39,255][WARN ][o.e.t.ThreadPool                       ][cerebro-node-3] write thread pool rejected [1284] bulk requests in last 5min
[2026-05-13T10:05:50,640][ERROR][o.e.s.SearchService                    ][cerebro-node-3] all shards failed for index [logs-2026.05] on 3 of last 20 queries
```

**Output do modelo:**

### Resumo executivo

- **Sistema:** Cerebro (Elasticsearch)
- **Severidade:** CRÍTICA
- **Causa-raiz (1 frase):** O job de reindexação agendado para 02:00 (duração esperada ~90 min) não terminou no prazo e seguiu consumindo recursos de indexação por mais de 6 horas, sustentando pressão de heap sobre o shard `logs-2026.05][7]` até o rompimento do circuit breaker de memória.
- **Veredito:** Cluster em degradação progressiva por exaustão de heap originada em reindexação anômala e não concluída; a partir de ~09:58 UTC o circuit breaker rompeu, causando rejeição de bulks e falhas parciais/totais de busca — ação de mitigação imediata necessária antes de nova escalada.

### Linha do tempo da degradação

```
02:00 UTC — reindex task 88123 inicia conforme schedule — evidência: config (reindex_job.schedule)
08:00 UTC — degradação já em curso: p99=850ms, heap=61%, cache_hit=74% — evidência: métricas
08:02 UTC — reindex task 88123 em apenas 38% (3.8M/10M), já ~4h30 além da duração média esperada (90min/~03:30) — evidência: log + config (avg_duration_min: 90)
08:14 UTC — GC young de 620ms — evidência: log
08:30 UTC — p99 sobe para 1100ms, heap 68%, cache_hit cai para 71% — evidência: métricas
08:41 UTC — indexing throttling ativado no shard [logs-2026.05][7] (segment writing não acompanha o ritmo) — evidência: log
09:00 UTC — p99 salta para 2300ms, indexação 9800 docs/s, heap 79%, cache_hit 58% — evidência: métricas
09:03 UTC — fila do write thread pool em 150/200 — evidência: log
09:12 UTC — GC old de 1.1s (heap 6.3gb→5.9gb/8gb) — evidência: log
09:20 UTC — reindex ainda em 40% — progresso quase estagnado — evidência: log
09:30 UTC — p99=4100ms, heap=88%, cache_hit=41% — evidência: métricas
09:31 UTC — parent circuit breaker em 86% de uso, alerta de aproximação do limite — evidência: log
09:44 UTC — slow query de 2380ms no shard [logs-2026.05][7] — evidência: log
09:51 UTC — fila do write thread pool em 188/200 — evidência: log
09:58:41 UTC — fila cheia (200/200), bulks começam a ser rejeitados — evidência: log
09:58:43 UTC — GC old de 1.8s (heap 7.6gb→7.4gb/8gb) — evidência: log
09:58:44 UTC — reindex em 41%, ETA desconhecido — evidência: log
09:58:45 UTC — buffer de indexação acima do limite, shard [7] throttled novamente — evidência: log
09:58:46 UTC — query com timeout (5031ms) + resultado parcial (11/12 shards) + circuit breaker rompido (96% de uso) — evidência: log
09:58:47 UTC — eviction do query cache dispara, hit_ratio cai para 0.29 — evidência: log + métrica (cache_hit_pct=29% às 10:00)
10:00 UTC — pico da degradação: p99=6700ms, heap=94%, cache_hit=29%, indexação=12400 docs/s — evidência: métricas
10:01 UTC — CircuitBreakingException "Data too large" — evidência: log
10:03 UTC — 1284 bulk requests rejeitados nos últimos 5 min — evidência: log
10:05 UTC — falha total de shards em 3 de 20 queries para o índice logs-2026.05 — evidência: log
```

### Causa-raiz

- **Diagnóstico:** A reindexação noturna (task 88123) não concluiu dentro da janela esperada e continuou rodando por horas além do previsto, mantendo carga de escrita concentrada no shard `logs-2026.05][7]`. Essa pressão sustentada de indexação, somada a `refresh_interval: 1s` (refreshes frequentes de segmento) e a um heap de apenas `8g`, elevou o uso de heap de forma contínua até romper o parent circuit breaker, que é o evento que desencadeou as falhas em cascata de escrita e busca.
- **Evidências cruzadas:**
  - Config: `reindex_job.avg_duration_min: 90` (esperado terminar ~03:30) e `jvm_heap: 8g` / `refresh_interval: 1s` — parâmetros que definem a janela normal e a sensibilidade do heap.
  - Métricas: `heap_used_pct` sobe monotonicamente de 61% (08:00) a 94% (10:00), em paralelo com queda de `cache_hit_pct` de 74% para 29%.
  - Logs: reindex task 88123 ainda em 38–41% entre 08:02 e 09:58 (muito além do previsto), throttling repetido no mesmo shard `[7]` (08:41 e 09:58:45), e rompimento do circuit breaker às 09:58:46/10:01 imediatamente após a fila do write thread pool encher (09:58:41).

### Efeitos colaterais (sintomas)

- Aumento progressivo de `search_p99_ms` (850 → 6700ms), consequência da concorrência entre reindexação e buscas pelo mesmo heap/recursos.
- GCs young/old cada vez mais longos e frequentes, refletindo a pressão de memória gerada pela indexação sustentada.
- Fila do write thread pool saturando (150→188→200/200) e rejeição de 1284 bulks em 5 min, decorrência direta do circuit breaker e do throttling de indexação no shard quente.
- Queda de `cache_hit_pct` (74%→29%) e eviction acelerada do query cache, efeito colateral da disputa por memória sob o `HierarchyCircuitBreakerService`, não uma causa independente.
- Resultados de busca parciais/totalmente falhos (11/12 shards; 3/20 queries falhas) e `CircuitBreakingException`, consequência final da cadeia acima.

### Ação recomendada

- **Imediata (plantão):** Pausar ou cancelar o reindex task 88123 para liberar heap e aliviar a pressão de escrita no shard `logs-2026.05][7]`; isso remove a fonte contínua de carga que sustenta o circuit breaker rompido e deve permitir a queda gradual do `heap_used_pct` e a normalização das filas de escrita/busca.
- **Follow-up (pós-incidente):** Investigar por que a reindexação, com duração média histórica de 90 min, não avançou além de ~41% em quase 8 horas (possível gargalo de volume de dados, hardware ou configuração não capturado nestes artefatos); revisar dimensionamento do `jvm_heap` e do `refresh_interval` frente à carga real de reindexação, e avaliar isolamento/rebalanceamento do shard `[7]` que concentrou o throttling.

### Limites dos dados

- Os artefatos não explicam **por que** a reindexação ficou tão mais lenta que a média histórica (90 min) — não há dados de volume de origem, hardware, rede ou concorrência com outros jobs que permitam confirmar a causa do atraso do reindex em si.
- Não é possível confirmar com certeza se o shard `[7]` foi a única fonte de pressão de heap ou apenas o sintoma mais visível registrado nos logs; outros shards podem ter contribuído sem terem sido logados.
- O aumento simultâneo de `indexed_docs_per_s` (4200→12400) junto com a degradação não tem explicação causal clara nos dados — pode refletir tentativas de retry/reenvio de bulks, aumento de tráfego legítimo, ou ambos; não há como distinguir com as evidências disponíveis.
- Não há dados após 10:05 UTC, portanto não é possível afirmar se o incidente foi contido, se houve auto-recuperação, ou se a degradação continuou/piorou.
- Não há informação sobre o estado de outros nós do cluster além de `cerebro-node-3`; não é possível avaliar se o problema é isolado a esse nó/shard ou disseminado.

---

## Justificativa do método

**Role + zero-shot estrutural + schema RCA fixo:** a persona SRE Elasticsearch e as seis regras (fonte única, causa vs. efeito, correlação temporal, evidências cruzadas, honestidade epistêmica, ação proporcional) conduzem o raciocínio até causa-raiz; o template de seções (Resumo → Linha do tempo → Causa-raiz → Efeitos colaterais → Ação → Limites) impõe saída acionável sem dump dos artefatos.
Few-shot com pacote pareado foi descartado — cola caso de teste na instrução e conflita com o parâmetro único `{{artefatos}}`.

---

## Curadoria

### Ajustes feitos no prompt (se houver)

_(preencher manualmente)_

---

## Sanitização

Antes de enviar artefatos reais de produção a um modelo externo, revisar e substituir:

- Hostnames e nomes de nós (`cerebro-node-*`, namespaces, clusters)
- Nomes de índices/shards (`logs-2026.05`, IDs de tasks)
- Identificadores internos de jobs e tenants
- Qualquer endpoint, credencial ou dado que permita reconstruir topologia interna

_(documentar aqui o que foi sanitizado nesta entrega, se aplicável)_
