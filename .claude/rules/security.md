---
paths:
  - src/**/*
  - .env*
---

# Security (lite)

Path-targeted: aplica em `src/**/*` e `.env*`. Exemplos em Python; princípios são agnósticos.

## Regra de ouro

**NUNCA commitar dados sensíveis.** Não negociável:
- Nunca hardcodear credentials (senhas, tokens, API keys)
- Nunca commitar `.env`
- Nunca expor detalhes internos em mensagens de erro
- Nunca logar informações sensíveis

## Secrets via env vars

Usar biblioteca do stack (`pydantic-settings`, `dotenv`, equivalente). Carregar de `.env` (gitignored).

`.env.example` documenta as variáveis necessárias, **sem valores reais**.

## .gitignore

Deve incluir no mínimo:
```
.env
.env.local
.env.*.local
*.key
*.pem
```

## Error handling sem expor credenciais

```python
# OK
except requests.HTTPError as e:
    logger.error(f"API erro: status={e.response.status_code}", exc_info=True)
    raise ValueError("Falha ao acessar API") from e

# Não OK
except Exception as e:
    print(f"Erro: {e}")  # pode incluir URL, credenciais
```

## Logging seguro

- Mascarar secrets antes de logar (`logger.info(f"Password: {'*'*8}")`)
- Headers de autorização: substituir por `Bearer ***`
- Não logar payloads brutos que possam conter PII

## Validação de inputs

Inputs externos sempre validados (tipo, formato, range). Falhar com erro específico, não com stack trace.

## Checklist (DoD por commit)

- [ ] Nenhum secret hardcoded
- [ ] `.env` no `.gitignore` (verificar)
- [ ] `.env.example` sanitizado
- [ ] Error handling não expõe credenciais
- [ ] Logs não contêm senhas/tokens/PII
- [ ] Inputs externos validados

## Red flags — ação imediata

- **Secret commitado:** rotacionar credencial AGORA. Limpar histórico se necessário.
- **Senha em logs:** limpar logs, rotacionar senha.
- **API key vazada:** revogar, gerar nova.
