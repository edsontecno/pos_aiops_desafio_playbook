## Why

Quando o Sentinel dispara um alerta, cada plantonista da Aegis escreve a nota de triagem do seu jeito — dificultando passagem de turno. O Checkpoint 02 exige um prompt parametrizável que transforme **alerta cru** em **nota padronizada** com cinco campos fixos, reutilizável no playbook de IA operacional.

## What Changes

- Adicionar **apenas o template** do prompt em `prompts/cp02-nota-de-triagem/prompt.md`.
- Parâmetro único `{{alerta_cru}}` documentado no template.
- Adicionar `prompts/cp02-nota-de-triagem/entrega.md` com os **três alertas crus** do enunciado já colados; **justificativa do método** com sugestão concisa (1 frase, máx. 3 linhas); outputs e curadoria para preenchimento manual.
- Incluir referência ao **formato de saída esperado** (5 rótulos) em comentário ou seção do template — separado das entradas de teste, conforme enunciado.
- **Não** executar prompts, **não** configurar API keys (convenção CP01–CP06).
- **Não** publicar em `registry/` (reservado ao CP07).

## Capabilities

### New Capabilities

- `devops/nota-de-triagem`: Template de prompt que converte alerta cru em nota de triagem padronizada (ALERTA, IMPACTO, HIPÓTESE INICIAL, AÇÃO IMEDIATA, ESCALAR PARA).

### Modified Capabilities

- _(nenhuma)_

## Impact

- **Arquivos novos:** `prompts/cp02-nota-de-triagem/prompt.md`, `prompts/cp02-nota-de-triagem/entrega.md`
- **Arquivos não alterados:** `registry/`, secrets, `.env`
- **Relacionado:** CP08 testará este prompt com asserts determinísticos (5 rótulos, `@handle`, ≤8 linhas)
