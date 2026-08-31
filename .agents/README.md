# .agents/ — Regras do Projeto {{PROJECT_NAME}}

Regras operacionais sempre ativas para `{{PROJECT_NAME}}` (baseado em `tech-spark-template`).

> **Single source of truth:** [Projeto.md](../Projeto.md) na raiz. Regras técnicas em `.agents/rules/`. Skills em `.agents/skills/`.

---

## 1. Trabalho em sessões

**Antes de começar:**
- Ler `Projeto.md` (decisões já tomadas, contexto atual)
- Ler `plan.md` na raiz se existir

**Durante:**
- Invocar `pre-commit-check` antes de cada `git commit`
- Se task tem >3 passos ou cruza sessões: criar/manter `plan.md` na raiz

**Depois:**
- Se decisão técnica importante foi tomada: invocar `update-projeto` para registrar em Decisões-chave + Changelog
- Se `plan.md` foi concluído: renomear para `.planning/scratch/<slug>-plan-DONE.md` e commitar

---

## 2. Context engineering

- **Sessão >150k tokens:** invocar `fresh-context` para gerar handoff em `.planning/scratch/`
- **Retomar após pausa ou trocar de ferramenta:** invocar `generate-session-prompt`
- **Antes de grep amplo:** ler `Projeto.md` primeiro (docs-first); só explorar se docs desatualizados
- Para pesquisa exploratória extensa ou análise multi-arquivo: dispatch para subagente

---

## 3. Agent teams (opcional)

Invocar `agent-team` quando tarefa tem **3+ subtarefas independentes** (sem dependência entre si), envolve pesquisa + implementação em fases distintas, ou toca arquivos diferentes sem conflito.

**Não usar** para tarefas simples (<100 linhas, 1-2 arquivos) ou sequenciais com forte dependência.

Versão lite da skill — sem refs a Roadmap/TODO/`documents/core/`. Restrições de teammates referenciam `Projeto.md` da raiz.

---

## 4. Princípios

- **Chunks gerenciáveis:** ~100 linhas por implementação. Quebrar funcionalidades complexas.
- **Explicar o "porquê":** decisões técnicas, trade-offs, alternativas consideradas — registrar em Decisões-chave do `Projeto.md`.
- **Validar contra requisitos:** testar com dados reais quando possível.

---

## 5. Segurança

**Regra de ouro:** NUNCA commitar secrets.

Checklist mínimo:
- [ ] Sem secrets hardcoded
- [ ] `.env` no `.gitignore`
- [ ] `.env.example` sanitizado
- [ ] Logs não expõem credenciais

Ver [rules/security.md](rules/security.md) para detalhes.

---

## 6. Commits

**Regra:** atômicos, conventional commits em **pt-BR**.

**Formato:** `<type>(<scope>): <assunto-em-pt-br>`

`type` e `scope` seguem padrão Conventional Commits. `subject` e `body` em pt-BR.

**Types:** feat, fix, docs, refactor, test, chore, perf, style, ci, build

**Scopes:** {{COMMIT_SCOPES}}

**Protocolo:**
1. NUNCA `git add .` ou `git add -A`
2. Stage arquivos individualmente por task
3. Máximo ~100 linhas por commit
4. Invocar `pre-commit-check` antes

**Atribuição:** sempre como trabalho do desenvolvedor; nunca mencionar assistentes de IA ou co-autoria com IA.

---

## 7. Referências

- [Projeto.md](../Projeto.md) — single source of truth
- [FUTURE_WORK.md](../FUTURE_WORK.md) — Promotion Path e direções futuras
- [rules/code-quality.md](rules/code-quality.md) — código-fonte (src/**/*, *.py)
- [rules/security.md](rules/security.md) — código-fonte e segredos (src/**/*, .env*)
- [skills/README.md](skills/README.md) — índice das 8 skills

---

**Versão:** 1.0.0
**Última atualização:** {{DATE}}
**Autor:** {{AUTHOR_NAME}}
