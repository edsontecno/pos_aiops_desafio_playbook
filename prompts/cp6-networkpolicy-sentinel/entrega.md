# Entrega — Checkpoint 06: NetworkPolicy do Sentinel

## Modelo

| Campo            | Valor                |
| ---------------- | -------------------- |
| Provedor         | _(preencher manual)_ |
| Modelo           | _(preencher manual)_ |
| Data da execução | _(preencher manual)_ |

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
  podSelector: {}          # aplica a todos os pods do namespace
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - {}                   # libera QUALQUER origem
  egress:
    - {}                   # libera QUALQUER destino
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

_(preencher YAML gerado pelo prompt.md)_

---

### Verificação

_(preencher feedback do prompt-verificacao.md aplicado à v1)_

---

### v2

_(preencher YAML corrigido após endereçar gaps da verificação)_

---

### v3 (opcional)

_(preencher se houver segunda rodada de verificação)_

---

## Justificativa do método

**Dois prompts (gerar + verificar):** o prompt principal produz NetworkPolicy endurecida a partir de manifesto permissivo + regras + mapa; o prompt-verificacao aplica checklist de revisor (allow-all, portas, labels, comentários, default-deny). Ciclo v1 → verificação → v2 documenta refinamento iterativo exigido pela segurança.

---

## Curadoria

### Ajustes feitos nos prompts (se houver)

_(preencher manualmente)_
