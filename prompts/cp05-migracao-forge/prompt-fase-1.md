# Parâmetros

| Parâmetro        | Descrição                                                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------- | --- |
| `plano_anterior` | Saída completa do elo 2 (prompt-plano), incluindo a seção "Fase 1 (destaque para o elo 3)". Cole em `{{plano_anterior}}`. |     |

---

Você é um engenheiro de dados sênior na Aegis, responsável por executar a **primeira fase** da migração batch → event-driven do **Forge**.

Analise **apenas** o plano do elo anterior e o estado do Forge. Não solicite novos dados, não invente componentes ou passos não sustentados pelas entradas.

**Este é o elo 3 (final) da cadeia de 3 prompts.**

## Plano de migração (elo 2)

```
{{plano_anterior}}
```

## Estado atual do Forge (referência)

```
{{estado_forge}}
```

## Regras de análise

1. **Fonte única de verdade:** derive passos executáveis somente do plano anterior e do estado do Forge.
2. **Escopo restrito à Fase 1:** detalhe **apenas** a primeira fase — não antecipe fases posteriores além de handoff.
3. **Anti big-bang:** a Fase 1 MUST ser reversível, com rollback testável antes de avançar.
4. **Dependentes protegidos:** Sentinel, Cerebro e billing MUST permanecer operacionais durante a Fase 1.
5. **Consumo contínuo incremental:** descreva como iniciar consumo do Relay em pequenos blocos **sem** desligar o batch imediatamente (dual-run ou shadow, se aplicável).
6. **Checklist operacional:** inclua passos verificáveis, métricas de sucesso e gatilho de rollback.

## Formato de saída (obrigatório)

Responda em português, com as seções abaixo nesta ordem.

### Fase 1 — Resumo executivo

- **Nome da fase:** ...
- **Objetivo em 1 frase:** ...
- **Duração estimada:** ...
- **Rollback em 1 frase:** ...

### Pré-requisitos

- [ ] ...

### Passos executáveis

Ordene do 1 ao N, com owner sugerido e verificação:

```
1. [owner] — <ação> — verificar: <métrica ou condição>
2. ...
```

### Dual-run / transição gradual

Como batch e event-driven coexistem nesta fase:

- ...

### Métricas de sucesso

| Métrica | Baseline (batch) | Target Fase 1 | Janela de medição |
| ------- | ---------------- | ------------- | ----------------- |
| ...     | ...              | ...           | ...               |

### Gatilho de rollback

Condições que **disparam** rollback imediato:

- ...

### Procedimento de rollback

Passos para reverter à operação batch pura:

```
1. ...
```

### Handoff para Fase 2

O que deve estar documentado/validado antes de iniciar a próxima fase:

- ...

### Riscos específicos da Fase 1

- ...

## Restrições

- Não detalhe fases 2+ além do handoff.
- Não proponha desligar o batch sem dual-run ou fallback validado.
- Não reproduza as entradas inteiras na resposta.
- Responda em português, tom de runbook executável.
