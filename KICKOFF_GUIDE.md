# Kickoff Guide — tech-spark-template

Caminho manual de inicialização. Para versão guiada via skill, use `bootstrap-spark` no Claude Code.

## Passos

1. **Clonar template e reinicializar git**

```bash
git clone https://github.com/<você>/tech-spark-template my-project
cd my-project
rm -rf .git
git init
git config user.name "Seu Nome"
git config user.email "seu@email.com"
```

2. **Substituir placeholders** nos arquivos:
   - `README.md`: `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`, `{{AUTHOR_NAME}}`, `{{AUTHOR_EMAIL}}`
   - `Projeto.md`: `{{PROJECT_NAME}}`, depois preencher seções
   - `.claude/CLAUDE.md`: `{{PROJECT_NAME}}`, `{{COMMIT_SCOPES}}`, `{{AUTHOR_NAME}}`, `{{DATE}}`

3. **Setup ambiente**

```bash
cp .env.example .env
# editar .env com seus valores
```

4. **Primeiro commit**

```bash
git add .
git commit -m "chore: bootstrap projeto"
```

## Alternativa: kickoff guiado

Em vez do passo manual acima, abra o projeto no Claude Code e invoque a skill `bootstrap-spark`. Ela pergunta o necessário e popula os arquivos.

## Próximos passos

- Comece a editar `Projeto.md` adicionando Decisões-chave conforme o projeto evolui.
- Use `pre-commit-check` antes de cada commit (`/pre-commit-check` no Claude Code).
- Crie `plan.md` na raiz quando a task tem >3 passos ou cruza sessões.
