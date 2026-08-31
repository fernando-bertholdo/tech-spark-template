---
name: bootstrap-spark
description: Kickoff guiado para projetos criados a partir de tech-spark-template. Use no primeiro contato com o repo recém-clonado para popular Projeto.md, README.md e os dois pontos de entrada de agente (.claude/CLAUDE.md e .agents/README.md) a partir da ideia (vaga, brief existente, ou já-pronto). Substitui o caminho manual do KICKOFF_GUIDE.md.
---

# Bootstrap Spark — Kickoff Guiado

Inicialização guiada de projetos `tech-spark-template`. Substitui placeholders em `Projeto.md`, `README.md` e nos dois pontos de entrada de agente — `.claude/CLAUDE.md` e `.agents/README.md` — a partir de 3 modos de captura de contexto: greenfield (ideia vaga), brief (material existente), ready (decisões prontas).

## Regra de Ouro

> **"Bootstrap é idempotente. Roda uma vez por projeto, sem flag `--force`."**

Se o projeto já foi bootstrappado (nenhum placeholder remanescente), a skill falha explicitamente e instrui o usuário a restaurar o template antes de tentar de novo.

---

## Quando Usar

- Primeiro contato com repo recém-clonado de `tech-spark-template`
- Quando arquivos `Projeto.md`, `README.md`, `.claude/CLAUDE.md`, `.agents/README.md` ainda contêm placeholders `{{...}}`
- Substituto guiado para o caminho manual descrito em `KICKOFF_GUIDE.md`

**NÃO usar:**
- Em projetos já populados (use edição direta de `Projeto.md`)
- Para criar Roadmap/milestones (não é função desta skill; este template não tem Roadmap formal)

---

## Argumentos

```
bootstrap-spark [--mode=greenfield|brief|ready] [--non-interactive]
                [--name="<project-name>"]
                [--description="<one-line>"]
                [--stack="<stack>"]
                [--initial-decision="<text>"]
                [--brief-path="<path-or-text>"]
                [--resume]
```

- `--mode`: força um dos três modos. Se omitido, pergunta interativamente.
- `--non-interactive`: desliga todas as perguntas. Todos os campos obrigatórios do modo escolhido **devem** vir via flags. Se algum faltar, falha claro indicando qual flag está ausente — NÃO cai para prompt interativo.
- `--resume`: usa estado parcial detectado e completa só o que falta.

---

## Pré-checagem: Detecção de Estado Existente

**Sempre executar antes de qualquer escrita.**

```bash
grep -lE '\{\{[A-Z_]+\}\}' Projeto.md README.md .claude/CLAUDE.md .agents/README.md 2>/dev/null
```

**Três estados possíveis:**

| Estado | Arquivos com placeholders | Ação |
|---|---|---|
| **Fresh** | Todos os 4 | Seguir modo escolhido normalmente |
| **Parcial** | 1 a 3 dos 4 | Perguntar: "Detectei bootstrap parcial em `<arquivos>`. Retomar (`--resume`) ou recomeçar?" — se recomeçar, restaurar manualmente |
| **Bootstrappado** | Nenhum | **Falhar**: `"Projeto já bootstrappado (nenhum placeholder restante em Projeto.md/README.md/.claude/CLAUDE.md/.agents/README.md). Para refazer, restaure o template e tente novamente."` |

**Não há flag `--force`** — idempotência é garantia da skill.

---

## Detecção de Modo (1ª interação)

Se não houver `--mode`, perguntar via `AskUserQuestion` com 3 opções:

1. **Greenfield** — "Ideia ainda vaga, me guie com perguntas."
2. **Brief existente** — "Vou colar/apontar um material; use isso como base."
3. **Já-pronto** — "Tenho as decisões prontas, só popula os arquivos."

**Default se usuário pular/cancelar:** `greenfield`.

Em `--non-interactive`, `--mode` é **obrigatório**. Sem ele, falhar:
```
ERRO: --non-interactive exige --mode=greenfield|brief|ready.
```

---

## Modo 1 — Greenfield

**Perguntas uma-por-vez via `AskUserQuestion`** (não em bloco):

