## 1. Redação do template de prompt

- [x] 1.1 Redigir (via meta-prompting ou curadoria manual) o texto do prompt em `prompts/cp01-triagem-de-pods/prompt.md`; verificar `{{snapshot_cluster}}` e seções de saída fixas
- [x] 1.2 Documentar parâmetro `snapshot_cluster` no topo de `prompt.md`; validar constraints (anti-alucinação, restart antigo, evidências) contra critérios do enunciado

## 2. Template de entrega e publicação

- [x] 2.1 Criar `prompts/cp01-triagem-de-pods/entrega.md` com seções vazias: Modelo, Execução (Entradas 1–3), Curadoria — sem outputs preenchidos
- [x] 2.2 Verificar que `registry/devops/` permanece sem prompts do playbook e que nenhum `.env`/secret de API foi adicionado

## 3. Finalização

- [x] 3.1 Revisar checklist: apenas templates presentes, nenhuma execução automatizada no repositório
- [ ] 3.2 Commit semântico `feat(prompts): adiciona template CP01 triagem de pods`
