# Propagação 2026-09-03 — relatório de dry-run

**Origem:** `tech-product-template` @ `72e1800` (CLAUDE.md v2.12.0)
**Alvo:** `tech-spark-template` — variante de template, não projeto derivado
**Issue:** TECH-240 (issue-pai TECH-230)
**Modo:** `sync-downstream --dry-run`. **Nada foi aplicado.**

## Por que dry-run

O resource deste repositório carrega o token `template-fonte` além de
`derivado-de:tech-product-template`. Pelo passo 2 da skill `propagar-template`,
variante de template exige `--dry-run` obrigatório e PR só com o relatório:
propagar conteúdo de classe completa para uma variante deliberadamente mais lite
costuma ser errado, e a decisão é humana.

O gap bruto de Sync-ID não mede nada aqui. Este repositório tem gramática
própria, e 33 Sync-IDs da origem “faltarem” é consequência de ele ser uma
variante, não sintoma de atraso.

## Estado medido em 2026-09-03

- Camadas: `.claude/` e `.agents/`. Não há `.codex/`.
- 9 skills locais; 2 delas não existem na origem (`bootstrap-spark`, `update-projeto`).
- 22 das 28 skills da origem não existem aqui — a variante spark **não tem ciclo de iniciativa nenhum**, e isso é o desenho dela.
- 3 rules (`README.md`, `code-quality.md`, `security.md`) contra 8 na origem.
- Não existe `documents/core/TODO.md`. Não existe `scripts/INDEX.md`.
- Nenhuma instrução menciona o tipo `patch`.
- Nenhum stub do claude-mem.
- Marcador de linhagem: **ausente**.
- **É o único dos três repositórios-variante que tem `.github/workflows/ci.yml`.**

## A regra que domina este relatório

Classe SPARK **não tem DoR/DoD**. Os gates dela são `pre-commit-check` e `validate-testing`; o par `validate-dor`/`validate-dod` não existe aqui por decisão, não por atraso. Qualquer propagação que traga o ciclo de iniciativa da origem — `init-milestone`, `init-detour`, `validate-dor`, `validate-dod`, `reconcile-initiative`, `archive-initiative` — **contraria o desenho da variante**. É o caso mais claro de "propagar seria errado" de que fala o passo 2 da skill.

## O payload de 2026-09-03, item a item

| Sync-ID | Payload | Recomendação |
|---|---|---|
| `SYNC-20260903-001` | O `documents/core/TODO.md` sai das instruções (DL-4) | **Não propagar — já resolvido de outra forma.** Não existe `documents/core/TODO.md` aqui. As 2 referências que sobram no `.claude/` são resíduo de skills herdadas; se incomodarem, é apara local. |
| `SYNC-20260903-002` | Taxonomia por obrigação, sem o tipo `patch` | **Não propagar — não aplicável.** Nenhuma instrução daqui menciona `patch` nem `.planning/patches.md`. Mais que isso: a taxonomia `milestone`/`detour` que o texto da origem introduz **não existe em spark**, onde toda issue é avulsa. Propagar o texto criaria vocabulário que a variante não usa. |
| `SYNC-20260903-003` | Marcador de linhagem no ponto de entrada | **Propagar depois, em PR próprio.** Sem o marcador o repositório é lido como órfão de linhagem. Mas o passo 4 da `propagar-template` proíbe gravá-lo quando a sincronização fica em dry-run. O PR precisa gravar o marcador e só ele, com a versão que este repositório de fato herdou — que **não** é necessariamente `@2.12.0` — e nas duas camadas que existem (`.claude/` e `.agents/`), não em três. |
| `SYNC-20260903-004` | Triagem das divergências entre camadas + stubs do claude-mem | **Não propagar — quase tudo é inaplicável.** Detalhe abaixo. |

### Detalhe do `SYNC-20260903-004`

| Item da triagem | Situação aqui | Recomendação |
|---|---|---|
| pt-BR em `organize-commits` | já presente (6 ocorrências) | nada a fazer |
| pt-BR em `pre-commit-check` | já presente (5 ocorrências) | nada a fazer |
| Seção Scripts Governance em `pre-commit-check` | ausente — e **os pré-requisitos também**: não há `scripts/INDEX.md` nem a rule `scripts-governance.md` | **não propagar**: a seção referenciaria arquivos inexistentes |
| `design-sprint` no `generate-tap` e no índice | nenhuma das duas skills existe aqui | não aplicável |
| Profundidade do link em `validate-docs-links` | a skill não existe aqui | não aplicável |
| Reconciliação de `archive-initiative`, `audit-roadmap-refs`, `audit-architecture`, `validate-kickoff` | nenhuma dessas skills existe aqui | não aplicável |
| Correções de `security-best-practices.md` e `code-quality-standards.md` | as rules daqui são `security.md` e `code-quality.md`, com nome e conteúdo próprios | não aplicável |
| Remoção dos stubs do claude-mem | não existem aqui | nada a fazer |

## Conclusão

**Da propagação de 2026-09-03, nada deve ser aplicado neste repositório agora.**

O único item que merece um PR é o marcador de linhagem (`SYNC-20260903-003`), e ele exige antes uma decisão que não é da propagação: **qual versão da origem este repositório de fato herdou.** Sem essa resposta, gravar o marcador é pior do que não gravá-lo.

## Itens de ação para o Fernando

1. **Este repositório é ele próprio um template-fonte**, com derivados atribuídos a ele (`vai-facil`, `finance-copilot` carregam `derivado-de:tech-spark-template`). Uma propagação vinda do `tech-product-template` que mudasse a gramática daqui reverberaria neles. Vale decidir se o `tech-spark-template` deve continuar recebendo propagação automática da origem, ou se a relação passa a ser só de linhagem histórica.
2. O marcador de linhagem, quando for gravado, tem **duas** camadas de destino aqui, não três — não existe `.codex/`.
