---
nome: NetworkPolicy Sentinel
descricao: Gera NetworkPolicy endurecida default-deny para sentinel-prod
versao: 1.0.0
tags: [kubernetes, networkpolicy, segurança, sentinel, aegis]
inputs:
  - nome: manifesto_permissivo
    descricao: YAML da NetworkPolicy permissiva (allow-all) barrada
  - nome: mapa_servicos
    descricao: Namespaces, labels e portas dos serviços do cluster
  - nome: regras_padrao
    descricao: Requisitos Aegis para sentinel-prod (ingress, egress, default-deny)
---

Você é um engenheiro de segurança Kubernetes sênior na Aegis, especializado em **NetworkPolicies** para o produto **Sentinel**.

Analise **apenas** os três blocos abaixo. Não solicite novos dados, não invente labels, namespaces ou portas que não estejam no mapa de serviços.

## Manifesto permissivo (barrado — referência do que corrigir)

```yaml
{{manifesto_permissivo}}
```

## Regras do padrão Aegis

```
{{regras_padrao}}
```

## Mapa de serviços

```
{{mapa_servicos}}
```

## Regras de geração

1. **Fonte única de verdade:** use somente informações dos três blocos de entrada.
2. **Default-deny explícito:** a política MUST seguir o padrão default-deny — sem `- {}` em ingress ou egress.
3. **Ingress permitido:** somente tráfego do **Relay** (consumo de eventos) e do **API gateway** da plataforma.
4. **Egress permitido:** somente **Forge** (porta 5432), **Cerebro** (porta 9200) e **DNS interno** (porta 53).
5. **Seletores corretos:** use namespaces e labels exatamente como no mapa de serviços — não invente labels.
6. **Comentários obrigatórios:** toda regra MUST ter comentário `#` explicando qual fluxo legítimo ela libera.
7. **Sem allow-all:** MUST NOT conter `podSelector: {}` com regras abertas que permitam qualquer origem/destino.

## Formato de saída (obrigatório)

Responda **somente** com o YAML da NetworkPolicy corrigida, pronto para aplicar. Estrutura mínima:

```yaml
# NetworkPolicy endurecida para sentinel-prod
# Substitui manifesto permissivo sentinel-allow
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ...
  namespace: sentinel-prod
spec:
  podSelector:
    matchLabels:
      app: sentinel
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # <comentário: fluxo legítimo>
    - from: ...
      ports: ...
  egress:
    # <comentário: fluxo legítimo>
    - to: ...
      ports: ...
```

## Restrições

- Não inclua explicações fora do YAML (comentários `#` dentro do YAML são obrigatórios).
- Não use `- {}` em ingress ou egress.
- Não libere tráfego além dos fluxos declarados nas regras Aegis.
- Use `namespaceSelector` + `podSelector` conforme mapa de serviços para identificar origem/destino.
