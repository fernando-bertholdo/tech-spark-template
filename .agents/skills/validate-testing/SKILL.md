---
name: validate-testing
description: Use após adicionar feature, corrigir bug, refatorar, ou antes de commit para validar que a suíte de testes roda e está estruturada. Detecta o stack via manifesto, executa o framework apropriado, e reporta cobertura como sugestão (não bloqueio). Pula graciosamente se `tests/` não existir ou estiver vazio, com mensagem informativa. Também serve como referência rápida para AAA pattern, naming convention, edge cases e diferença unit vs integration.
---

# Validate Testing (Opt-in / Light)

Skill leve para validar testes localmente. Sem gates de DoD, milestone ou roadmap — apenas execução e diagnóstico do que existe agora.

## Quando Usar

- Após implementar feature ou bugfix
- Após refatoração relevante
- Antes de `git commit` (complementa `pre-commit-check`)
- Quando quiser uma checagem rápida de "ainda passa?"

## Comportamento Quando Não Há Testes

Se `tests/` (ou diretório equivalente do stack) não existe ou está vazio:

```
Sem testes para validar; considere adicionar para regressão. Pulando.
```

Não bloqueia. Apenas registra a sugestão.

## Detecção de Stack (via manifesto)

| Manifesto presente | Stack | Comando de teste padrão |
|---|---|---|
| `pyproject.toml` ou `requirements*.txt` | Python | `pytest -q` |
| `package.json` | Node/TS | `npm test` (ou `npm test --if-present`) |
| `go.mod` | Go | `go test ./...` |
| `Cargo.toml` | Rust | `cargo test` |
| outro | — | usar comando declarado em `Projeto.md`, se houver |

Se o stack não estiver claro, peça confirmação antes de rodar.

## Procedimento

```
1. Verificar existência de testes
   - Se tests/ ausente ou vazio → mensagem "Sem testes..." e SAIR

2. Detectar stack via manifesto

3. Executar suíte (não-bloqueante se zero testes)
   - Python: pytest -q
   - Node:   npm test --if-present
   - Outros: comando do stack

4. (Opcional) Rodar cobertura, se ferramenta disponível
   - Python: pytest --cov=src --cov-report=term-missing
   - Node:   npm test -- --coverage   (se configurado)
   - Reportar como SUGESTÃO, não como gate

5. Reportar resultados
```

## Output (formato sugerido)

```
Validate Testing
================

Stack detectado: Python (pyproject.toml)
Suíte:    42 passed, 0 failed
Cobertura: 67%  (sugestão: ~80% para business logic)

Sugestões:
- Adicionar testes para src/services/normalizer.py (sem cobertura)
- Testar caso de input vazio em src/api/client.py
```

Se sem testes:

```
Validate Testing
================

Sem testes para validar; considere adicionar para regressão. Pulando.
```

## Bloqueadores vs Sugestões

| Situação | Tratamento |
|---|---|
| Suíte com falhas | BLOQUEIO (algum teste quebrou — investigar) |
| Cobertura abaixo de 80% | SUGESTÃO (não bloqueia) |
| Sem testes | SUGESTÃO (não bloqueia, apenas registra) |
| Testes flaky (intermitentes) | SUGESTÃO de estabilização |

---

## Referência Rápida — Como Escrever Bons Testes

Esta seção absorve o essencial de uma rule de testing tradicional.

### AAA Pattern (Arrange-Act-Assert)

Todo teste deve ter três blocos claros:

```python
def test_calcular_metrica_caso_normal():
    """Testa cálculo de métrica em caso normal."""
    # Arrange (preparar dados)
    valor_base = 750.0
    fator = 1.5

    # Act (executar função sob teste)
    resultado = calcular_metrica(valor_base, fator)

    # Assert (validar resultado)
    assert resultado == 1125.0
```

### Naming Convention

**Formato:** `test_<function>_<scenario>_<expected>`

```python
def test_calcular_metrica_caso_normal():               # happy path
def test_calcular_metrica_quando_valor_zero_deve_lancar_erro():
def test_calcular_metrica_quando_negativo_deve_retornar_zero():
```

Nomes longos são bons aqui — descrevem o cenário e o resultado esperado em uma única linha.

### Edge Cases Mínimos

Para cada função pública, cobrir pelo menos:

1. **Valores extremos** — zero, negativo, vazio, `None`, máximo/mínimo
   ```python
   def test_calcular_quando_valor_zero_deve_retornar_zero(): ...
   def test_calcular_quando_fator_none_deve_retornar_none(): ...
   ```

2. **Inputs inválidos** — tipos errados, formato errado, fora do domínio
   ```python
   def test_processar_quando_id_vazio_deve_lancar_erro():
       with pytest.raises(ValueError):
           processar("")
   ```

3. **Estados não-esperados** — dados incompletos, ordem inesperada, ausência de dependência
   ```python
   def test_processar_quando_dados_incompletos_deve_flagear():
       resultado = processar({"id": "X"})  # falta 'valor'
       assert resultado["qualidade"] == "INCOMPLETO"
   ```

Testar apenas o happy path é insuficiente.

### Unit vs Integration (brevemente)

| Tipo | Escopo | Dependências externas | Velocidade |
|---|---|---|---|
| **Unit** | Função/classe isolada | Mocadas | Rápido (ms) |
| **Integration** | Componentes juntos (pipeline, API client + parser, etc.) | Mocks de I/O externo; uso de DB/serviços de teste local quando necessário | Mais lento |

Sugestão de estrutura:

```
tests/
  unit/          # funções isoladas
  integration/   # componentes juntos
  fixtures/      # dados e mocks reutilizáveis
```

Mantenha unit tests determinísticos (sem rede, sem clock real, sem random sem seed). Integration tests podem precisar de fixtures mais elaboradas, mas devem permanecer hermetic quando possível.

### Sinais de Saúde dos Testes

- Determinísticos (mesmo input → mesmo resultado, sempre)
- Independentes (qualquer ordem, qualquer subset)
- Rápidos (suíte unit < poucos segundos em projeto pequeno)
- Legíveis (o nome do teste explica o caso)
- Sem secrets reais; usar `.env.test` ou mocks

## Integração com outros skills

- `pre-commit-check` — usa este skill como sub-passo de "Testing"
- `organize-commits` — útil para separar adições de teste em commits próprios

## Cobertura como Sugestão (não meta imposta)

Referências usuais (não bloqueio neste template):

- Business logic: ~90%
- Integrações e utilitários: ~80%
- Overall projeto: ~80%

Se o projeto quiser tornar isso obrigatório, configure `--cov-fail-under=N` no `pyproject.toml` (ou equivalente) e o gate passa a ser do tooling, não desta skill.
