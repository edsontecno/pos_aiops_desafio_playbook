## Why

Após CP01–CP06, os prompts vivem em `prompts/` como templates de trabalho. O Checkpoint 07 exige transformar a coleção em **biblioteca versionada** seguindo o template [prompt-registry](https://github.com/fabricioveronez/prompt-registry) — frontmatter, `prompt.md` + `README.md`, índices e semver — tratada como código pelo time Aegis.

## What Changes

- Migrar todos os prompts de `prompts/cp01-*` … `prompts/cp06-*` para `registry/devops/<slug>/` com frontmatter `versao: 1.0.0`.
- Garantir cada pasta com `prompt.md` (frontmatter + corpo com `{{placeholders}}`) e `README.md` (mesmo frontmatter + objetivo, casos de uso, exemplo, limitações).
- Atualizar índices: `registry/README.md`, `registry/devops/README.md`.
- Criar `registry/docs/mapeamento-playbook.md` — nota curta CP01–CP06 → slugs do registry.
- Um prompt **completo como referência** (enunciado): `triagem-de-pods` como exemplo canônico; demais seguem o mesmo padrão.
- Manter `prompts/` como histórico de rascunho (não remover) ou documentar relação no mapeamento.
- **Não** executar prompts, **não** adicionar `promptfooconfig.yaml` (CP08), **não** configurar API keys (CP08).

## Capabilities

### New Capabilities

- `devops/prompt-registry`: Biblioteca de prompts DevOps do playbook Aegis no formato prompt-registry, migrada de `prompts/` com versionamento semver e documentação indexada.

### Modified Capabilities

- _(nenhuma spec principal ainda — primeira publicação no registry)_

## Impact

- **Origem:** `prompts/cp01-*` … `cp06-*` (pré-requisito: changes CP1–CP6 aplicados)
- **Destino:** `registry/devops/` (+ `registry/docs/mapeamento-playbook.md`)
- **Template base:** `registry/` já presente no repo (fork/clone do prompt-registry)
- **Fora de escopo:** promptfoo, CI, execução de modelos
