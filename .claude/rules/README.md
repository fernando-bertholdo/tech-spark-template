# Regras Path-Targeted

Regras carregadas automaticamente conforme o path do arquivo sendo editado.

| Arquivo | Paths | Escopo |
|---|---|---|
| [code-quality.md](code-quality.md) | `src/**/*`, `*.py` | Formatação, type hints, docstrings, naming, logging |
| [security.md](security.md) | `src/**/*`, `.env*` | Secrets, error handling, logging seguro, validação |

**Diferenças vs `tech-product-template`:**
- Sem `testing-requirements.md` (vira parte da skill `validate-testing`)
- Sem `api-integration-patterns.md`, `artifact-governance.md`, `documentation-templates.md`
- Versões muito mais curtas (≤150 linhas cada)
