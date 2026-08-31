# Agent Skills — tech-spark-template (camada .agents/)

8 skills para projetos lite. Origem: tech-product-template (5 portadas com ajustes) + 2 novas + 1 adaptada.

## Índice

| Skill | Origem | Status | Uso |
|---|---|---|---|
| [organize-commits](organize-commits/SKILL.md) | portada do full | quase idêntica | Organizar mudanças em commits granulares |
| [pre-commit-check](pre-commit-check/SKILL.md) | portada do full | enxuta (sem DoR/DoD) | Checklist antes de cada commit |
| [fresh-context](fresh-context/SKILL.md) | portada do full | simplificada | Handoff entre sessões >150k tokens |
| [generate-session-prompt](generate-session-prompt/SKILL.md) | portada do full | só modo genérico | Retomar trabalho após pausa |
| [validate-testing](validate-testing/SKILL.md) | portada do full | opt-in/light | Sugerir cobertura de testes |
| [update-projeto](update-projeto/SKILL.md) | nova | substitui update-docs | Atualizar Projeto.md (decisões + changelog) |
| [agent-team](agent-team/SKILL.md) | adaptada do full | sem refs Roadmap/TODO | Orquestrar múltiplos agentes |
| [bootstrap-spark](bootstrap-spark/SKILL.md) | nova | 3 modos + idempotência | Kickoff guiado de projeto novo |

## Diferenças vs tech-product-template

**Removidas** (não aplicáveis a projetos lite):
- Initiative lifecycle: `init-milestone`, `init-detour`, `reconcile-initiative`, `archive-initiative`
- Validação de processo: `validate-dor`, `validate-dod`, `validate-kickoff`
- Strategy/planning pesado: `design-sprint`, `generate-tap`, `enhanced-planning`
- Auditoria: `audit-rules`, `audit-roadmap-refs`, `audit-architecture`, `validate-docs-links`
- Sync entre stacks: `mirror-upstream`, `sync-downstream`

**Mecanismo de sync entre os dois templates:** convenção manual (Sync-ID + diff manual). Sem auto-sync. Ver spec original em `tech-product-template/documents/superpowers/specs/2026-05-18-tech-spark-template-design.md`.

## Convenções

- Nomes em `kebab-case`
- `SKILL.md` obrigatório (uppercase)
- Frontmatter: `name`, `description`
- Body conciso (≤300 linhas idealmente)

---

## Duas camadas de instrução

Desde 2026-08-31 este template mantém `.claude/` e `.agents/` **pareados**: as 8
skills, as 2 rules e o índice de cada diretório existem nas duas camadas, para os
harnesses que leem `.agents/` em vez de `.claude/`. O ponto de entrada é o par
`.claude/CLAUDE.md` ↔ `.agents/README.md` — mesmo papel, nomes que cada harness impõe.

O pareamento é um invariante, não um instantâneo: `scripts/validate/check-pareamento-instrucoes.sh`
roda em CI e falha se um homônimo divergir sem declaração, se um arquivo existir só
numa camada sem declaração, ou se uma declaração ficar obsoleta. Divergência legítima
vive em `scripts/validate/pareamento-instrucoes-excecoes.txt`, sempre com motivo.

**Consequência prática ao editar:** as duas camadas mudam no mesmo commit — essa é a
disciplina, e o gate cobre só parte dela. O que ele barra é homônimo divergente **não
declarado** e arquivo solo **não declarado**; par já declarado `divergencia` e os dois
pontos de entrada, declarados `solo`, ficam fora da comparação byte a byte — hoje 8 dos
13 pares. Nesses 8, alterar uma camada e esquecer a outra passa em silêncio, e é a lista
versionada em `scripts/validate/pareamento-instrucoes-excecoes.txt` que torna essa cegueira
auditável: uma linha por exceção, sempre com motivo, e exceção obsoleta reprovando igual a
drift. Nos outros 5 pares a comparação é byte a byte — e é dela que vem o freio ao drift
que se acumulou no `tech-product-template`, onde 19 pares divergiram em seis meses sem
ninguém notar.

## Changelog Local

| Data | Commit | Sync-ID | Arquivo | Descrição |
|------|--------|---------|---------|-----------|
| 2026-05-19 | — | — | (criação inicial — 8 skills) | Inicializa as skills do tech-spark-template |
| 2026-08-31 | `5f5b281`, `6075bd9`, `c1f5a7e`, `7c6ca27`, `5d1c16a` | SYNC-20260831-001 | `fresh-context/`, `generate-session-prompt/`, `pre-commit-check/`, `update-projeto/`, `validate-testing/` | Espelha do `.claude/` as 5 skills que não referenciam mecanismo de harness — cópias byte a byte |
| 2026-08-31 | `b6f6df7` | SYNC-20260831-001 | `agent-team/SKILL.md` | Espelha a skill descrevendo as capacidades de forma agnóstica de harness, sem nome de ferramenta nem atalho de teclado |
| 2026-08-31 | `90f715b` | SYNC-20260831-001 | `organize-commits/SKILL.md` | Espelha a skill apontando para `.agents/README.md` como arquivo de regras sempre-ativas |
| 2026-08-31 | `7327ef6` | SYNC-20260831-001 | `bootstrap-spark/SKILL.md` | Espelha o kickoff, que passa a preencher os dois pontos de entrada |
| 2026-08-31 | `0e4215a` | SYNC-20260831-001 | `README.md` | Cria o índice da camada e registra as duas camadas |
