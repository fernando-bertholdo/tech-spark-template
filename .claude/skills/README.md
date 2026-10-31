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

---

## Duas camadas de instrução

Desde 2026-08-31 este template mantém as skills de `.claude/` e `.agents/` **pareadas**:
as 8 skills e o índice delas existem nas duas camadas, para os harnesses que leem
`.agents/` em vez de `.claude/`. O ponto de entrada é o par `.claude/CLAUDE.md` ↔
`.agents/README.md` — mesmo papel, nomes que cada harness impõe. As 2 rules vivem só em
`.claude/rules/` desde 2026-10-31: a cópia em `.agents/rules/` não tinha leitor
automático, e o ponto de entrada da camada `.agents/` aponta para a cópia única.

O pareamento é um invariante, não um instantâneo: `scripts/validate/check-pareamento-instrucoes.sh`
roda em CI e falha se um homônimo divergir sem declaração, se um arquivo existir só
numa camada sem declaração, se uma declaração ficar obsoleta, ou se um arquivo voltar a
`.agents/rules/`. Divergência legítima vive em `scripts/validate/pareamento-instrucoes-excecoes.txt`,
sempre com motivo.

**Consequência prática ao editar:** as duas camadas mudam no mesmo commit. Um par
declarado `divergencia` não sai da comparação: só sai o que as linhas `trecho` e `secao`
dele declaram, e o resto é comparado byte a byte. Alterar uma camada e esquecer a outra
fora desses trechos reprova o gate. Ficam fora do gate os dois pontos de entrada, que
mudam juntos por disciplina, e o literal que um `trecho` declara.

## Changelog Local

| Data | Commit | Sync-ID | Arquivo | Descrição |
|------|--------|---------|---------|-----------|
| 2026-05-19 | — | — | (criação inicial — 8 skills) | Inicializa as skills do tech-spark-template |
| 2026-08-31 | `90f715b` | SYNC-20260831-001 | `organize-commits/SKILL.md` | Corrige a referência ao arquivo de regras sempre-ativas, que apontava para uma seção "Commit Strategy" inexistente |
| 2026-08-31 | `7327ef6` | SYNC-20260831-001 | `bootstrap-spark/SKILL.md` | Kickoff passa a preencher os dois pontos de entrada e a preservar a linha de linhagem em ambos |
| 2026-08-31 | — | SYNC-20260831-001 | `README.md` | Registra as duas camadas e abre o changelog local |
| 2026-08-31 | — | SYNC-20260831-001 | `README.md`, `bootstrap-spark/SKILL.md` | Troca a afirmação de que alterar uma camada reprova o gate pela cobertura real dele, e faz o kickoff reprovar por placeholder remanescente em vez de invocar o gate |
| 2026-08-31 | — | SYNC-20260831-001 | `pre-commit-check/SKILL.md` | Acrescenta o gate de pareamento ao procedimento, aos bloqueadores e à checklist — antes o pareamento só reprovava depois do push, no CI |
| 2026-08-31 | — | SYNC-20260831-001 | `pre-commit-check/SKILL.md` | Tira a condição de caminho do gate de pareamento: ele passa a rodar em todo commit, porque editar só o arquivo de exceções reprova o gate sem tocar `.claude/` nem `.agents/` |
| 2026-08-31 | — | SYNC-20260831-001 | `README.md` | Troca a contagem fixa de pares dentro e fora da comparação byte a byte por descrição qualitativa: o número decaía em silêncio a cada exceção adicionada ou removida, sem gate que o validasse |
| 2026-08-31 | — | SYNC-20260831-001 | `pre-commit-check/SKILL.md` | Anota que o gate compara a árvore de trabalho, não o índice: com stage parcial ele valida algo diferente do que vai no commit |
| 2026-09-12 | — | SYNC-20260830-002 | `generate-session-prompt/SKILL.md`, `agent-team/SKILL.md` | Saem as duas citações órfãs ao arquivo de tarefas granulares que a origem aposentou e que este template nunca teve. Decisão de origem: `5818ee8` (TECH-126, DL-4 da TECH-106), em `tech-product-template@18fd32c`. Executado por TECH-215, sob a TECH-210 |
| 2026-10-31 | — | SYNC-20260920-001/002 | `pre-commit-check/SKILL.md`, `organize-commits/SKILL.md` | Seção 6 do `pre-commit-check`: varredura de quantificador e número sem fonte na mensagem, como aviso, sem o hook nem a varredura de diff da origem; `organize-commits` aponta para ela. TECH-1308 |
| 2026-10-31 | — | SYNC-20260920-001/002 | `fresh-context/SKILL.md`, `generate-session-prompt/SKILL.md` | A coleta lê a issue do trabalho quando há rastreador: descrição, checkboxes e comentários de topo. TECH-1308 |
| 2026-10-31 | — | — | `pre-commit-check/SKILL.md` | As Referências apontam `.claude/rules/code-quality.md` e `security.md`, em vez de três rules com nomes do template completo que este não tem. Achado do porte, sem par na origem. TECH-1308 |
| 2026-10-31 | — | — | `README.md` | "Duas camadas" diz que as rules vivem só em `.claude/rules/` e que o par `divergencia` é comparado fora do `trecho` declarado. Origem: TECH-852 e TECH-698 do `tech-product-template`, sem Sync-ID lá. TECH-1308 |
| 2026-10-31 | — | — | `bootstrap-spark/SKILL.md` | O `{{DATE}}` sai do calendário do fuso do dono (`TZ=… date`), como pede a nova §4 do ponto de entrada. TECH-1308 |
| 2026-10-31 | — | — | `bootstrap-spark/SKILL.md`, `pre-commit-check/SKILL.md`, `generate-session-prompt/SKILL.md` | Aparas da revisão do PR #10: o kickoff troca a linha do fuso do dono e tira dela o `{{DATE}}`; a varredura da seção 6 não acusa chave de issue nem nome de arquivo e entra no Checklist Rápido; `bootstrap-spark` e `generate-session-prompt` sobem para 1.1.0. TECH-1308 |

> Linhas com `—` na coluna Commit registram mudanças cujo commit é o próprio que edita
> esta tabela: o hash ainda não existe no momento da escrita. `git log -- <arquivo>`
> resolve a procedência sem o registro circular.

> **O Sync-ID de um delta recebido é o que a origem atribuiu a ele, não a data em que ele
> chegou aqui.** É o que permite responder por `grep <ID>` se este derivado recebeu um delta
> específico — e um ID cunhado pela data de aplicação faz esse `grep` mentir, porque colide com
> o ID que a origem usa para outro delta do mesmo dia. Foi o caso medido em 12/09/2026: o índice
> `001` daquela data já nomeia, na origem, o `--parent-issue` do `init-detour` (TECH-459). ID
> local só se cunha para porte sem ID upstream.
