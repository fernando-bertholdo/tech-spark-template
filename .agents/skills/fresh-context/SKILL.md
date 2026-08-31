---
name: fresh-context
description: Gerar documento CONTEXT.md curto e self-contained para handoff entre sessões ou subagentes. Use quando sessão > 150k tokens (context rot), ao retomar trabalho após pausa, ao trocar de ferramenta/IDE, ou ao delegar para subagente. Output único é sempre `.planning/scratch/<slug>-CONTEXT.md`.
---

# Fresh Context — Handoff Document Generator (Lite)

Gera um CONTEXT.md curto para permitir continuação de trabalho em janela limpa, sem perder o essencial.

> **Versão lite:** este projeto não usa `milestones/`, `detours/`, `patches/` nem `_archive/`. Todo CONTEXT.md vai para `.planning/scratch/`.

## Regra de Ouro

> **"Contexto fresco > contexto acumulado com noise."**

Sessões longas (> 150k tokens) degradam qualidade da resposta. O CONTEXT.md é o pacote mínimo que permite recomeçar limpo sem perder o fio da meada.

## Quando Usar

- **Sessão > 150k tokens** — context rot detectado, hora de `/clear`
- **Retomar trabalho após pausa** — em vez de reler a sessão inteira
- **Trocar de ferramenta** — passar de Claude Code para Codex, Cursor, etc.
- **Handoff para subagente** — fornecer contexto focado e auto-contido
- **Mudança de contexto significativa** — capturar o estado antes de pivotar

## Princípio do Output

O CONTEXT.md deve ser **curto** (alvo: ~200–500 tokens). Ele **não duplica** documentação: aponta para fontes (`Projeto.md`, código, prompts anteriores). Inclui apenas o que é necessário para retomar.

**Inclui:**

- Goal atual (o que está sendo construído)
- Onde o trabalho parou
- Próximos passos imediatos
- Arquivos/paths tocados e decisões locked relevantes
- Perguntas em aberto

**NÃO inclui:**

- Walkthrough longo de implementação
- Logs ou diffs completos
- Conteúdo que pertence a `Projeto.md` (decisões de fonte de verdade) ou ao código

## Workflow

```text
1. Identificar o trabalho atual:
   - Goal de uma sentença
   - Slug curto em kebab-case (ex.: "scraper-login", "refactor-api-client")
     derivado do tópico da sessão atual (não de milestone-id)

2. Reunir o essencial:
   - Último estado: o que acabou de ser feito / onde parou
   - Próximos 1–3 passos
   - Arquivos importantes tocados ou em foco
   - Decisões já tomadas que NÃO devem ser re-debatidas
   - Perguntas/dúvidas em aberto

3. Preencher o template (ver abaixo) — seja conciso.

4. Salvar em:
     .planning/scratch/<slug>-CONTEXT.md

5. (Opcional) Sugerir prompt de continuação:
     /clear
     Retomar trabalho em <goal>.
     Contexto: @.planning/scratch/<slug>-CONTEXT.md
```

## Template do CONTEXT.md

Salvar exatamente este esqueleto em `.planning/scratch/<slug>-CONTEXT.md` e preencher:

```markdown
# CONTEXT: <título-curto>

**Gerado em:** <YYYY-MM-DD>
**Slug:** <slug>

---

## 1. Goal atual

<Uma sentença descrevendo o que está sendo construído ou resolvido.>

## 2. Último estado

<Onde o trabalho parou. 2–4 bullets. Inclua o que acabou de ser feito e qualquer
falha/bloqueio observado.>

- ...
- ...

## 3. Próximos passos

<As primeiras 1–3 ações concretas ao retomar. Em ordem.>

1. ...
2. ...
3. ...

## 4. Contexto técnico relevante

<Arquivos tocados, paths importantes, comandos úteis, decisões locked que evitam
re-debate. Mantenha curto — links/paths em vez de transcrever conteúdo.>

- **Arquivos em foco:** `path/para/arquivo.py`, `outro/arquivo.md`
- **Decisões locked:** <ex.: "biblioteca X escolhida; não revisitar">
- **Referências:** `Projeto.md` seção <X>, prompts/artefatos relevantes

## 5. Decisões em aberto

<Perguntas que ficaram sem resposta e precisam ser respondidas para destravar
os próximos passos. Pode estar vazio.>

- [ ] ...
- [ ] ...
```

## Exemplo Mínimo Preenchido

```markdown
# CONTEXT: scraper-login

**Gerado em:** 2026-05-19
**Slug:** scraper-login

---

## 1. Goal atual

Implementar login automatizado no portal X usando Playwright, com retry e captura de evidência.

## 2. Último estado

- Função `login()` esboçada em `src/scraper/auth.py`
- Falha intermitente no seletor do campo de senha (provável race condition)
- Teste manual passou 2 de 3 execuções

## 3. Próximos passos

1. Adicionar `wait_for_selector` antes de digitar a senha
2. Cobrir cenário de credencial inválida com `pytest.raises`
3. Salvar screenshot em falha para auditoria

## 4. Contexto técnico relevante

- **Arquivos em foco:** `src/scraper/auth.py`, `tests/unit/test_auth.py`
- **Decisões locked:** Playwright (não Selenium); credenciais via `.env`
- **Referências:** `Projeto.md` seção "Autenticação"

## 5. Decisões em aberto

- [ ] Onde guardar screenshots de falha? `tmp/` ou `evidence/`?
- [ ] Retry: backoff exponencial ou fixo?
```

## Integração

- O CONTEXT.md é **derivado e descartável** — sobrescreva livremente.
- Use junto com `/clear` para iniciar uma sessão nova sem ruído.
- Para projetos opinionados com `.planning/` completo (milestones/detours), use a versão cheia em `tech-product-template`.

## Referências

- **Diretório de scratch:** `.planning/scratch/`
- **Fonte de verdade do projeto:** `Projeto.md` (raiz do repositório)
- **Skills relacionadas:** `pre-commit-check`, `organize-commits`
