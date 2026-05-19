---
name: agent-team
description: Orquestra múltiplos agentes Claude Code para trabalho paralelo quando uma tarefa tem 3+ subtarefas independentes (sem dependência entre si). Use ao planejar pesquisa exploratória que se beneficia de paralelização ou ao implementar features que tocam arquivos diferentes sem conflito.
---

# agent-team (lite)

Orquestração multi-agente dentro do Claude Code. Versão adaptada para projetos `tech-spark-template` (sem milestones/Roadmap; planejamento mora em `plan.md` ou em seção dedicada de `Projeto.md`).

## Regra de Ouro

> **"Lead coordena e commita. Teammates implementam e reportam. Ninguém edita docs core."**

## Quando usar

**SIM:**
- 3+ subtarefas independentes (sem dependência sequencial)
- Pesquisa + implementação em fases paralelizáveis
- Tasks que tocam arquivos diferentes sem conflito de merge
- Code review com múltiplos revisores (segurança, performance, cobertura)

**NÃO:**
- Tarefas simples (<100 linhas, 1-2 arquivos)
- Dependência sequencial forte entre subtarefas
- Decisões arquiteturais incrementais que precisam diálogo com o usuário
- Quando o escopo está ambíguo (resolver ambiguidade primeiro)

## Níveis

### Nível 1 — Parallel Research (Haiku)

Pesquisa paralela antes de implementar. Use para validar abordagem, identificar riscos e comparar alternativas. Researchers só leem; quem decide é o Lead.

```
Lead (Opus/Sonnet): coordena, sintetiza, decide
├── Researcher A (Haiku): analisa codebase e padrões existentes
├── Researcher B (Haiku): pesquisa abordagens e best practices
└── Researcher C (Haiku): identifica riscos e edge cases
```

**Workflow:**
1. Lead lê `plan.md` (ou seção relevante de `Projeto.md`) e define 2-3 perguntas independentes
2. Spawna researchers em paralelo (read-only)
3. Sintetiza findings em uma recomendação de approach
4. Apresenta ao usuário; após aprovação, escala para Nível 2 ou implementa diretamente

### Nível 2 — Parallel Sprint (Sonnet)

Tasks independentes implementadas em paralelo. Cada teammate trabalha em arquivos disjuntos. Use quando o escopo já está definido e há 3+ entregas autocontidas.

```
Lead (Opus/Sonnet, delegate mode): distribui tasks, valida, commita
├── Implementer (Sonnet): implementa módulos designados
├── Tester (Sonnet): escreve testes para módulos prontos
└── Reviewer (Haiku): review read-only de código + segurança
```

**Workflow:**
1. Lead lê `plan.md` (ou seção de `Projeto.md`) e mapeia tasks → arquivos (zero overlap)
2. Ativa delegate mode (Shift+Tab)
3. Spawna teammates com tasks e arquivos designados
4. Implementers/Tester trabalham em paralelo; Reviewer reporta findings
5. Lead valida resultado, organiza commits atômicos e atualiza docs

### Nível 3 — Full Pipeline (mix)

Sprint completo com fases sequenciais e paralelismo interno. Use para entregas maiores que combinam research, implementação, qualidade e documentação.

```
Lead (Opus, delegate mode): orquestra todas as fases

Fase 1 — Research (paralelo, Haiku)
Fase 2 — Implementation (paralelo, Sonnet); Tester inicia quando módulos prontos
Fase 3 — Quality (Lead, sequencial): rodar testes/lint/security antes do commit
Fase 4 — Documentation (Lead, sequencial): invocar update-projeto e reportar
```

**Workflow:**
1. Lead executa Fase 1 e apresenta approach ao usuário
2. Após aprovação, executa Fase 2 monitorando via task list
3. Fase 3 consolida e roda gates de qualidade
4. Fase 4 atualiza `Projeto.md` via `update-projeto` e reporta resultado final

## Regras de segurança

**Teammates NÃO podem:**
- `git commit`, `git add` ou `git push` (só o Lead comita)
- Editar `Projeto.md` (single source of truth — Lead only)
- Editar `FUTURE_WORK.md`
- Invocar skills de documentação (ex.: `update-projeto`) — Lead only

**Teammates PODEM:**
- Ler qualquer arquivo do projeto (incluindo `Projeto.md` e `plan.md`)
- Criar/editar código nos diretórios designados (ex.: `src/`, `tests/`)
- Executar testes e linters
- Reportar findings ao Lead via mensagem final

