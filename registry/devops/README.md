# DevOps

Prompts voltados a **infraestrutura, automação e operação** de sistemas: pipelines de CI/CD, containers, orquestração, provisionamento, observabilidade, confiabilidade e segurança operacional.

## Escopo

Entram aqui prompts relacionados a:

- Pipelines de CI/CD (GitHub Actions, GitLab CI, Jenkins etc.).
- Containers e orquestração (Docker, Kubernetes, Helm).
- Infraestrutura como código (Terraform, Pulumi, Ansible).
- Provedores de nuvem (AWS, GCP, Azure) e seus recursos.
- Observabilidade (logs, métricas, tracing, alertas, dashboards).
- Confiabilidade, SRE, postmortems e análise de incidentes.
- Segurança operacional (hardening, secrets, políticas de acesso).

## Fora de escopo

- Escrita de código de aplicação → usar `desenvolvimento/`.
- Conteúdo educacional sobre DevOps (aulas, artigos, vídeos) → usar `criacao-conteudo/`.

## Prompts

Playbook Aegis — checkpoints 01 a 06 migrados para o registry (CP07):

- [triagem-de-pods](./triagem-de-pods/) — Analisa snapshot kubectl e identifica pods problemáticos no namespace Sentinel
- [nota-de-triagem](./nota-de-triagem/) — Converte alerta cru em nota padronizada de handoff entre plantonistas
- [causa-raiz-cerebro](./causa-raiz-cerebro/) — Diagnostica degradação no Elasticsearch correlacionando config, métricas e logs
- [backpressure-relay](./backpressure-relay/) — Compara estratégias de backpressure no Relay respeitando SLAs e zero perda
- [migracao-forge-diagnostico](./migracao-forge-diagnostico/) — Diagnostica estado batch atual do Forge e riscos antes da migração event-driven
- [migracao-forge-plano](./migracao-forge-plano/) — Elabora plano incremental batch→event-driven com fases reversíveis
- [migracao-forge-fase-1](./migracao-forge-fase-1/) — Detalha runbook executável da primeira fase da migração batch→event-driven
- [networkpolicy-sentinel](./networkpolicy-sentinel/) — Gera NetworkPolicy endurecida default-deny para sentinel-prod
- [networkpolicy-sentinel-verificacao](./networkpolicy-sentinel-verificacao/) — Revisa NetworkPolicy candidata com checklist de segurança Kubernetes

Referência canônica de estrutura e documentação: [`triagem-de-pods/`](./triagem-de-pods/).
