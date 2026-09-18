# CP08 — Resultados dos testes promptfoo (determinísticos)

> **Execução manual:** rode a suíte a partir de `registry/` com `npm install && npm run eval` (ou scripts individuais `npm run eval:nota`, `eval:triagem`, `eval:networkpolicy`). Configure `OPENAI_API_KEY` e `ANTHROPIC_API_KEY` em `.env` (copie de `.env.example`).

## Ambiente

| Campo | Valor |
| ----- | ----- |
| Data da execução | _(preencher)_ |
| Diretório de trabalho | `registry/` |
| Versão promptfoo | _(preencher — ex.: `npx promptfoo --version`)_ |
| Providers usados | `openai:gpt-4o-mini`, `anthropic:claude-3-5-haiku-20241022` |

## Resumo

| Prompt | Test cases | Pass | Fail | Observações |
| ------ | ---------- | ---- | ---- | ----------- |
| nota-de-triagem | 3 × 2 providers | _(preencher)_ | _(preencher)_ | |
| triagem-de-pods | 3 × 2 providers | _(preencher)_ | _(preencher)_ | |
| networkpolicy-sentinel | 1 × 2 providers | _(preencher)_ | _(preencher)_ | |

---

## nota-de-triagem

### Saída bruta (`promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml`)

```
(colar saída do terminal aqui)
```

### Curadoria

- **Passou:** _(listar asserts/casos que passaram)_
- **Falhou:** _(listar asserts/casos que falharam, se houver)_
- **Ajustes feitos:** _(alterações no prompt ou nos testes em resposta a falhas)_

---

## triagem-de-pods

### Saída bruta (`promptfoo eval -c devops/triagem-de-pods/promptfooconfig.yaml`)

```
(colar saída do terminal aqui)
```

### Curadoria

- **Passou:** _(preencher)_
- **Falhou:** _(preencher)_
- **Ajustes feitos:** _(preencher)_

---

## networkpolicy-sentinel

### Saída bruta (`promptfoo eval -c devops/networkpolicy-sentinel/promptfooconfig.yaml`)

```
(colar saída do terminal aqui)
```

### Curadoria

- **Passou:** _(preencher)_
- **Falhou:** _(preencher)_
- **Ajustes feitos:** _(preencher)_

---

## Notas operacionais

- **Frontmatter em `prompt.md`:** se o modelo receber metadados YAML indesejados, documente aqui e ajuste prompt ou config conforme necessário.
- **Trade-off latência/custo:** registre reprovações em `latency` ou `cost` e justifique escolha de modelo ou limiares.