1. "Em uma frase, o que esse projeto faz?" → `PROJECT_DESCRIPTION` + base da Visão
2. "Quem usa (você, time, externo)? Tem prazo?" → contexto da Visão
3. "Stack (linguagem/runtime/ferramentas conhecidas)?" → `STACK` (se não souber: `[TODO: definir]`)
4. "Existe algo que NÃO vai entrar no escopo inicial (no-goals)?" → seção opcional em Visão
5. "Algum risco/incógnita que você já conhece?" → registrar em Decisões-chave como ponto aberto

Também perguntar (se não inferível):
- `PROJECT_NAME` (default: nome do diretório atual via `basename "$PWD"`)

**Consolida em `Projeto.md`:**
- Visão (1-2 parágrafos): combina respostas 1, 2, 4
- Stack: resposta 3
- Decisões-chave: linha do template + risco/incógnita (resposta 5) como nota

**Em `--non-interactive`:** ler `--name`, `--description`, `--stack` das flags. `--initial-decision` opcional. Demais campos (no-goals, risco) ficam vazios sem erro.

---

## Modo 2 — Brief Existente

**Fluxo:**

1. Usuário cola/aponta para material (TAP, brief, transcrição, descrição em README de outro projeto, etc.)
   - Aceita via prompt interativo OU `--brief-path="<file-or-inline-text>"`
2. Skill **extrai** o que conseguir (sem inventar):
   - Visão (procurar "objetivo", "missão", "o que faz")
   - Stack (procurar nomes de linguagens/frameworks)
   - Restrições (procurar "não", "fora do escopo", prazos)
3. **Lista o que NÃO ficou claro** e pergunta SÓ essas lacunas
4. **Confirma com usuário** antes de escrever (mostra preview do `Projeto.md` populado)
5. Popula `Projeto.md`

**Princípio:** não chutar. Se Stack não aparece no brief, perguntar; se usuário não soube, deixar `[TODO: definir]`.

**Em `--non-interactive`:** exige `--brief-path` + todos os campos essenciais (`--name`, `--description`, `--stack`) via flags. Lacunas detectadas no brief que não tenham override por flag → falham com lista do que falta.

---

## Modo 3 — Já-pronto

Pede um único bloco de campos:

```
PROJECT_NAME:
PROJECT_DESCRIPTION:
STACK:
INITIAL_DECISION (opcional):
```

Escreve direto sem perguntas adicionais.

**Em `--non-interactive`:** ler `--name`, `--description`, `--stack` (obrigatórios) e `--initial-decision` (opcional) das flags. Se algum obrigatório faltar:
```
ERRO: --mode=ready --non-interactive exige --name, --description e --stack. Faltando: <lista>.
```

---

## Placeholders Substituídos (Exaustivo)

Lista completa — se aparecer qualquer outro `{{...}}` nos arquivos após bootstrap, é bug.

| Placeholder | Arquivos | Origem |
|---|---|---|
| `{{PROJECT_NAME}}` | `README.md`, `Projeto.md`, `.claude/CLAUDE.md`, `.agents/README.md` | Resposta do usuário (greenfield Q "nome do projeto") ou `PROJECT_NAME:` no bloco do modo ready ou flag `--name`. Default: `basename "$PWD"` |
| `{{PROJECT_DESCRIPTION}}` | `README.md` | Resposta "o que esse projeto faz" (greenfield Q1) ou `PROJECT_DESCRIPTION:` no modo ready ou flag `--description` |
| `{{AUTHOR_NAME}}` | `README.md`, `.claude/CLAUDE.md`, `.agents/README.md` | `git config user.name` (auto). Se vazio, perguntar |
| `{{AUTHOR_EMAIL}}` | `README.md` | `git config user.email` (auto). Se vazio, perguntar |
| `{{DATE}}` | `Projeto.md`, `.claude/CLAUDE.md`, `.agents/README.md` | Data ISO 8601 atual: `date +%Y-%m-%d` |
| `{{COMMIT_SCOPES}}` | `.claude/CLAUDE.md`, `.agents/README.md` | Inferido do Stack — ver tabela abaixo |

