# Dry-run de propagação — TECH-548

**Origem:** `tech-product-template` @ `b0be05c` (PR #24, TECH-529)
**Alvo:** `tech-spark-template`, base `e4d3b0b`
**Data:** 2026-09-14
**Nada foi aplicado.** Este arquivo é o diff inteiro deste PR.

## Por que dry-run

O resource deste repositório carrega o token `template-fonte` no label do workspace: ele
não é um projeto derivado em andamento, é **variante deliberada** da origem, em geral mais
lite que ela. A skill `propagar-template`, passo 2, manda dry-run obrigatório nesse caso,
com a adoção marcada como decisão humana. A regra é incondicional — vale mesmo quando o
delta é neutro de classe, como este é.

## O delta da rodada

O push que disparou a propagação não tocou `.claude/`, `.codex/` nem `.agents/`. Ele
mudou dois arquivos de raiz:

| Arquivo na origem | Commit | O quê |
|---|---|---|
| `.gitignore` | `75d0f40` | acrescenta `.claude/worktrees/` à seção de artefatos de runtime |
| `KICKOFF_GUIDE.md` | `dbe4432` | o Passo 6 troca `git add -A` por `git add -u` + `git status --short`, com aviso |

⚠️ **Nenhum dos dois tem Sync-ID.** Os changelogs locais das três camadas não têm onde
registrar mudança de arquivo de raiz, então o `sync-downstream --all` não enxerga este
delta. A descoberta desta rodada foi por leitura de estado. É o mesmo defeito que a
TECH-471 consertou para o `SYNC-20260912-001`, entrando por outra porta.

## O que se aplicaria aqui

### Gap 1 — `.claude/worktrees/` ausente do `.gitignore`

Medido: `grep -c worktrees .gitignore` devolve `0`. A seção que o receberia já existe,
com `.multica/`, `.agent_context/`, `/CLAUDE.md` e `.claude/skills/multica-*/`.

O diretório nasce não-rastreado a cada sessão do Claude Code que isola trabalho em worktree.
Sem a linha ele derruba o pré-voo de árvore limpa que todo run de agente faz, e produz acerto
falso em varredura que lê o working tree em vez de `git ls-files`.

**Este delta é neutro de classe.** Não carrega milestone, DoR/DoD, iniciativa nem nada da
classe completa — é higiene de artefato de runtime, e vale igual num repositório lite.

### Gap 2 — `KICKOFF_GUIDE.md` manda `git add .`

Medido: linha 33, no passo "Primeiro commit". É a mesma classe de defeito que a origem
consertou no Passo 6 dela, e a mesma contradição interna: o `.claude/CLAUDE.md` deste
repositório proíbe `git add .` e `git add -A` em letra. Aqui o risco é maior que na origem,
porque o passo roda no repositório recém-instanciado, com artefato de runtime untracked no
checkout.

O texto da origem não desce como está — o guia daqui é mais curto e não tem o Passo 6 em
seis linhas. A correção equivalente seria `git add -u` mais a entrada nominal do arquivo
novo, adaptada ao formato local. **Também não aplicada.**

## Recomendação

**Adotar os dois, em PRs separados.**

O **gap 1** não toca a fronteira que o passo 2 existe para proteger: não traz conteúdo de
classe completa, não altera skill nenhuma, e a seção que o recebe já está aqui.

O **gap 2** é correção de contradição interna deste repositório, não importação de conteúdo
da origem — o `.claude/CLAUDE.md` daqui já proíbe `git add .`, e o guia manda fazê-lo. Vale
por si, com ou sem propagação, e por isso pede PR próprio em vez de viajar junto.

A adoção é do Fernando nos dois casos; este relatório não a executa.

## O que este PR NÃO faz

- Não aplica o delta. O `.gitignore` não foi tocado.
- Não grava o marcador `Template de origem: tech-product-template@2.12.0` — nada foi
  sincronizado, e marcador de versão não recebida faz a próxima propagação calcular o gap
  errado (passo 4 da skill).
- Não instala `.github/workflows/ci.yml`.