### Prevenção de conflitos de arquivo

Cada teammate trabalha em **conjunto disjunto de arquivos**. Se overlap for inevitável, serialize — não paralelize.

```
# CORRETO
Implementer A → src/module_a/file_a.ext, src/module_a/file_b.ext
Implementer B → src/module_b/file_c.ext
Tester        → tests/test_module_a.ext, tests/test_module_b.ext

# ERRADO
Implementer A → src/module_a/file_a.ext
Implementer B → src/module_a/file_a.ext  ← CONFLITO
```

## Diferenças vs `tech-product-template`

- Sem refs a `Roadmap.md`, `TODO.md` ou `documents/core/` (não existem aqui)
- "Milestone scope" substituído por **`plan.md` ou seção em `Projeto.md`**
- Restrições referenciam `Projeto.md` na raiz do projeto
- Sem `init-milestone`, `validate-dor`, `validate-dod` no pipeline
- `update-docs` substituído por `update-projeto`
- Sem refs a `.codex/` ou `.agents/`
- Sem spawn templates separados — orientação inline neste arquivo

## Spawn prompt — incluir no Task tool

Ao invocar subagente via Task tool, mandar no prompt:

1. **Goal** (extraído de `plan.md` ou de seção em `Projeto.md`)
2. **Arquivos designados** (lista exata, para evitar conflitos)
3. **Restrições explícitas:** "Não comita. Não edita `Projeto.md`. Não edita `FUTURE_WORK.md`. Reporta findings ao final."
4. **Deliverable esperado** (o que reportar de volta ao Lead)

### Exemplo — Researcher (Nível 1)

```
Você é um Researcher (read-only).

Goal: investigar como o módulo X é estruturado hoje, comparar com 2 abordagens
alternativas (A vs B), e listar riscos/edge cases.

Contexto: ler `Projeto.md` (raiz) e `plan.md` (se existir) para entender escopo.

Arquivos permitidos: leitura em todo o projeto. Sem edição.

Restrições: NÃO comita. NÃO edita nenhum arquivo. Apenas pesquisa e reporta.

Deliverable: mensagem final com (a) sumário das abordagens, (b) trade-offs,
(c) riscos identificados, (d) recomendação preliminar.
```

### Exemplo — Implementer (Nível 2)

```
Você é um Implementer.

Goal: implementar a task T01 descrita em `plan.md` seção "Tarefas".

Arquivos designados (exclusivos seus):
- src/module_a/feature_x.py
- src/module_a/helpers.py

Restrições: NÃO comita. NÃO edita `Projeto.md` nem `FUTURE_WORK.md`. NÃO toca
em outros diretórios. Rode os testes existentes (`pytest tests/unit/module_a/`)
antes de finalizar.

Deliverable: mensagem final com (a) arquivos modificados, (b) decisões técnicas
relevantes, (c) saída dos testes locais, (d) qualquer ambiguidade encontrada.
```

## Delegate mode

Ativar com **Shift+Tab** após criar a equipe. O Lead fica restrito a:
- Spawnar e gerenciar teammates
- Distribuir e acompanhar tasks
- Revisar e aprovar entregas
- Consolidar resultados e commitar

Usar quando a equipe tem 3+ teammates, para evitar que o Lead implemente em vez de coordenar.

## Monitoramento

- **Ctrl+T**: alternar task list (ver progresso)
- **Shift+Up/Down**: navegar entre teammates
- **Enter** sobre teammate: abrir sessão do teammate
- **Escape**: interromper turn do teammate

| Sinal | Ação |
|-------|------|
| Teammate parado há muito tempo | Mensagem perguntando status |
| Task marcada completa sem evidência | Pedir saída de testes/logs |
| Teammate editando arquivo fora do escopo | Interromper (Escape) e redirecionar |
| Conflito de arquivo detectado | Parar teammates, resolver, redistribuir |

## Changelog

### v1.0.0 (spark)

- Versão lite adaptada de `tech-product-template/agent-team` v1.1.0
- Removidas refs a Roadmap/TODO/`documents/core/` e ao ciclo de milestones
- Planejamento alinhado a `plan.md` + `Projeto.md` (raiz)
- Sem spawn templates separados — exemplos inline
