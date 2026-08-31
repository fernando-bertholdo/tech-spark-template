---
name: update-projeto
description: Atualiza Projeto.md (Decisões-chave + Changelog) ao registrar uma decisão técnica importante ou marcar um trabalho concluído. Use após tomar uma decisão de arquitetura, concluir um plan.md, ou ao final de um marco interno do projeto.
---

# update-projeto

Atualiza `Projeto.md` na raiz do repositório com novas entradas em **Decisões-chave** e/ou **Changelog**.

## Quando usar

- Após tomar uma decisão técnica/arquitetural relevante
- Ao concluir um `plan.md` ou marco interno
- Ao introduzir mudança estrutural que vale registrar no Changelog

## O que NÃO faz

- Não cria `Projeto.md` (use `bootstrap-spark` primeiro)
- Não atualiza Roadmap (não existe no spark template)
- Não comita (granularidade fica com o usuário)
- Não tem subcomandos (`task`/`system`/`roadmap` são do full template)

## Precondições

- `Projeto.md` deve existir na raiz do repositório
- Estrutura esperada (5 seções): **Visão**, **Stack**, **Decisões-chave**, **Como rodar**, **Changelog**

## Comportamento por estado

| Estado | Comportamento |
|---|---|
| `Projeto.md` ausente | Falha com mensagem: `"Projeto.md não encontrado. Rode bootstrap-spark primeiro ou crie manualmente seguindo KICKOFF_GUIDE.md."` |
| Seções faltantes/renomeadas | Cria silenciosamente as seções faltantes no fim do arquivo (idempotente) |
| Múltiplas execuções na mesma sessão | Cada execução adiciona no máx 1 entrada em Decisões-chave e 1 em Changelog. Se o conteúdo já existe (match por hash de commit ou texto da decisão), pula sem alteração |

## Idempotência

Rodar `update-projeto` duas vezes seguidas sem mudanças entre elas **não produz diff**. Antes de adicionar, a skill compara:
- **Decisão**: título normalizado (lowercase, trim) já presente em Decisões-chave
- **Changelog**: hash do commit OU descrição literal já presente em Changelog

Match positivo → pula a entrada e informa "Entrada já existente, nada a fazer."

## Fluxo

### 1. Verificar precondições

- Ler `Projeto.md` na raiz. Se ausente → falhar com mensagem padronizada (ver tabela acima).
- Detectar presença das 5 seções via headings (`## Visão`, `## Stack`, `## Decisões-chave`, `## Como rodar`, `## Changelog`).
- Para seções faltantes: anexar headers vazios no fim do arquivo antes de prosseguir (idempotente).

### 2. Coletar entrada de Decisões-chave (opcional)

Perguntar ao usuário:

> "Foi uma decisão técnica? (sim/não)"

Se **sim**, perguntar:
- "O que foi decidido?" (título curto)
- "Razão / motivação?"
- "Alternativas consideradas e descartadas?"

Se **não**, pular para passo 3.

### 3. Coletar entrada de Changelog (opcional)

Perguntar:

> "Mudança relevante para Changelog? (sim/não)"

Se **sim**, perguntar:
- "Descrição curta da mudança?"
- "Hash do commit?" (sugerir rodar `git log -1 --format=%h` se o usuário não souber)

Se **não**, pular para passo 4.

### 4. Aplicar entradas

Formato exato:

**Decisões-chave** (anexar ao final da seção):
```
- [YYYY-MM-DD] **<título>**. Razão: <por quê>. Alternativas: <descartadas>.
```

**Changelog** (anexar ao final da seção):
```
- [YYYY-MM-DD] <descrição> (commit `<hash>`).
```

Use a data atual em formato ISO (`YYYY-MM-DD`).

### 5. Confirmar com diff

Exibir o diff proposto (antes/depois das seções alteradas) e pedir confirmação:

> "Aplicar mudanças? (sim/não)"

Apenas após `sim` explícito, escrever o arquivo.

### 6. Lembrete final

Após salvar, informar:

> "Pronto. Não esqueça de commitar Projeto.md (ex.: `chore(docs): atualiza Projeto.md`)."

## Exemplo

**Entrada do usuário:**
- Decisão: usar SQLite ao invés de Postgres
- Razão: simplicidade para protótipo single-user
- Alternativas: Postgres (overkill), DuckDB (sem persistência fácil)
- Changelog: "adota SQLite como storage default", commit `a1b2c3d`

**Resultado em `Projeto.md`:**

```markdown
## Decisões-chave

- [2026-05-19] **Usar SQLite ao invés de Postgres**. Razão: simplicidade para protótipo single-user. Alternativas: Postgres (overkill), DuckDB (sem persistência fácil).

## Changelog

- [2026-05-19] adota SQLite como storage default (commit `a1b2c3d`).
```

## Notas

- Sempre em pt-BR.
- Se o usuário responder "não" em ambas perguntas (decisão e changelog), informar "Nada a registrar" e encerrar sem modificar o arquivo.
- Não invente conteúdo: se o usuário não fornecer razão/alternativas, pergunte novamente ou registre `n/a` explicitamente.
