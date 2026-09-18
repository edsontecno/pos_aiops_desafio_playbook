# Catálogo de prompts

Coleção de prompts em Markdown organizados por categoria/área de domínio. Cada prompt vive em sua própria pasta, contendo o arquivo `prompt.md` (texto puro, pronto para copiar e colar) e um `README.md` com metadados, variáveis e exemplos de uso.

Este repositório faz parte do material dos projetos da pós-graduação em AIOps e Inteligência Artificial com Engenharia Cloud: [pos.veronez.io/pos-aiops](https://pos.veronez.io/pos-aiops/).

Convenções de estrutura, nomenclatura e manutenção estão em [`CLAUDE.md`](./CLAUDE.md).

## Como usar

1. Navegar até a categoria de interesse.
2. Abrir o `README.md` do prompt para entender objetivo, variáveis esperadas e limitações.
3. Copiar o conteúdo do `prompt.md` e substituir os placeholders `{{nome_variavel}}` pelos valores desejados.

## Adicionando um prompt

Use o slash command [`/catalogar`](./.claude/commands/catalogar.md) passando o texto do prompt como argumento. Ele analisa, propõe organização (categoria, slug, frontmatter) e, após sua aprovação, escreve os arquivos e atualiza os índices — sem commitar. Convenções completas em [`CLAUDE.md`](./CLAUDE.md).

## Categorias

### [Desenvolvimento](./desenvolvimento/)

Escrita, revisão e refatoração de código, design de APIs e arquitetura, debugging, testes e documentação técnica.

_Nenhum prompt cadastrado ainda._

### [DevOps](./devops/)

Pipelines de CI/CD, containers, orquestração, infraestrutura como código, observabilidade, SRE e segurança operacional.

- [triagem-de-pods](./devops/triagem-de-pods/) — Analisa snapshot kubectl e identifica pods problemáticos no namespace Sentinel
- [nota-de-triagem](./devops/nota-de-triagem/) — Converte alerta cru em nota padronizada de handoff entre plantonistas
- [causa-raiz-cerebro](./devops/causa-raiz-cerebro/) — Diagnostica degradação no Elasticsearch correlacionando config, métricas e logs
- [backpressure-relay](./devops/backpressure-relay/) — Compara estratégias de backpressure no Relay respeitando SLAs e zero perda
- [migracao-forge-diagnostico](./devops/migracao-forge-diagnostico/) — Diagnostica estado batch atual do Forge e riscos antes da migração event-driven
- [migracao-forge-plano](./devops/migracao-forge-plano/) — Elabora plano incremental batch→event-driven com fases reversíveis
- [migracao-forge-fase-1](./devops/migracao-forge-fase-1/) — Detalha runbook executável da primeira fase da migração batch→event-driven
- [networkpolicy-sentinel](./devops/networkpolicy-sentinel/) — Gera NetworkPolicy endurecida default-deny para sentinel-prod
- [networkpolicy-sentinel-verificacao](./devops/networkpolicy-sentinel-verificacao/) — Revisa NetworkPolicy candidata com checklist de segurança Kubernetes

### [Produtividade](./produtividade/)

Organização pessoal, gestão de tempo e tarefas, rotina, hábitos, foco e decisões sobre fluxo de trabalho individual.

_Nenhum prompt cadastrado ainda._

### [Finanças](./financas/)

Orçamento, investimentos, planejamento financeiro, impostos e apoio a decisões financeiras.

_Nenhum prompt cadastrado ainda._

### [Criação de Conteúdo](./criacao-conteudo/)

Roteiros, artigos, posts para redes sociais, material didático e copy de divulgação.

_Nenhum prompt cadastrado ainda._

<!--
Ao adicionar um prompt, substituir "Nenhum prompt cadastrado ainda" pela lista:

- [nome-do-prompt](./<slug-da-categoria>/<slug-do-prompt>/) — o que o prompt faz, em uma linha.
-->

## Contribuindo

Antes de adicionar ou alterar um prompt, revisar [`CLAUDE.md`](./CLAUDE.md) — a seção **Manutenção da documentação** lista todos os arquivos que precisam ser atualizados junto com a mudança (este índice incluso).
