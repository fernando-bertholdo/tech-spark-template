# Dry-run de propagação — TECH-566 · `SYNC-20260914-001`

**Origem:** `tech-product-template` @ `cf18030` (PR #23, TECH-531), versão 2.13.0
**Alvo:** `tech-spark-template`, base `e4d3b0b`
**Data:** 2026-09-14
**Nada foi aplicado.** Este arquivo é o diff inteiro deste PR.

## Por que dry-run

O resource deste repositório carrega o token `template-fonte` no label do workspace: variante
deliberada da origem, e a mais lite da família. A skill `propagar-template`, passo 2, manda
dry-run obrigatório nesse caso.

Na rodada anterior (`PROPAGACAO-DRY-RUN.md`, TECH-548, ainda em PR aberto) o delta era **neutro
de classe** e a recomendação foi adotar. Este é o caso oposto, e é o único das três variantes em
que a recomendação é **não adotar**.

## O delta da rodada

`SYNC-20260914-001` — registro de horizontes de escopo. Na origem:

| Arquivo | O quê |
|---|---|
| `documents/strategy/scope-horizons.md` | documento novo: living doc Tier 1 |
| `{.claude,.codex,.agents}/skills/scope-horizons/SKILL.md` | skill de dois modos: `capture` e `review` |
| `.claude/CLAUDE.md` §1.7 | linha na tabela de destinos do registro contínuo |
| `.claude/CLAUDE.md` §1 | `scope-horizons review` no bloco "Ao completar uma fase" |
| `AGENTS.md` | seção "Horizonte de escopo — a ideia que ainda não é trabalho" |
| `documents/README.md`, `documents/strategy/README.md` | índice, Tier 1 e exceção à salvaguarda |

## O gap medido aqui

    $ grep -rl scope-horizons . --exclude-dir=.git
    (nenhum arquivo)

Gap total — e, diferente das outras duas variantes, **nenhuma das âncoras existe**:

| A origem precisa de | Existe aqui? |
|---|---|
| `documents/` | não — o repositório inteiro é `Projeto.md`, `FUTURE_WORK.md`, `src/`, `tests/`, `scripts/` |
| `documents/strategy/` | não |
| tabela de destinos do registro contínuo (§1.7) | não — o `CLAUDE.md` daqui tem 7 seções, nenhuma delas de registro |
| bloco "Ao completar uma fase" | não — não há fases; o `CLAUDE.md` §1 é "Trabalho em sessões" |
| `AGENTS.md` de governança | não |
| living doc Tier 1 | não — o conceito de Tier não existe neste template |

O `Projeto.md` da raiz tem cinco seções: Visão, Stack, Decisões-chave, Como rodar, Changelog.
Não há onde a linha de roteamento cair sem inventar seção.

## Recomendação: **não adotar**

O critério sai do que este template declara sobre si no `FUTURE_WORK.md` da família: serve a
"projeto pequeno, poucas horas, sem defesa", combate **"overhead de processo em trabalho de uma
sessão"**, e não serve a "trabalho que precisa sobreviver a semanas".

Um registro de horizontes pressupõe três coisas que um spark não tem: um **produto** cujo escopo
se possa ampliar, um **plano** do qual a ideia esteja fora, e um **fim de fase** onde o veredito
seja dado. O segundo teste de admissão da skill — "está fora do plano" — é inaplicável num
repositório que não tem plano por design.

E já existe o endereço certo para a ideia que aparece no meio do caminho: o **`FUTURE_WORK.md`**
da raiz, que o template protege com "esta seção não pode ser removida sem decisão explícita
registrada em Decisões-chave". Ele guarda direção reconhecida e não construída — que é
literalmente o que um horizonte é, sem o aparato de living doc, skill e gate.

**O caminho de promoção cobre o resto.** O próprio `FUTURE_WORK.md` descreve a `promote-to-tpt`:
projeto spark que cresce a ponto de precisar de registro de horizontes é projeto que passou do
ponto de ser spark, e o que ele precisa é da promoção inteira, não de uma skill avulsa.

**Custo de não adotar:** nenhum que o `FUTURE_WORK.md` não cubra.

**Custo de adotar:** seis âncoras inventadas num template cujo inimigo declarado é exatamente
esse tipo de invenção.

## O que este PR NÃO faz

- Não aplica nada. Nenhum arquivo além deste foi tocado.
- Não toca o `PROPAGACAO-DRY-RUN.md` da rodada anterior (TECH-548), que segue em PR aberto. Os
  dois relatórios têm nome próprio e não conflitam.
- Não grava o marcador `Template de origem: tech-product-template@2.13.0` — nada foi
  sincronizado.
- Não instala `.github/workflows/ci.yml`.
