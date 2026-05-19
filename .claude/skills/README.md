# Agent Skills — tech-spark-template

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
| [agent-team](agent-team/SKILL.md) | adaptada do full | sem refs Roadmap/TODO | Orquestrar múltiplos agentes Claude Code |
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
