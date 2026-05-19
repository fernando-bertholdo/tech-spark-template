---
name: organize-commits
description: Organizar mudanças pendentes em commits granulares seguindo Conventional Commits. Use quando houver múltiplas mudanças sem commitar, após trabalho extenso, quando não tiver certeza de como organizar commits logicamente, antes de push, ou como parte do checklist pré-commit.
---

# Organize Commits

Guia para organizar mudanças pendentes em commits **atômicos** e bem estruturados, seguindo Conventional Commits.

## Regra de Ouro

> **"1 task = 1 commit. NUNCA use `git add .` ou `git add -A`"**

Commits atômicos permitem:
- Git bisect eficiente (encontrar bugs)
- Reverts cirúrgicos (desfazer apenas uma mudança)
- Code review focado (revisar por contexto)
- Histórico legível (entender evolução)

## Protocolo Atomic Commits

### Regras Hard-Coded

1. **NUNCA** usar `git add .` ou `git add -A`
2. **SEMPRE** stage arquivos individualmente por task
3. **MÁXIMO** ~100 linhas por commit
4. **FORMATO:** `<type>(<scope>): <descricao-em-pt-br>`
5. **REGISTRAR** mudança em `plan.md` (se existir) ou no Changelog do `Projeto.md`

### Exceções Permitidas

- TDD: até 3 commits por task (test → feat → refactor)
- Docs: commits maiores se apenas markdown
- Config: arquivos de configuração podem agrupar

## Quando Usar

- Após completar uma task (commit imediato)
- Após trabalho extenso que precisa ser granularizado
- Quando não tem certeza de como organizar commits logicamente
- Antes de fazer push (validar histórico local)
- Como parte do checklist pré-commit

## Workflow de Organização

```bash
1. Analisar mudanças pendentes
   - git status (ver arquivos modificados)
   - git diff --stat (contar linhas)
   - Identificar tasks/contextos lógicos

2. Mapear mudanças por TASK (não por arquivo):
   - Qual contexto cada arquivo pertence?
   - Marcar arquivos órfãos (sem task clara)

3. Para CADA task, criar UM commit:
   - Stage apenas arquivos daquela task
   - NUNCA usar git add . ou git add -A
   - Formato: <type>(<scope>): <descricao-em-pt-br>
   - Máximo ~100 linhas (quebrar se maior)

4. Executar commit atômico:
   # Correto:
   git add src/module/file.py
   git add tests/unit/test_file.py
   git commit -m "feat(parser): implementa parsing de datas"

   # ERRADO:
   git add .  # NUNCA!
   git add -A # NUNCA!

5. Registrar mudança (quando aplicável):
   - Em plan.md (se existir): marcar task concluída
   - Em Projeto.md: adicionar entrada no Changelog

6. Validar resultado:
   - git log --oneline -5 (ver commits recentes)
   - Verificar se cada commit é atômico
```

## Convenções de Commits (Conventional Commits)

### Formato Padrão

```
<type>(<scope>): <assunto-em-pt-br>

<corpo-opcional-em-pt-br>

<footer>
```

`type` e `scope` permanecem nos tokens padrão de Conventional Commits. `subject`, `body` e qualquer texto descritivo complementar devem ser sempre em português do Brasil.

### Types Disponíveis

| Type | Quando Usar | Exemplo |
|------|-------------|---------|
| `feat` | Nova funcionalidade | `feat(collector): implementa download de dados` |
| `fix` | Correção de bug | `fix(parser): corrige parsing de datas` |
| `docs` | Documentação apenas | `docs: atualiza Projeto.md` |
| `refactor` | Refatoração sem mudança de comportamento | `refactor(processor): simplifica lógica` |
| `test` | Adiciona ou modifica testes | `test(parser): adiciona testes de borda` |
| `chore` | Tarefas de manutenção | `chore(deps): atualiza dependências` |
| `perf` | Melhoria de performance | `perf(calculator): otimiza cálculo` |
| `style` | Formatação | `style: aplica formatador` |
| `ci` | CI/CD configuration | `ci: adiciona GitHub Actions` |
| `build` | Build system | `build: configura setuptools` |

### Subject (Obrigatório)

