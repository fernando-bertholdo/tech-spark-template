#!/usr/bin/env bash
#
# check-pareamento-instrucoes.sh
#
# Gate de pareamento entre as famílias de instruções de agente do repositório
# (hoje .claude/ e .agents/). Um arquivo homônimo às duas famílias é byte a byte
# idêntico, ou a diferença está declarada com motivo no arquivo de exceções.
#
# Regras — o gate falha em qualquer uma:
#   1. Homônimo com conteúdo diferente e sem linha `divergencia` ou `drift`.
#   2. Arquivo presente numa família e ausente na outra, sem linha `solo`.
#   3. Exceção obsoleta (DL-1): alvo que não existe mais, par que voltou a ser
#      idêntico, ou `solo` cujo arquivo passou a ter par. Falha igual a drift.
#
# O gate itera `git ls-files`, nunca o filesystem (DL-2): o workdir do runtime
# Multica injeta .claude/ próprio, e varrer o disco contaminaria a comparação.
#
# Arquivo de exceções — uma linha por exceção, `tipo | caminho | motivo`,
# com `#` iniciando comentário:
#
#   solo        | .claude/settings.json | configuração exclusiva do Claude Code
#   divergencia | rules/README.md       | .claude/ usa frontmatter path-targeted
#   drift       | skills/agent-team/SKILL.md | pendente — TECH-106 PR-3
#
# `solo` usa o caminho com o prefixo da família (é sobre um arquivo).
# `divergencia` e `drift` usam o caminho relativo à família (é sobre o par).
#
# Uso:
#   scripts/validate/check-pareamento-instrucoes.sh
#   scripts/validate/check-pareamento-instrucoes.sh --excecoes <arquivo>
#
# Exit codes:
#   0  pareamento íntegro
#   1  erro de argumento
#   2  violação de pareamento (drift não declarado, solo não declarado, obsoleta)
#   3  arquivo de exceções ausente ou malformado
#   5  pré-requisito de ambiente ausente

set -euo pipefail

# Estender o gate a uma terceira camada é acrescentar o diretório aqui.
readonly FAMILIAS=(".claude" ".agents")

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log()  { printf '[pareamento] %s\n' "$*"; }
die()  { printf '[pareamento] ERRO: %s\n' "$1" >&2; exit "${2:-1}"; }

trim() { printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

VIOLACOES=0
viol() {
  printf '[pareamento] %-22s %s\n                       → %s\n' "$1" "$2" "$3" >&2
  VIOLACOES=$((VIOLACOES + 1))
}

# ---------------------------------------------------------------------------
# Argumentos
# ---------------------------------------------------------------------------
EXCECOES=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --excecoes)   EXCECOES="${2:-}"; shift 2 ;;
    --excecoes=*) EXCECOES="${1#*=}"; shift ;;
    -h|--help)    sed -n '3,35p' "$0"; exit 0 ;;
    *)            die "argumento desconhecido: $1" 1 ;;
  esac
done

command -v git >/dev/null 2>&1 || die "git não encontrado no PATH." 5

REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$REPO_ROOT" ]] || die "fora de um repositório git — o gate depende de 'git ls-files' (DL-2)." 5

[[ -n "$EXCECOES" ]] || EXCECOES="$REPO_ROOT/scripts/validate/pareamento-instrucoes-excecoes.txt"
[[ -f "$EXCECOES" ]] || die "arquivo de exceções não encontrado: $EXCECOES" 3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
# Inventário por família — git ls-files, nunca o filesystem (DL-2)
# ---------------------------------------------------------------------------
fam_index() {
  local alvo="$1" k
  for k in "${!FAMILIAS[@]}"; do
    [[ "${FAMILIAS[$k]}" == "$alvo" ]] && { printf '%s' "$k"; return 0; }
  done
  return 1
}

for i in "${!FAMILIAS[@]}"; do
  fam="${FAMILIAS[$i]}"
  git -C "$REPO_ROOT" ls-files -- "$fam" | cut -c "$(( ${#fam} + 2 ))-" | sort > "$TMP/fam.$i"
done

# ---------------------------------------------------------------------------
# Leitura e validação de formato das exceções
# ---------------------------------------------------------------------------
EXC_TIPO=(); EXC_ALVO=(); EXC_LINHA=(); EXC_USADA=()
ERROS_FORMATO=0
lineno=0