### Inferência de `{{COMMIT_SCOPES}}`

Examinar o valor de Stack (case-insensitive):

| Sinais no Stack | `{{COMMIT_SCOPES}}` |
|---|---|
| `python`, `py`, `pytest`, `fastapi`, `django`, `flask` | `core, cli, tests` |
| `node`, `nodejs`, `typescript`, `ts`, `javascript`, `js`, `react`, `next`, `vue` | `core, api, ui, tests` |
| `go`, `golang` | `core, cli, tests` |
| `rust` | `core, cli, tests` |
| Stack ambíguo ou `[TODO: definir]` | `core, tests` |

Se Stack tem múltiplos sinais (ex.: "Python backend + React frontend"), combinar: `core, api, ui, tests`.

---

## Saídas Comuns aos 3 Modos

Ao final, os 4 arquivos abaixo ficam **sem placeholders**:

- `Projeto.md` — Visão + Stack + Decisões-chave preenchidos
- `README.md` — `{{PROJECT_NAME}}`, descrição, autor preenchidos
- `.claude/CLAUDE.md` — nome, escopos de commit, data, autor preenchidos
- `.agents/README.md` — os mesmos valores, na camada `.agents/`

**Detalhes:**
- **Os dois pontos de entrada são preenchidos com os mesmos valores.** `.claude/CLAUDE.md` e `.agents/README.md` são um par declarado `solo` dos dois lados, então o gate de pareamento não os compara: preencher só um deixa a outra camada com `{{PROJECT_NAME}}` literal sem que nada reclame. Quem pega isso é a verificação final da etapa 8
- **A linha que declara o template de origem fica nos dois.** É a terceira linha de cada ponto de entrada — `(baseado em \`tech-spark-template\`)` — e é o que registra a linhagem do projeto derivado. Substituir `{{PROJECT_NAME}}` em volta dela, nunca removê-la
- Seção **"Como rodar" em `Projeto.md` fica vazia** para o usuário completar conforme implementa o projeto
- **Changelog em `Projeto.md`** mantém apenas a linha do template (`[YYYY-MM-DD] Bootstrap inicial do projeto.`); próxima entrada virá com commit subsequente, não no bootstrap
- Opcional: se escopo inicial estiver claro, oferecer criar `plan.md` na raiz com 2-3 passos — **NÃO incluir no commit de bootstrap** (`plan.md` está em `.gitignore`)

---

## O Que a Skill NÃO Faz

- ❌ Não cria Roadmap, fases ou milestones (template spark não tem essa hierarquia)
- ❌ Não cria diretórios `documents/core/`, `strategy/`, `technical/`, etc.
- ❌ Não invoca skills tipo `validate-kickoff` ou `validate-dor`/`validate-dod` (não existem neste template)
- ❌ Não chuta Stack — se usuário não soube, deixa `[TODO: definir]` literal
- ❌ Não comita `plan.md` (mesmo se criar — está no `.gitignore`)
- ❌ Não tem flag `--force` (idempotência é regra)
- ❌ Não comita automaticamente — deixa working tree pronta para o usuário/agente fazer `git commit`

---

## Fluxo de Execução (Resumo)

```
1. Parse argumentos (--mode, --non-interactive, --resume, etc.)
2. Pré-check: detectar estado (fresh | parcial | bootstrappado)
   └── Se bootstrappado → falhar
   └── Se parcial → perguntar resume ou abortar
3. Detectar modo (flag, pergunta, ou default greenfield)
4. Coletar dados:
   - Greenfield: 5 perguntas one-by-one (ou flags em non-interactive)
   - Brief: extrair + perguntar lacunas + confirmar
   - Ready: 1 bloco (ou flags em non-interactive)
5. Auto-detectar:
   - PROJECT_NAME (basename do diretório, se não fornecido)
   - AUTHOR_NAME via `git config user.name`
   - AUTHOR_EMAIL via `git config user.email`
   - DATE via `date +%Y-%m-%d`
   - COMMIT_SCOPES via inferência da Stack
6. Confirmar preview com o usuário (skip em --non-interactive)
7. Substituir placeholders nos 4 arquivos (sed/edit, em ordem):
   - Projeto.md
   - README.md
   - .claude/CLAUDE.md
   - .agents/README.md (mesmos valores; manter a linha de linhagem)
8. Verificação final (bloqueante):
   - `grep -lE '\{\{[A-Z_]+\}\}' Projeto.md README.md .claude/CLAUDE.md .agents/README.md`
   - Se o comando listar qualquer um dos 4 arquivos → declarar FALHA, nomeando
     os arquivos, e NÃO concluir o kickoff
   - Essa checagem não é delegável ao gate de pareamento: os dois pontos de
     entrada são `solo` e ficam fora da comparação
9. Reportar:
   - Arquivos modificados
   - Valores aplicados
   - Próximos passos (commit `chore: bootstrap via spark`)
```

