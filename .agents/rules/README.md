# Regras Técnicas

Regras de engenharia da camada `.agents/`. O formato agents não tem carregamento
condicional por path: o escopo abaixo diz a que tipo de arquivo cada regra se
aplica, e cabe ao agente consultá-la ao tocar esses arquivos.

| Arquivo | Escopo de arquivos | Assunto |
|---|---|---|
| [code-quality.md](code-quality.md) | `src/**/*`, `*.py` | Formatação, type hints, docstrings, naming, logging |
| [security.md](security.md) | `src/**/*`, `.env*` | Secrets, error handling, logging seguro, validação |

**Diferenças vs `tech-product-template`:**
- Sem `testing-requirements.md` (vira parte da skill `validate-testing`)
- Sem `api-integration-patterns.md`, `artifact-governance.md`, `documentation-templates.md`
- Versões muito mais curtas (≤150 linhas cada)
