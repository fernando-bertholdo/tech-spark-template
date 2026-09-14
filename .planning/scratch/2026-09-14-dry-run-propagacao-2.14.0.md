# Dry-run — propagação de `tech-product-template@2.14.0` (TECH-589)

**Nada foi aplicado.** Este repositório carrega o token `template-fonte` nos resources do
workspace: é variante deliberada da origem, e o passo 2 da skill `propagar-template` manda
parar no relatório. A decisão de adotar, adaptar ou recusar cada item abaixo é humana.

## O que o delta 2.13.0 → 2.14.0 contém

| # | Item | Origem |
|---|---|---|
| 1 | A dívida de saída do detour vira pergunta de entrada em `init-detour`; a dimensão 4a.1 de `reconcile-initiative` passa a confrontar a resposta com o entregue | TECH-574 |
| 2 | Jargão de projeto derivado neutralizado nos exemplos de `validate-dor`, `validate-dod`, `fresh-context`, `generate-tap` | TECH-552 |
| 3 | `AGENTS.md` ganha a tabela de destinos do registro contínuo | TECH-552 |
| 4 | `.gitignore` ignora `.claude/worktrees/` | TECH-529 |
| 5 | Hook `check-planning-index.sh` + `settings.json` | TECH-574 |

## O que se aplicaria aqui — item a item

| # | Veredito | Por quê |
|---|---|---|
| 1 | **NÃO SE APLICA** | Este é o template da classe SPARK. Não existem `init-detour`, `reconcile-initiative`, `.planning/milestones/`, `.planning/detours/` nem `documents/core/Roadmap.md`. O delta inteiro é sobre a taxonomia de detour e a reconciliação com o Roadmap — vocabulário que esta classe **não tem por decisão de desenho**, não por atraso. Adotar por simetria instalaria em SPARK a estrutura que o `CLAUDE.md` do próprio template manda não inventar. |
| 2 | **PARCIAL — só `fresh-context`** | Das quatro skills, só `fresh-context` existe aqui. Medido nesta branch: `grep -rlE 'BTG|monitor-fundos' .claude` não devolve nada. O jargão **já não existe** neste repositório; não há o que neutralizar. |
| 3 | **NÃO SE APLICA** | Não há `AGENTS.md` de raiz no padrão do template, e a seção de destinos da origem roteia para `documents/core/Projeto.md`, `.planning/scratch/seed-*` e `documents/strategy/` — caminhos que a classe SPARK não tem. A regra equivalente aqui é o `update-projeto`, que já existe. |
| 4 | **APLICÁVEL, e é o único** | `.gitignore` não ignora `.claude/worktrees/`. É mecânico, neutro de classe e independente do resto do delta. **Não foi aplicado neste PR** porque o passo 2 da skill não abre exceção por tamanho de item; se o Fernando quiser, vale uma issue de uma linha. |
| 5 | **NÃO SE APLICA** | O hook lê `.planning/README.md` procurando iniciativa fora do índice. Aqui só existe `.planning/scratch/`. Além disso, `hooks/` e `settings.json` do derivado são locais dele por regra da própria skill (passo 5). |

## Achado que sai daqui

Sem marcador `Template de origem:` em nenhuma camada. A ausência é coerente com o que
este dry-run mede — não houve versão recebida —, mas significa que a próxima rodada de
propagação vai recalcular o gap por comparação de conteúdo, e não por leitura do marcador.
Gravar o marcador exigiria antes decidir **qual** relação esta variante tem com a origem:
derivada que fica para trás de propósito, ou linhagem própria que só herdou o kickoff.
