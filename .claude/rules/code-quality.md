---
paths:
  - src/**/*
  - "*.py"
---

# Code Quality (lite)

Path-targeted: aplica em `src/**/*` e `*.py`. Exemplos em Python; adaptar ao stack do projeto.

## Formatação

- Linha máxima 100 chars
- Centralizar config em manifesto do stack (`pyproject.toml`/`package.json`/etc.)
- Imports em 3 grupos: stdlib, third-party, local

## Type hints / Tipagem

Toda função/classe pública tem tipagem. Validar com a ferramenta do stack (ex.: `mypy src/` em Python).

## Docstrings e comentários

**Docstrings em tudo público.** Explicar intenção/contexto (o "porquê"), invariantes, edge cases. Em Python: Google style (Args/Returns/Raises).

**Comentários** explicam decisões, não o óbvio.

## Naming

- `snake_case` para variáveis/funções
- `PascalCase` para classes
- `UPPER_SNAKE_CASE` para constantes
- Sem abreviações obscuras

## Constants nomeadas

Sem magic numbers. Exceções óbvias: `0`, `1`, `-1`, `100` em conversões percentuais explícitas.

## Error handling

- Exceções específicas (`ValueError`, `TypeError`); evitar `except Exception` genérico (salvo boundaries de processo)
- Sempre logar antes de re-raise ou suprimir
- Nunca silenciar erro sem rastreabilidade

## Logging (obrigatório)

- Nunca `print` (exceção: CLIs)
- Todo módulo: `logger = logging.getLogger(__name__)` (ou equivalente do stack)
- Configurar logging uma vez no entrypoint
- Logar: início/fim de operações importantes, contagens, status de chamadas externas (sem payload sensível)
- Nunca logar: tokens, senhas, cookies, headers sensíveis, PII

## Secrets

Via env vars + biblioteca do stack (`pydantic-settings`/`dotenv`/etc.). `.env` no `.gitignore`. `.env.example` sanitizado.

## Checklist de review

- [ ] Código formatado
- [ ] Type hints em tudo público
- [ ] Docstrings (público) + comentários de "porquê"
- [ ] Logging em boundaries e fluxos principais
- [ ] Sem secrets hardcoded ou em logs
- [ ] Testes cobrindo casos principais e edge cases
