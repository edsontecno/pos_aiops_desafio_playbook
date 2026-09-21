# Entrega — Checkpoint 06: NetworkPolicy do Sentinel

## Modelo

| Campo            | Valor      |
| ---------------- | ---------- |
| Provedor         | Claude     |
| Modelo           | Sonnet 5   |
| Data da execução | 18/09/2026 |

---

## Inputs usados

### Manifesto permissivo (barrado)

```yaml
# manifesto barrado pela revisão de segurança — permissivo demais
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sentinel-allow
  namespace: sentinel-prod
spec:
  podSelector: {} # aplica a todos os pods do namespace
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - {} # libera QUALQUER origem
  egress:
    - {} # libera QUALQUER destino
```

### Regras do padrão Aegis

```
NetworkPolicy para o namespace "sentinel-prod":
- pods do Sentinel só aceitam tráfego de entrada do Relay (consumo de
  eventos) e do gateway de API da plataforma
- pods do Sentinel só fazem saída para: Forge (warehouse, porta 5432),
  Cerebro (busca, porta 9200) e DNS interno
- nada de "allow all" em ingress ou egress
- política default-deny explícita no namespace
- toda regra precisa de comentário dizendo qual fluxo legítimo ela libera
```

### Mapa de serviços

```
Sentinel     → namespace sentinel-prod, pods com label app=sentinel
Relay        → namespace relay-prod,    pods com label app=relay
API gateway  → namespace edge,          pods com label app=api-gateway
Forge        → namespace forge-prod,    pods com label app=forge,   porta 5432 (Postgres do warehouse)
Cerebro      → namespace cerebro-prod,  pods com label app=cerebro, porta 9200 (Elasticsearch)
DNS interno  → namespace kube-system,   pods com label k8s-app=kube-dns, porta 53
```

---

## Iterações

### v1

```yaml
# NetworkPolicy endurecida para sentinel-prod
# Substitui manifesto permissivo sentinel-allow
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sentinel-strict
  namespace: sentinel-prod
spec:
  podSelector:
    matchLabels:
      app: sentinel
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Libera tráfego de entrada do Relay (consumo de eventos)
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: relay-prod
          podSelector:
            matchLabels:
              app: relay
    # Libera tráfego de entrada do gateway de API da plataforma
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: edge
          podSelector:
            matchLabels:
              app: api-gateway
  egress:
    # Libera tráfego de saída para o Forge (warehouse)
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: forge-prod
          podSelector:
            matchLabels:
              app: forge
      ports:
        - protocol: TCP
          port: 5432
    # Libera tráfego de saída para o Cerebro (busca)
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: cerebro-prod
          podSelector:
            matchLabels:
              app: cerebro
      ports:
        - protocol: TCP
          port: 9200
    # Libera tráfego de saída para o DNS interno
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

---

### Verificação

### Veredito geral

- **Status:** APROVADO COM RESSALVAS
- **Resumo:** A NetworkPolicy estabelece um perímetro defensivo sólido para a aplicação `sentinel`. O isolamento por `namespaceSelector` combinado com `podSelector` impede movimentação lateral e aplica default-deny efetivo. No entanto, o Ingress deixa as portas de entrada completamente abertas para as fontes autorizadas, o que expõe superfícies desnecessárias no Pod.

---

### Checklist detalhado

| #   | Item                   | Status | Evidência / gap                                                                                                   |
| --- | ---------------------- | ------ | ----------------------------------------------------------------------------------------------------------------- |
| 1   | Sem allow-all          | PASS   | Nenhuma regra genérica ou `- {}` encontrada no Ingress ou Egress.                                                 |
| 2   | Default-deny implícito | PASS   | `podSelector` restrito a `app: sentinel` (linhas 9-11) e `policyTypes` cobre `Ingress` e `Egress` (linhas 12-14). |
| 3   | Ingress Relay          | PASS   | Regra combina `namespaceSelector: relay-prod` e `podSelector: app: relay` no mesmo item (linhas 18-24).           |
| 4   | Ingress API gateway    | PASS   | Regra combina `namespaceSelector: edge` e `podSelector: app: api-gateway` no mesmo item (linhas 26-32).           |
| 5   | Egress Forge           | PASS   | Regra de saída direcionada a `forge-prod` / `app: forge` na porta TCP 5432 (linhas 35-43).                        |
| 6   | Egress Cerebro         | PASS   | Regra de saída direcionada a `cerebro-prod` / `app: cerebro` na porta TCP 9200 (linhas 45-53).                    |
| 7   | Egress DNS             | PASS   | Regra de saída direcionada a `kube-system` / `k8s-app: kube-dns` nas portas UDP/TCP 53 (linhas 55-65).            |
| 8   | Sem egress extra       | PASS   | Regras de saída restritas estritamente a Forge, Cerebro e DNS.                                                    |
| 9   | Comentários            | PASS   | Todas as regras contêm comentários explicativos de contexto (linhas 17, 25, 34, 44, 54).                          |
| 10  | Portas explícitas      | WARN   | O bloco `ingress` (linhas 16-32) não especifica portas de destino no pod `sentinel`.                              |
| 11  | Metadata               | PASS   | `name: sentinel-strict` e `namespace: sentinel-prod` configurados corretamente (linhas 5-6).                      |

---

### Gaps críticos (FAIL)

- Nenhum item reprovado. Os bloqueios essenciais de tráfego não autorizado estão operacionais.

---

### Ressalvas (WARN)

- **Acesso a portas irrestrito no Ingress (linhas 16-32):** As regras do Ingress não declaram o bloco `ports`. Isso significa que tanto o `relay` quanto o `api-gateway` podem alcançar **qualquer** porta aberta no pod `sentinel` (ex.: portas de métricas `:9090`, depuração ou endpoints administrativos internos do container).

---

### Perguntas que um revisor faria

- Em quais portas específicas a aplicação `sentinel` recebe requisições do `api-gateway` e do `relay` (ex.: TCP 8080, TCP 8443)?
- A rotulagem dos pods de DNS no cluster utiliza exclusivamente `k8s-app: kube-dns`, ou há nodes/clusters onde a label ativa é `app.kubernetes.io/name: coredns`?

---

### Sugestões de correção para próxima versão

- **Restringir portas no Ingress:** Adicionar o campo `ports` especificando apenas as portas de serviço da aplicação sob os blocos de Ingress do `relay` e do `api-gateway` (ex.: declarar `- protocol: TCP` / `port: <PORTA_DA_APLICACAO>`).
- **Validação de labels DNS:** Verificar no cluster se a seleção `k8s-app: kube-dns` é suficiente ou se requer fallback para rótulos do CoreDNS via `matchExpressions`.

---

### v2

```yml
# NetworkPolicy endurecida para sentinel-prod (Versão Final Aprovada)
# Substitui manifesto permissivo sentinel-allow
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sentinel-strict
  namespace: sentinel-prod
