# Claude Code - Regras do Projeto {{PROJECT_NAME}}

Regras operacionais sempre ativas para `{{PROJECT_NAME}}` (baseado em `tech-spark-template`).

> **Single source of truth:** [Projeto.md](../Projeto.md) na raiz. Regras path-targeted em `.claude/rules/`. Skills em `.claude/skills/`.

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
- Para pesquisa exploratória extensa ou análise multi-arquivo: dispatch para subagente via Task tool

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

### Horas e datas

**Fuso do dono:** `America/Sao_Paulo`, rótulo `BRT`. Projeto cujo dono vive em outro fuso troca esta linha no kickoff, e só ela.

- **Texto para gente** (resposta, handoff, `Projeto.md`, changelog): a hora sai de `TZ=<fuso do dono> date '+%d/%m/%Y %H:%M %z'`, medida logo antes de escrever, com o rótulo: `18:41 BRT`. O `%z` confere a zona.
- **Hora que vai ser cruzada com carimbo de API** (GitHub, git), que vem em UTC: o UTC vai ao lado, `18:41 BRT (21:41Z)`, com a data dia/mês quando ele cai em outro dia.
- **Carimbo de máquina** (log, JSON, nome de arquivo gerado): UTC com `Z`.
- **Segundos** só entram copiados de um carimbo de máquina, com a zona dele. **Hora sem zona é defeito.**

---

## 5. Segurança e fidelidade de dados

Dois casos opostos, não graus do mesmo caso:

**Segredo** (credencial, token, chave, senha): NUNCA commitar, sem exceção. Num repositório privado ele continua sendo risco, porque quem obtém o repositório ganha a capacidade de agir.

Checklist mínimo:
- [ ] Sem secrets hardcoded
- [ ] `.env` no `.gitignore`
- [ ] `.env.example` sanitizado
- [ ] Logs não expõem credenciais

**Dado de trabalho** (o registro, documento ou medição que o projeto processa): viaja exatamente como medido, rastreável à fonte. Arredondar, parafrasear, redigir ou trocar por equivalente quebra a conferência sem avisar quem lê depois; transformação necessária é declarada, com o caminho de volta ao valor de origem. Quando o projeto processa dado de terceiro, quem detém o dado e sob que autorização vai em Decisões-chave do `Projeto.md`; sem esse registro, trate dado de terceiro com cautela e registre a lacuna.

Ver [rules/security.md](rules/security.md) para detalhes path-targeted.

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
- [rules/code-quality.md](rules/code-quality.md) — path-targeted (src/**/*, *.py)
- [rules/security.md](rules/security.md) — path-targeted (src/**/*, .env*)
- [skills/README.md](skills/README.md) — índice das 8 skills

---

**Versão:** 1.1.0
**Última atualização:** {{DATE}}
**Autor:** {{AUTHOR_NAME}}

**Changelog v1.1.0 (31/10/2026, porte neutro de classe do `tech-product-template@06cee39`, 2.21.1; TECH-1308):**
- §4 ganha "Horas e datas", com o fuso do dono numa linha que o kickoff troca
- §5 separa segredo (nunca entra) de dado de trabalho (viaja exato, com a base declarada em Decisões-chave)
- As rules vivem só em `.claude/rules/`; o gate de pareamento compara o par `divergencia` fora do `trecho` declarado
- CI: invariantes reprovam por linha; testes Python pulam sem teste e não escondem o `pip`
- Skills: o handoff lê a issue do rastreador; a mensagem de commit é varrida por quantificador e número sem fonte
- Não entram, por não serem spark: registro de horizontes, hooks, processo de iniciativa, `AGENTS.md` e `.codex/`
