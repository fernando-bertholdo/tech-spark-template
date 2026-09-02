# Dry-run da propagação — `tech-product-template@2.12.0` → `tech-spark-template`

Data: 2026-09-02 · Issue: TECH-198 · Origem medida: `tech-product-template@2.12.0` (HEAD `ddc393e`)

**Nada foi aplicado.** Este repositório carrega o token `template-fonte` no resource do
workspace: é variante lite deliberada da origem, e a skill `propagar-template` exige
`--dry-run` para esse caso. O que segue é o relatório para decisão humana.

## Estado medido

- Camadas presentes: `.claude/` e `.agents/`
- Sync-IDs da origem ausentes no changelog local: **29 de 29** (o repositório nunca
  registrou nenhum)
- Sync-IDs em que este repositório está **à frente** da origem: 1 (`SYNC-20260831-001`) — isso é
  `mirror-upstream` pendente, não trabalho de propagação
- Marcador `Template de origem: <template>@<versão>`: **ausente**

## O que a propagação cega faria — e por que não deve

A origem tem 7 rules (`api-integration-patterns`, `artifact-governance`,
`code-quality-standards`, `documentation-templates`, `scripts-governance`,
`security-best-practices`, `testing-requirements`) e 28 skills de classe completa
(`validate-dor`, `validate-dod`, `init-milestone`, `init-detour`,
`reconcile-initiative`, `archive-initiative`, os quatro `audit-*`, `generate-tap`,
`enhanced-planning`, `design-sprint`, `claude-design-flow`, `mirror-upstream`,
`sync-downstream`, `update-docs`, `validate-docs-links`, `validate-kickoff`,
`references/`).

Este repositório tem, no lugar, duas rules próprias (`code-quality.md`, `security.md`)
e um catálogo de skills desenhado para a sua própria classe.

Aplicar o conjunto da origem aqui não é sincronizar: é **converter a variante lite em
classe completa**, ligando DoR/DoD, Roadmap por fase, iniciativas com `.planning/` e o
ecossistema de skills interdependente que vem com eles. Isso é mudança de produto, não
propagação — e por isso a skill a manda parar aqui.

## Recomendação

**Não aplicar as 29 entradas.** Três caminhos possíveis, todos do Fernando:

1. **Manter divergente** (default). Se sim, vale declarar a divergência de forma
   auditável, para que a próxima propagação não a recalcule do zero a cada disparo.
2. **Retirar o label** `derivado-de:tech-product-template` do resource, se este
   template não deve ser destino de propagação nenhuma. A skill é explícita: excluir um
   derivado se faz tirando o label, nunca escrevendo nome de repositório na skill.
3. **Recortar um subconjunto neutro de classe** — o que for infraestrutura de agente e
   não governança de classe completa — e propagar só ele, por issue própria.

Do subconjunto do caminho 3, um item já está medido e é barato:

- `.gitignore` — este repositório já ignora `.multica/`, `.agent_context/` e
  `.claude/skills/multica-*/`, mas **não** `.agents/skills/multica-*/`, que a origem
  passou a ignorar no commit `3ca7787`. Aqui isso importa: a camada `.agents/` existe.

## Marcador de origem

**Não gravado**, e não deve ser: a skill proíbe gravá-lo em dry-run. Versão que o
repositório não recebeu faz a próxima propagação calcular o gap errado, e isso é pior
que a ausência.
