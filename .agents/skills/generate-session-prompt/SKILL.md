---
name: generate-session-prompt
version: 1.0.0
description: Gerar prompt para retomada de desenvolvimento em nova sessão. Use ao retomar trabalho após pausa, ao trocar de ferramenta (ex: Cursor → Claude Code), em mudança de contexto, ou quando sessão atual passou de ~150k tokens. Aceita argumento de detalhe (brief, standard, detailed). Modo genérico — funciona em qualquer projeto, sem framework opinionado.
---

# Generate Session Prompt

Gera prompt para continuidade de trabalho em nova sessão, adaptando nível de detalhe ao contexto.

## Quando Usar

- Sessão atual >150k tokens (performance degradada)
- Retomar trabalho após pausa (dias/semanas)
- Trocar de ferramenta (ex: Cursor → Claude Code)
- Mudança de contexto (ex: terminou trabalho secundário, vai retomar o principal)
- Handoff de tarefas complexas com conclusões a preservar

## Níveis de Detalhe

| Nível | Invocação | Tokens | Quando |
|-------|-----------|--------|--------|
| **brief** | `generate-session-prompt brief` | 200-500 | Continuação imediata, mesmo contexto, próximo dia |
| **standard** | `generate-session-prompt` (default) | 800-1500 | Retomada após pausa, troca de ferramenta |
| **detailed** | `generate-session-prompt detailed` | 1500-3000+ | Handoff complexo, múltiplas tarefas, conclusões a preservar |

**Seleção automática (sem argumento explícito):**
- Sessão curta + mesmo trabalho + poucas tarefas → `brief`
- Caso geral / sem indicação clara → `standard`
- Sessão com análises, conclusões ou múltiplas tarefas → `detailed`
- Usuário pediu "contexto completo" → `detailed`

## Princípios

1. **Contexto proporcional** — Detalhe proporcional à complexidade do handoff
2. **Referências @** — Links diretos a arquivos facilitam navegação do agente
3. **Conclusões inline** — Carregar análises no prompt quando a próxima sessão precisa agir sobre elas (standard/detailed)
4. **Universal** — Funciona em qualquer projeto, sem framework opinionado
5. **Skills contextuais** — Indicar skills relevantes para a próxima sessão

## Source of Truth

Se existir `Projeto.md` na **raiz do projeto**, trate-o como fonte primária de contexto de negócio/arquitetura — referencie-o no prompt gerado sempre que existir.

## Procedimento

1. **Coletar estado atual** (ver bloco abaixo)
2. **Determinar nível** — argumento explícito, ou inferir
3. **Identificar tipo de trabalho** (feature, bugfix, refactor, spike, misc)
4. **Gerar prompt** seguindo a estrutura do nível + template do tipo
5. **Validar** contra o checklist do nível

### Coleta

```bash
1. Identificar tipo de trabalho
   - O que foi discutido na sessão, código tocado, problema sendo resolvido
   - git branch --show-current
     feat/* → feature; fix/* → bugfix; refactor/* → refactor; spike/* → spike
   - Se ambíguo → "misc"

2. Coletar estado do projeto
   - Projeto.md (raiz) se existir — source of truth
   - README.md (visão, comandos, stack)
   - Manifest (package.json, pyproject.toml, Cargo.toml, go.mod, etc.)
   - git log --oneline -10  (narrativa recente)
   - git status              (mudanças pendentes)
   - git diff HEAD --stat    (escopo do diff)
   - Arquivos modificados nas últimas 48h:
     find . -type f -mtime -2 -not -path './.git/*' \
       -not -path './node_modules/*' -not -path './dist/*' 2>/dev/null | head -20

3. Coletar contexto da sessão atual (CRÍTICO)
   - O que o usuário pediu, o que foi entregue, o que ficou pendente
   - Decisões tomadas e o porquê
   - Análises/descobertas técnicas (APIs, bugs, convenções)
   - Bloqueios e como foram (ou não) contornados
```

## Templates por Tipo

| Tipo | Abertura | Refs obrigatórias | Skills |
|------|----------|-------------------|--------|
| **feature** | `Vamos continuar a implementação de [FEATURE] em [PROJETO].` | Projeto.md, README.md, arquivos da feature | organize-commits, pre-commit-check |
| **bugfix** | `Vamos resolver [BUG] em [PROJETO].` | Arquivo do bug, log/stack trace, teste reproduzindo | systematic-debugging |
| **refactor** | `Vamos continuar o refactor de [ÁREA] em [PROJETO].` | Arquivos refatorados, testes, docs afetadas | simplify, code-review |
| **spike** | `Vamos continuar a exploração de [TEMA] em [PROJETO].` | Notas/scratch, código de POC | brainstorming |
| **misc** | `Vamos continuar o trabalho em [DESCRIÇÃO] em [PROJETO].` | Arquivos relevantes da sessão | — |