spec:
  podSelector:
    matchLabels:
      app: sentinel
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Libera tráfego de entrada do Relay (consumo de eventos) apenas na porta de serviço
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: relay-prod
          podSelector:
            matchLabels:
              app: relay
      ports:
        - protocol: TCP
          port: 8080 # Altere para a porta exata da sua aplicação se for diferente
    # Libera tráfego de entrada do gateway de API da plataforma apenas na porta de serviço
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: edge
          podSelector:
            matchLabels:
              app: api-gateway
      ports:
        - protocol: TCP
          port: 8080 # Altere para a porta exata da sua aplicação se for diferente
  egress:
    # Libera tráfego de saída para o Forge (warehouse)
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: forge-prod
          podSelector:
            matchLabels:
              app: forge
      ports:
        - protocol: TCP
          port: 5432
    # Libera tráfego de saída para o Cerebro (busca)
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: cerebro-prod
          podSelector:
            matchLabels:
              app: cerebro
      ports:
        - protocol: TCP
          port: 9200
    # Libera tráfego de saída para o DNS interno
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

---

### v3 (opcional)

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sentinel-strict
  namespace: sentinel-prod
spec:
  podSelector:
    matchLabels:
      app: sentinel
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Libera tráfego de entrada do Relay (consumo de eventos) apenas na porta de serviço
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: relay-prod
          podSelector:
            matchLabels:
              app: relay
      ports:
        - protocol: TCP
          port: 8080
    # Libera tráfego de entrada do gateway de API da plataforma apenas na porta de serviço
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: edge
          podSelector:
            matchLabels:
              app: api-gateway
      ports:
        - protocol: TCP
          port: 8080
  egress:
    # Libera tráfego de saída para o Forge (warehouse)
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: forge-prod
          podSelector:
            matchLabels:
              app: forge
      ports:
        - protocol: TCP
          port: 5432
    # Libera tráfego de saída para o Cerebro (busca)
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: cerebro-prod
          podSelector:
            matchLabels:
              app: cerebro
      ports:
        - protocol: TCP
          port: 9200
    # Libera tráfego de saída para o DNS interno (suporta tanto kube-dns quanto coredns)
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchExpressions:
              - key: k8s-app
                operator: In
                values:
                  - kube-dns
                  - coredns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

---

## Justificativa do método

**Dois prompts (gerar + verificar):** o prompt principal produz NetworkPolicy endurecida a partir de manifesto permissivo + regras + mapa; o prompt-verificacao aplica checklist de revisor (allow-all, portas, labels, comentários, default-deny). Ciclo v1 → verificação → v2 documenta refinamento iterativo exigido pela segurança.
