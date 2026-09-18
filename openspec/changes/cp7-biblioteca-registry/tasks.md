## 1. Pré-requisitos

- [ ] 1.1 Verificar que `prompts/cp01-*` até `cp06-*` existem (apply CP1–CP6 concluído); abortar checklist se faltar origem

## 2. Migração para registry/devops/

- [ ] 2.1 Migrar CP01 → `registry/devops/triagem-de-pods/` (prompt.md + README.md + frontmatter v1.0.0) como **exemplo canônico completo**
- [ ] 2.2 Migrar CP02 → `nota-de-triagem/`
- [ ] 2.3 Migrar CP03 → `causa-raiz-cerebro/`
- [ ] 2.4 Migrar CP04 → `backpressure-relay/`
- [ ] 2.5 Migrar CP05 → `migracao-forge-diagnostico/`, `migracao-forge-plano/`, `migracao-forge-fase-1/`
- [ ] 2.6 Migrar CP06 → `networkpolicy-sentinel/`, `networkpolicy-sentinel-verificacao/`
- [ ] 2.7 Validar que cada `inputs` do frontmatter corresponde aos `{{placeholders}}` do corpo

## 3. Índices e documentação

- [ ] 3.1 Atualizar `registry/devops/README.md` com lista dos 9 prompts
- [ ] 3.2 Atualizar `registry/README.md` na seção DevOps
- [ ] 3.3 Criar `registry/docs/mapeamento-playbook.md` com tabela CP→slug e relação prompts/ vs registry/

## 4. Finalização

- [ ] 4.1 Confirmar ausência de `promptfooconfig.yaml` e API keys
- [ ] 4.2 Commit `feat(devops): migra playbook CP01-CP06 para registry`
