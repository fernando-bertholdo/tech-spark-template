---
name: pre-commit-check
description: Use SEMPRE antes de git commit. Executa validações de qualidade (formatter, linter, typecheck quando aplicável), busca por secrets hardcoded, valida que .env não está staged, roda a suíte de testes se existir, e checa o formato da mensagem de commit (conventional commits em pt-BR). Bloqueia o commit se algum gate crítico falhar.
---

# Pre-Commit Check

Gate de qualidade antes de `git commit`. Sem dependências de roadmap, milestones ou DoD — apenas as validações essenciais para o snapshot atual.

## Quando Usar

- SEMPRE antes de `git commit`
- Aceita argumento livre opcional (ex.: contexto/escopo do commit) para incorporar à validação da mensagem

## O Que Valida

### 1. Code Quality (por stack)

Fonte de verdade do stack: `Projeto.md` (raiz do repositório) ou marcadores do projeto (`pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`, etc.).

**Python (se aplicável):**

```bash
ruff format --check src/ tests/
ruff check src/ tests/
mypy src/                    # se mypy estiver configurado
```

**Node/TypeScript (se aplicável):**

```bash
npx prettier --check .
npx eslint .
npx tsc --noEmit             # se TS estiver configurado
```

**Outros stacks:** execute formatter + linter (+ typecheck) oficiais do projeto. Se ainda não existem, defina antes de prosseguir — não chute ferramentas.

**Auto-fix disponível:**

```bash
ruff format src/ tests/ && ruff check src/ tests/ --fix
# ou
npx prettier --write . && npx eslint . --fix
```

### 2. Security básico

**Busca por secrets hardcoded (CRÍTICO — bloqueador):**

```bash
rg -n "password\s*=\s*['\"]" src/ 2>/dev/null
rg -n "api_key\s*=\s*['\"]" -i src/ 2>/dev/null
rg -n "SECRET\s*=\s*['\"]" -S src/ 2>/dev/null
rg -n "token\s*=\s*['\"][A-Za-z0-9_\-]{16,}" src/ 2>/dev/null
```

**`.env` não staged (CRÍTICO):**

```bash
git status --porcelain | grep -E "(^|/)\.env(\s|$)" && echo "BLOQUEADO: .env staged"
```

Se `.env` aparecer: `git reset .env` antes de prosseguir.

**`.env.example` atualizado:** se variáveis novas foram adicionadas a `.env`, sincronize `.env.example` (sem valores reais).

### 3. Testing

Rode a suíte se existir; pule graciosamente se `tests/` estiver vazio ou ausente.

```bash
# Python
[ -d tests ] && [ "$(ls -A tests 2>/dev/null)" ] && pytest -q || echo "skip: sem testes"

# Node
[ -f package.json ] && npm test --if-present || echo "skip: sem script test"
```

**Bloqueador:** se há testes e algum falha, NÃO commitar.

### 4. Git Status

Antes de commitar:

```bash
git status
git diff --cached --stat
```

Confirmar:
- Arquivos corretos staged (sem `git add .` indiscriminado)
- Nenhum arquivo sensível staged (`.env`, `credentials.json`, `*.key`, `*.pem`)
- Diff faz sentido como uma unidade lógica

### 5. Mensagem de Commit (Conventional Commits em pt-BR)

**Formato:** `<type>(<scope>): <assunto-em-pt-br>`

- `type` ∈ `feat | fix | docs | refactor | test | chore | perf | style | ci | build`
- `scope` opcional, em minúsculas
- `subject`, `body` e qualquer texto descritivo sempre em **português do Brasil**
- Sem co-autoria de IA, sem menções a assistentes

**Exemplos válidos:**

```
feat(auth): adiciona login via OAuth
fix(api): corrige timeout em chamadas longas
docs: atualiza README com instruções de setup
test(parser): cobre caso de input vazio
```

## Procedimento

```
1. Code Quality
   - Rodar formatter --check + linter (+ typecheck se houver)
   - Se FAIL: aplicar auto-fix quando possível e revalidar
   - Buscar secrets hardcoded → se encontrar, BLOQUEAR

2. Security
   - Verificar `git status` para `.env`/credentials staged
   - Se staged: `git reset <arquivo>` e revalidar

3. Testing
   - Rodar suíte se `tests/` (ou equivalente) existir e estiver populado
   - Se FAIL: BLOQUEAR

4. Git Status
   - Revisar `git diff --cached`
   - Confirmar arquivos corretos
   - Rodar `bash scripts/validate/check-pareamento-instrucoes.sh` em TODO commit,
     sem condição de caminho — se FAIL, BLOQUEAR. Leva ~3s e não depende de stack,
     e editar só `scripts/validate/pareamento-instrucoes-excecoes.txt` reprova o
     gate sem tocar camada nenhuma
   - O gate inventaria pelo índice, mas compara o conteúdo da **árvore de trabalho**:
     com mudança parcialmente staged ele valida algo diferente do que vai no commit.
     Se sobrou edição não staged em `.claude/`, `.agents/` ou nas exceções, o verde
     dele não fala do commit — resolva o stage parcial antes de confiar no resultado

5. Mensagem
   - Validar formato conventional commit em pt-BR
   - Planejar `<type>(<scope>): <assunto>`

6. Relatório: READY ou NOT READY
```

## Exemplo de Output

```
Pre-Commit Check
================

1. Code Quality   PASS  (ruff format / ruff check / mypy)
2. Security       PASS  (sem secrets, .env não staged)
3. Testing        PASS  (42 testes ok)
4. Git Status     OK    (5 arquivos staged, nada sensível)
5. Mensagem       OK    feat(auth): adiciona login via OAuth

READY TO COMMIT
```

## Bloqueadores (NOT READY)

- Formatter/linter/typecheck com erros
- Secrets hardcoded encontrados
- `.env` ou credenciais staged
- Testes existentes falhando
- Gate de pareamento reprovando — ele roda incondicionalmente, inclusive num commit que só mexe em `scripts/validate/`

## Avisos (revisar, não bloqueia)

- `.env.example` desatualizado
- Manifesto de dependências (`requirements.txt`, `package-lock.json`, etc.) modificado sem intenção declarada
- Arquivos não staged que parecem relacionados ao commit atual

## Checklist Rápido

- [ ] Formatter check passou
- [ ] Linter passou
- [ ] Typecheck passou (se aplicável)
- [ ] Nenhum secret hardcoded
- [ ] `.env` não staged
- [ ] Testes passam (ou inexistentes)
- [ ] Arquivos staged conferem
- [ ] Pareamento `.claude/` × `.agents/` íntegro (`bash scripts/validate/check-pareamento-instrucoes.sh`, rodado em todo commit)
- [ ] Mensagem em formato conventional (pt-BR)

## Referências

- `@rules/code-quality-standards.md` — padrões de qualidade
- `@rules/security-best-practices.md` — práticas de segurança
- `@rules/testing-requirements.md` — requisitos de testes
- `Projeto.md` (raiz) — stack e comandos oficiais do projeto