while IFS= read -r bruta || [[ -n "$bruta" ]]; do
  lineno=$((lineno + 1))
  linha="$(trim "${bruta%%#*}")"
  [[ -z "$linha" ]] && continue

  IFS='|' read -r tipo alvo motivo <<<"$linha"
  tipo="$(trim "${tipo:-}")"; alvo="$(trim "${alvo:-}")"; motivo="$(trim "${motivo:-}")"

  erro=""
  case "$tipo" in
    solo)
      fam="${alvo%%/*}"
      if [[ "$fam" == "$alvo" ]] || ! fam_index "$fam" >/dev/null; then
        erro="'solo' exige caminho prefixado por uma família conhecida (${FAMILIAS[*]})"
      fi
      ;;
    divergencia|drift)
      if fam_index "${alvo%%/*}" >/dev/null; then
        erro="'$tipo' usa o caminho relativo à família, sem o prefixo '${alvo%%/*}/'"
      fi
      ;;
    "") erro="linha sem tipo" ;;
    *)  erro="tipo desconhecido: '$tipo' (use solo, divergencia ou drift)" ;;
  esac
  [[ -z "$erro" && -z "$alvo" ]]  && erro="caminho vazio"
  [[ -z "$erro" && -z "$motivo" ]] && erro="motivo ausente — exceção sem motivo não é auditável"

  for k in "${!EXC_ALVO[@]}"; do
    [[ -z "$erro" && "${EXC_ALVO[$k]}" == "$alvo" && "${EXC_TIPO[$k]}" == "$tipo" ]] &&
      erro="duplicata de '$tipo | $alvo' (já declarado na linha ${EXC_LINHA[$k]})"
  done

  if [[ -n "$erro" ]]; then
    printf '[pareamento] FORMATO linha %s: %s\n' "$lineno" "$erro" >&2
    ERROS_FORMATO=$((ERROS_FORMATO + 1))
    continue
  fi

  EXC_TIPO+=("$tipo"); EXC_ALVO+=("$alvo"); EXC_LINHA+=("$lineno"); EXC_USADA+=("")
done < "$EXCECOES"

[[ "$ERROS_FORMATO" -eq 0 ]] || die "$ERROS_FORMATO linha(s) malformada(s) em $EXCECOES" 3

# Localiza uma exceção por tipo(s) e alvo, e a marca como consumida.
consumir() {
  local tipos="$1" alvo="$2" k
  for k in "${!EXC_ALVO[@]}"; do
    if [[ "${EXC_ALVO[$k]}" == "$alvo" && "|$tipos|" == *"|${EXC_TIPO[$k]}|"* ]]; then
      EXC_USADA[$k]="sim"; return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Regras 1 e 2 — par a par entre as famílias
# ---------------------------------------------------------------------------
for ((i = 0; i < ${#FAMILIAS[@]}; i++)); do
  for ((j = i + 1; j < ${#FAMILIAS[@]}; j++)); do
    A="${FAMILIAS[$i]}"; B="${FAMILIAS[$j]}"

    comm -12 "$TMP/fam.$i" "$TMP/fam.$j" > "$TMP/homonimos"
    while IFS= read -r rel; do
      cmp -s "$REPO_ROOT/$A/$rel" "$REPO_ROOT/$B/$rel" && continue
      consumir "divergencia|drift" "$rel" && continue
      viol "DRIFT NÃO DECLARADO" "$A/$rel × $B/$rel" \
        "reconcilie os dois arquivos, ou declare 'divergencia | $rel | <motivo>' em $(basename "$EXCECOES")"
    done < "$TMP/homonimos"

    comm -23 "$TMP/fam.$i" "$TMP/fam.$j" > "$TMP/so-em-A"
    comm -13 "$TMP/fam.$i" "$TMP/fam.$j" > "$TMP/so-em-B"
    for lado in "A:$A:$B:$TMP/so-em-A" "B:$B:$A:$TMP/so-em-B"; do
      IFS=':' read -r _ tem falta lista <<<"$lado"
      while IFS= read -r rel; do
        consumir "solo" "$tem/$rel" && continue
        viol "SOLO NÃO DECLARADO" "$tem/$rel" \
          "crie $falta/$rel, ou declare 'solo | $tem/$rel | <motivo>' em $(basename "$EXCECOES")"
      done < "$lista"
    done
  done
done

# ---------------------------------------------------------------------------
# Regra 3 (DL-1) — toda exceção não consumida é obsoleta
# ---------------------------------------------------------------------------
for k in "${!EXC_ALVO[@]}"; do
  [[ -n "${EXC_USADA[$k]}" ]] && continue
  tipo="${EXC_TIPO[$k]}"; alvo="${EXC_ALVO[$k]}"; ln="${EXC_LINHA[$k]}"

  if [[ "$tipo" == "solo" ]]; then
    fam="${alvo%%/*}"; rel="${alvo#*/}"
    idx="$(fam_index "$fam")"
    if grep -Fxq "$rel" "$TMP/fam.$idx"; then
      causa="o arquivo deixou de ser exclusivo — já existe par em outra família"
    else
      causa="o arquivo não é mais rastreado em $fam/"
    fi
  else
    presentes=0
    for i in "${!FAMILIAS[@]}"; do
      grep -Fxq "$alvo" "$TMP/fam.$i" && presentes=$((presentes + 1))
    done
    case "$presentes" in
      0) causa="nenhuma família rastreia esse caminho" ;;
      1) causa="deixou de ser homônimo — virou exclusivo; declare como 'solo'" ;;
      *) causa="o par voltou a ser byte a byte idêntico" ;;
    esac
  fi

  viol "EXCEÇÃO OBSOLETA" "linha $ln: $tipo | $alvo" \
    "$causa — remova a linha de $(basename "$EXCECOES")"
done

# ---------------------------------------------------------------------------
if [[ "$VIOLACOES" -gt 0 ]]; then
  printf '[pareamento] %s violação(ões). Pareamento reprovado.\n' "$VIOLACOES" >&2
  exit 2
fi

log "pareamento íntegro entre ${FAMILIAS[*]} — ${#EXC_ALVO[@]} exceção(ões) declarada(s) e em uso."
