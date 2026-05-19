# Future Work — tech-spark-template

> ⚠️ **Esta seção não pode ser removida** sem decisão explícita registrada em "Decisões-chave" do [Projeto.md](Projeto.md).

**Spec original:** [`tech-product-template/documents/superpowers/specs/2026-05-18-tech-spark-template-design.md`](https://github.com/fernando-bertholdo/tech-product-template/blob/main/documents/superpowers/specs/2026-05-18-tech-spark-template-design.md) — §10 ("Future Work — Promotion Path").

Documento espelha a §10 da spec original. Preserva direções futuras reconhecidas mas não construídas na v1 deste template.

## Promotion Path (Abordagem C)

**Status:** Reconhecido. Não construído na v1.

### Motivação

Algum projeto iniciado com `tech-spark-template` pode crescer a ponto de fazer sentido adotar a estrutura full de `tech-product-template`. Hoje isso seria um rewrite manual; queremos um caminho documentado e (eventualmente) automatizado.

### Pré-condições já garantidas pela v1 deste template

- `Projeto.md` na raiz é um **superset reduzido** do `documents/core/Projeto.md` do full. Promover = mover arquivo + expandir seções, não reescrever.
- Skills com mesmos nomes (quando ambos templates as têm) reduzem custo de transição.
- Estrutura `.claude/` é compatível.
- `.planning/scratch/` é compatível com o `.planning/` do full.

### Forma proposta da skill `promote-to-tpt`

Quando construída, faria:

1. Cria `documents/core/`, move `Projeto.md` da raiz para lá.
2. Cria `Roadmap.md` vazio (template para usuário preencher).
3. Cria `documents/strategy/`, `technical/`, `guides/`, `archive/` com READMEs.
4. Adiciona skills do full que não existem aqui (`init-milestone`, `validate-dor`, `validate-dod`, `update-docs`, `reconcile-initiative`, `archive-initiative`, etc.).
5. Adiciona `.codex/` e `.agents/` espelhados se usuário optar por multi-IA.
6. Adiciona `documents/core/CLAUDE.md`, `documents/CLAUDE.md`, etc.
7. Atualiza `.claude/CLAUDE.md` para a versão completa do full.
8. Commit: `chore: promote spark project to tech-product-template`.

### Gatilho para construir

Quando você (ou alguém usando este template) tiver feito a promoção manual 2+ vezes e a fricção for sentida. Antes disso: YAGNI.

## Outras direções futuras

[Adicionar aqui conforme aparecerem. Manter a regra: nada migra do `tech-product-template` sem perguntar antes "esse projeto ainda é spark?".]