---

## Mensagem Final

Ao concluir, imprimir:

```
Bootstrap concluído.
- Modo: <greenfield|brief|ready>
- Arquivos modificados: Projeto.md, README.md, .claude/CLAUDE.md, .agents/README.md
- Próximo passo: revise os arquivos e commite com:
    git add Projeto.md README.md .claude/CLAUDE.md .agents/README.md
    git commit -m "chore: bootstrap via spark"
- Itens em aberto:
    <lista se houver [TODO: definir] ou seções vazias intencionalmente>
```

---

## Exemplos de Invocação

**Interativo, greenfield:**
```
bootstrap-spark
> Modo? Greenfield
> Em uma frase... → "Calculadora de IRPF para freelas"
> Quem usa... → "Eu, anual"
> Stack... → "Python + Click"
...
```

**Não-interativo, modo ready (CI/testes determinísticos):**
```
bootstrap-spark --mode=ready --non-interactive \
  --name="irpf-tools" \
  --description="Ferramentas auxiliares para IRPF de freelancers" \
  --stack="Python 3.12 + Click + pytest" \
  --initial-decision="Adotar Click no lugar de Typer por simplicidade"
```

**Não-interativo, modo brief com arquivo:**
```
bootstrap-spark --mode=brief --non-interactive \
  --brief-path="./brief.md" \
  --name="meu-projeto" \
  --description="Resumo extraído do brief" \
  --stack="Node + TypeScript"
```

**Resumindo bootstrap parcial:**
```
bootstrap-spark --resume
```

---

## Erros Esperados (Mensagens Claras)

| Cenário | Mensagem |
|---|---|
| Projeto já bootstrappado | `ERRO: Projeto já bootstrappado (nenhum placeholder restante). Para refazer, restaure o template.` |
| `--non-interactive` sem `--mode` | `ERRO: --non-interactive exige --mode=greenfield|brief|ready.` |
| `--non-interactive --mode=ready` sem campos obrigatórios | `ERRO: --mode=ready --non-interactive exige --name, --description e --stack. Faltando: <lista>.` |
| `--non-interactive --mode=brief` sem brief-path | `ERRO: --mode=brief --non-interactive exige --brief-path.` |
| Estado parcial + nem `--resume` nem confirmação | `ERRO: bootstrap parcial detectado em <arquivos>. Use --resume para continuar ou restaure o template para recomeçar.` |
| Placeholder remanescente após escrita | `BUG: placeholders {{...}} restantes em <arquivo>. Reportar.` |

---

## Referências

- [KICKOFF_GUIDE.md](../../../KICKOFF_GUIDE.md) — caminho manual equivalente
- [Projeto.md](../../../Projeto.md) — destino principal de captura
- [README.md](../../../README.md) — destino secundário (apresentação)
- [.claude/CLAUDE.md](../../../.claude/CLAUDE.md) — destino terciário (regras operacionais, camada Claude Code)
- [.agents/README.md](../../README.md) — destino quaternário (as mesmas regras, camada agents)
- [skills/fresh-context/SKILL.md](../fresh-context/SKILL.md) — handoff entre sessões (uso posterior ao bootstrap)

---

**Versão:** 1.0.0
**Última atualização:** 2026-05-19