**Regras:**
- Máximo 72 caracteres
- Lowercase (não capitalizar)
- Imperativo ("adiciona" não "adicionado")
- Sem ponto final
- Descrever O QUE (não "porquê")
- Sempre em português do Brasil (`pt-BR`)

### Body (Opcional, recomendado)

**Quando incluir:**
- Features significativas (>50 linhas)
- Decisões técnicas (porquê esta abordagem?)
- Trade-offs considerados
- Contexto de negócio

**Formato:**
- Linhas de 72 caracteres máximo
- Bullet points com `-` ou `*`
- Separe do subject com linha em branco
- Escrever sempre em português do Brasil (`pt-BR`)

### Footer (Opcional)

**Quando incluir:**
- Breaking changes: `BREAKING CHANGE: descrição`
- Issues relacionados: `Closes #123`, `Ref #456`

**IMPORTANTE — Política de Atribuição:**
- NUNCA incluir co-autoria com IA
- NUNCA mencionar assistentes de IA (Claude, Codex, Cursor, etc.)
- NUNCA incluir "Generated with X" ou similares
- SEMPRE apresentar como trabalho do desenvolvedor

## Princípios de Granularidade

### Tamanho Máximo: ~100 Linhas

| Tamanho | Linhas | Status | Quando Aceitar |
|---------|--------|--------|----------------|
| **Pequeno** | <50 | Ideal | Config, chore, pequenos fixes |
| **Médio** | 50-100 | Ideal | Features isoladas, refactorings |
| **Grande** | 100-150 | Justificar | Testes extensos, docs |
| **Muito grande** | >150 | Quebrar | Dividir em múltiplos commits |

**Por que ~100 linhas?**
- Cabe em uma tela de code review
- Fácil de entender em `git show`
- Reverts cirúrgicos possíveis
- Git bisect mais preciso

### Como Quebrar Commits Grandes

1. **Por Feature/Componente** — Commit A, Commit B, Commit que integra A+B
2. **Por Camada** — models → business logic → endpoints → tests
3. **Por Tipo de Mudança** — feat, depois test, depois docs, depois chore
4. **Por Dependência** — base → depende de base → depende de ambos

## Anti-Padrões (O Que NÃO Fazer)

`git add .` ou `git add -A` (NUNCA!)
```bash
# ERRADO - stage tudo indiscriminadamente
git add .
git commit -m "feat: implementa várias coisas"

# CORRETO - stage por task
git add src/collectors/scraper.py
git commit -m "feat(collector): implementa login automatizado"
```

Commit monolítico (>100 linhas, múltiplos contextos) — impossível fazer revert cirúrgico.

Commit "WIP" ou "checkpoint" sem mensagem clara.

Commit misto (feat + fix + docs juntos) — 3 contextos diferentes, difícil reverter.

## Exemplo Completo

```bash
# 1. Ver mudanças pendentes
$ git status
modified:   src/collectors/scraper.py
modified:   tests/unit/test_scraper.py

$ git diff --stat
 src/collectors/scraper.py     | 85 +++++++++++++
 tests/unit/test_scraper.py    | 42 +++++++

# 2. Commit 1: Feature (85 linhas)
$ git add src/collectors/scraper.py
$ git commit -m "feat(collector): implementa login automatizado"

# 3. Commit 2: Testes (42 linhas)
$ git add tests/unit/test_scraper.py
$ git commit -m "test(collector): adiciona testes de login"

# 4. Verificar resultado
$ git log --oneline -3
abc123f feat(collector): implementa login automatizado
def456g test(collector): adiciona testes de login
```

## Ferramentas Complementares

```bash
git log --oneline -5            # últimos commits
git show <sha>                  # detalhes de um commit
git show --stat <sha>           # arquivos do commit
git log --follow -- caminho     # histórico de um arquivo
git commit --amend --no-edit    # adicionar arquivo esquecido
git commit --amend -m "msg"     # corrigir mensagem do último commit
```

## Quando NÃO Usar

- Commits já feitos (requer `git rebase -i` manual)
- Commits já enviados ao remoto (não reescrever histórico público)
- Organizar commits de outras branches

## Referências

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- `CLAUDE.md` — Seção "Commit Strategy"
- `Projeto.md` — Changelog do projeto