## Formato dos Prompts

Todos os níveis seguem o esqueleto: **abertura → referências @ → objetivo → contexto atual → (conclusões inline) → tarefas**.

### Brief (200-500 tokens)

```markdown
Vamos continuar a [TIPO] de [DESCRIÇÃO] em [PROJETO].

**Referências principais:**
- @Projeto.md (se existir)  · @[arquivo1] · @[arquivo2]

**Objetivo:** [1 frase]

**Contexto atual:**
- Branch: [nome] — [progresso resumido]
- [Feito na sessão anterior]
- [Próximo passo concreto]

**Por favor:**
1. [Tarefa 1]   2. [Tarefa 2]   3. [Tarefa 3]
```

### Standard (800-1500 tokens, default)

Adiciona ao Brief: 5-8 referências; contexto expandido (últimos commits, diff pendente, decisões/bloqueios); **seção "Conclusões da sessão anterior"** com 2-5 bullets quando há análises a transportar; 4-6 tarefas com critério de completude; uma tarefa final de commit/PR conforme padrão do projeto.

### Detailed (1500-3000+ tokens)

Adiciona ao Standard: referências sem limite; objetivo em parágrafo com sub-objetivos; **seção "Contexto do projeto"** (stack, convenções, narrativa dos commits, escopo do diff); **seções dedicadas por tarefa** (`### TAREFA A — [Nome]`) contendo:
- *Conclusão da análise anterior* (justificativa, alternativas descartadas, recomendação)
- *Pontos de atenção* (estado real + ação sugerida)
- *Ação sugerida* (sub-passos detalhados)

Lista final consolidada de tarefas referenciando as seções acima.

## Regras

**SEMPRE:**
1. Adaptar detalhe ao nível
2. Usar referências @
3. Incluir métricas quando disponíveis (progresso %, coverage, commits)
4. Referenciar skills aplicáveis
5. Incluir conclusões/análises inline quando a próxima sessão precisa agir
6. Identificar tipo de trabalho
7. Incluir validações e critérios de completude
8. Referenciar `Projeto.md` (raiz) quando existir

**NUNCA:**
1. Copiar histórico completo da sessão (resumir, não copiar)
2. Duplicar conteúdo extenso dos arquivos referenciados
3. Usar descrições genéricas ("continue o trabalho")
4. Omitir referências aos arquivos principais
5. Ignorar conclusões da sessão em standard/detailed

## Validação

**Brief:** 200-500 tokens · 3-5 refs · objetivo 1 frase · 3-5 bullets de contexto · 3-4 tarefas · tipo identificado

**Standard:** 800-1500 tokens · 5-8 refs · objetivo 1-2 frases · 5-8 bullets · conclusões inline (2-5 bullets se houver) · 4-6 tarefas · skills sugeridas · tipo identificado

**Detailed:** 1500-3000+ tokens · refs sem limite · objetivo em parágrafo · contexto expandido · seções dedicadas por tarefa com conclusões inline · pontos de atenção (estado real + ação) · tarefas consolidadas · skills/validações · tipo identificado

## Troubleshooting

- **Prompt genérico:** sessão sem decisões/análises explícitas → refine manualmente antes de usar
- **Detalhe demais:** use argumento explícito `brief`
- **Conclusões ausentes:** brief não inclui — use `standard` ou `detailed`
- **Referências quebradas:** valide caminhos manualmente antes de colar em nova sessão

---

## Changelog

### v1.0.0 (Maio/2026)

- Versão inicial para `tech-spark-template`
- Modo único (genérico) — sem suporte a frameworks opinionados
- Detecta `Projeto.md` (raiz) como source of truth (opcional)
- Coleta via Projeto.md + README + git log + git status + contexto da sessão
- Templates universais: feature, bugfix, refactor, spike, misc
- Três níveis: brief (200-500), standard (800-1500, default), detailed (1500-3000+)
- Inferência automática de nível quando não especificado

**Origem:** Adaptado de `tech-product-template/.claude/skills/generate-session-prompt/SKILL.md` (v4.0.0),
descartando o modo opinionated (que pressupõe `.planning/milestones/`, Roadmap.md, TODO.md, init-milestone, validate-dor, validate-dod).
