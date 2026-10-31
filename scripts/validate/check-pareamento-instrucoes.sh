#!/usr/bin/env bash
#
# check-pareamento-instrucoes.sh
#
# Gate de pareamento entre as duas cópias das skills do repositório,
# .claude/skills/ e .agents/skills/. Um arquivo homônimo às duas famílias é byte
# a byte idêntico, ou a diferença está declarada no arquivo de exceções: com
# motivo, e com o trecho em que ela pode estar.
#
# Regras — o gate falha em qualquer uma:
#   1. Homônimo com conteúdo diferente e sem linha `divergencia` ou `drift`; ou
#      com `divergencia`, e diferente FORA do que as linhas `trecho` e `secao`
#      do mesmo caminho declaram (TECH-698).
#   2. Arquivo presente numa família e ausente na outra, sem linha `solo`.
#   3. Exceção obsoleta (DL-1): alvo que não existe mais, par que voltou a ser
#      idêntico, `solo` cujo arquivo passou a ter par, ou `trecho` e `secao` que
#      não casam em nenhum dos dois lados. Falha igual a drift.
#   4. Par com `divergencia` em que as declarações deixam, de algum dos lados,
#      menos de 50% (PISO_COMPARADO) das linhas de texto para comparar, sem
#      que o caminho tenha declarado `secao | <caminho> | *`: a isenção ampla não
#      pode sair, sem aviso, de declarações que pareciam finas, nem quando sobra
#      um resíduo como o frontmatter (TECH-698, rodadas 1 e 2 da revisão).
#   5. Arquivo versionado numa camada aposentada: .codex/skills/,
#      .codex/rules/*.md, .agents/rules/, .agents/prompts/ ou .codex/prompts/.
#      As três primeiras saíram na TECH-852, por decisão do Fernando de
#      01/10/2026 na TECH-846: as rules porque o Codex 0.145 não relatou nenhuma
#      na medição da TECH-699 (recorte no AGENTS.md, §6), e .codex/skills/
#      porque repetia .agents/skills/, que o Codex também lê. As duas de
#      prompts/ saíram na TECH-894, pela decisão (a) do Fernando registrada na
#      TECH-852 em 02/10/2026: os prompts vivem só em .claude/prompts/. Cópia
#      que voltasse seria paridade a manter sem ganho. Em
#      .codex/rules/ só o .md reprova: o arquivo `.rules` de regra de comando
#      (DL-4 da TECH-852) mora ali desde o PR-2 da TECH-852 (merge 3e28a6f),
#      e não é rule em Markdown.
#
# O gate itera `git ls-files`, nunca o filesystem (DL-2): o workdir do runtime
# Multica injeta .claude/ próprio, e varrer o disco contaminaria a comparação.
#
# Alcance: `.claude/skills/` × `.agents/skills/`, e nada mais das duas famílias.
# Desde a TECH-852 as rules vivem só em `.claude/rules/`, e ponto de entrada,
# hooks, planos, configuração, workflows, stacks e prompts existem numa família
# só (`stacks/` tem cópia idêntica em `.codex/stacks/`, fora das duas famílias e
# sem gate que a compare). As cópias de `prompts/` fora do `.claude` saíram na
# TECH-894 e são camada aposentada (regra 5): uma que volte a `.agents/prompts/`
# ou a `.codex/prompts/` reprova, e os cenários P33 e P35 do harness provam
# isso. Em 02/10/2026, na branch da TECH-894, nenhum par homônimo sobrava fora
# de `skills/`; o comando que decide, vazio quando não há par:
#   comm -12 <(git ls-files .claude | sed 's#^\.claude/##' | sort) \
#            <(git ls-files .agents | sed 's#^\.agents/##' | sort) | grep -v '^skills/'
# Um par novo fora de `skills/` e fora das camadas aposentadas passa por este
# gate sem ser comparado.
# Exceção cujo caminho cai fora de `skills/` é arquivo malformado (exit 3):
# ela não teria o que isentar.
#
# Arquivo de exceções — uma linha por exceção, `tipo | caminho | motivo`,
# com `#` iniciando comentário:
#
#   solo           | .claude/skills/x/spawn.md | prompt que só o Claude Code lê
#   divergencia    | skills/x/SKILL.md     | cada camada cita o próprio diretório
#   trecho .claude | skills/x/SKILL.md     | .claude/skills/
#   trecho .agents | skills/x/SKILL.md     | .agents/skills/
#   secao          | skills/x/SKILL.md     | ## Changelog Local
#   drift          | skills/y/SKILL.md     | pendente — TECH-106 PR-3
#
# `solo` usa o caminho com o prefixo da família (é sobre um arquivo).
# `divergencia` e `drift` usam o caminho relativo à família (é sobre o par).
#
# `trecho` e `secao` qualificam a `divergencia` do mesmo caminho e dizem ONDE o
# par pode divergir. No lugar do motivo vem um literal, cru — pode ter '|' e
# '#'; só o espaço das pontas sai, e por isso essas linhas não têm comentário:
#   trecho <família>  cada ocorrência do literal sai do lado daquela família
#           antes da comparação, e só dele: no outro lado o mesmo texto é
#           comparado, e a cópia que cita a camada errada é acusada. Sai o
#           literal, não a linha que o contém; a linha que ficou vazia sai junto.
#   secao   a seção de título ATX igual ao literal sai inteira dos dois lados,
#           até o próximo título de nível igual ou superior, fora de bloco de
#           código; título com recuo de até 3 espaços conta, como no
#           CommonMark, e título setext (sublinhado) não é reconhecido. O literal `---` é o frontmatter YAML do topo do arquivo, e
#           o literal `*` é o arquivo inteiro: a isenção total, que só existe
#           declarada assim, sozinha no caminho, e que o gate lista em toda
#           rodada aprovada.
# O resto é comparado byte a byte, e `divergencia` sem `trecho` nem `secao` não
# isenta nada. Declare o literal mais longo que ainda casa: um literal curto
# isenta toda ocorrência dele. `drift` segue isentando o par inteiro, porque é
# dívida com dono, não desenho, e não tem trecho a declarar.
#
# Uso:
#   scripts/validate/check-pareamento-instrucoes.sh
#   scripts/validate/check-pareamento-instrucoes.sh --excecoes <arquivo>
#
# Exit codes:
#   0  pareamento íntegro
#   1  erro de argumento
#   2  violação de pareamento (drift não declarado, drift fora do trecho, solo
#      não declarado, exceção obsoleta, isenção ampla não declarada, arquivo
#      versionado em camada aposentada)
#   3  arquivo de exceções ausente ou malformado
#   5  pré-requisito de ambiente ausente

set -euo pipefail

# As duas famílias e o recorte comparado dentro delas. O caminho que as exceções
# declaram continua relativo à família (`skills/x/SKILL.md`), e por isso o
# recorte é um diretório dentro de cada família, e não a família em si.
#
# Parte das divergências entre as cópias é desenho, não drift: são runtimes
# diferentes, e a skill `agent-team` difere por isso. Separar desenho de drift,
# par a par, é decisão de quem governa as camadas.
#
readonly FAMILIAS=(".claude" ".agents")
readonly ALCANCE="skills"

# Camadas aposentadas na TECH-852, como pathspec do `git ls-files`: arquivo
# versionado que case qualquer uma reprova (regra 5).
readonly APOSENTADAS=(".codex/skills/" ".codex/rules/*.md" ".agents/rules/" ".agents/prompts/" ".codex/prompts/")

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
    -h|--help)    sed -n '3,/^set -euo/{/^set -euo/!p;}' "$0"; exit 0 ;;
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
  git -C "$REPO_ROOT" ls-files -- "$fam/$ALCANCE/" | cut -c "$(( ${#fam} + 2 ))-" | sort > "$TMP/fam.$i"
done

# ---------------------------------------------------------------------------
# Leitura e validação de formato das exceções
# ---------------------------------------------------------------------------
EXC_TIPO=(); EXC_ALVO=(); EXC_LINHA=(); EXC_USADA=()
TR_TIPO=(); TR_LADO=(); TR_ALVO=(); TR_LIT=(); TR_LINHA=(); TR_USADA=()
ERROS_FORMATO=0
lineno=0

formato() {
  printf '[pareamento] FORMATO linha %s: %s\n' "$lineno" "$1" >&2
  ERROS_FORMATO=$((ERROS_FORMATO + 1))
}

while IFS= read -r bruta || [[ -n "$bruta" ]]; do
  lineno=$((lineno + 1))
  crua="$(trim "$bruta")"
  [[ -z "$crua" || "$crua" == \#* ]] && continue

  # `trecho` e `secao`: o literal é o texto depois do segundo '|', cru — ele
  # pode conter '|' e '#', que linha de tabela e título Markdown têm. Só o
  # espaço das pontas sai, e por isso não há comentário no fim dessas linhas.
  tipo="$(trim "${crua%%|*}")"; lado=""
  if [[ "$tipo" == "trecho "* ]]; then lado="$(trim "${tipo#trecho }")"; tipo="trecho"; fi
  if [[ "$tipo" == "trecho" || "$tipo" == "secao" ]]; then
    resto="${crua#*|}"
    if [[ "$crua" != *"|"*"|"* ]]; then
      formato "'$tipo' exige 'tipo | caminho | literal'"; continue
    fi
    alvo="$(trim "${resto%%|*}")"; literal="$(trim "${resto#*|}")"
    erro=""
    fam_index "${alvo%%/*}" >/dev/null &&
      erro="'$tipo' usa o caminho relativo à família, sem o prefixo '${alvo%%/*}/'"
    [[ -z "$erro" && -z "$alvo" ]] && erro="caminho vazio"
    [[ -z "$erro" && "$alvo" != "$ALCANCE/"* ]] && erro="caminho fora do alcance do gate ($ALCANCE/): $alvo"
    [[ -z "$erro" && -z "$literal" ]] && erro="literal vazio — o '$tipo' não diz o que pode divergir"
    [[ -z "$erro" && "$tipo" == "trecho" && -z "$lado" ]] &&
      erro="'trecho' exige o lado de onde o literal sai: 'trecho <família>', com a família em (${FAMILIAS[*]})"
    [[ -z "$erro" && -n "$lado" ]] && ! fam_index "$lado" >/dev/null &&
      erro="'trecho $lado': o lado deve ser uma família conhecida (${FAMILIAS[*]})"
    for k in "${!TR_ALVO[@]}"; do
      [[ -z "$erro" && "${TR_TIPO[$k]}|${TR_LADO[$k]}|${TR_ALVO[$k]}|${TR_LIT[$k]}" == "$tipo|$lado|$alvo|$literal" ]] &&
        erro="duplicata de '$tipo${lado:+ $lado} | $alvo | $literal' (já declarado na linha ${TR_LINHA[$k]})"
    done
    if [[ -n "$erro" ]]; then formato "$erro"; continue; fi
    TR_TIPO+=("$tipo"); TR_LADO+=("$lado"); TR_ALVO+=("$alvo"); TR_LIT+=("$literal"); TR_LINHA+=("$lineno"); TR_USADA+=("")
    continue
  fi

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
    *)  erro="tipo desconhecido: '$tipo' (use solo, divergencia, drift, trecho ou secao)" ;;
  esac
  [[ -z "$erro" && -z "$alvo" ]]  && erro="caminho vazio"
  if [[ -z "$erro" && -n "$tipo" ]]; then
    rel="$alvo"; [[ "$tipo" == "solo" ]] && rel="${alvo#*/}"
    [[ "$rel" == "$ALCANCE/"* ]] || erro="caminho fora do alcance do gate ($ALCANCE/): $alvo"
  fi
  [[ -z "$erro" && -z "$motivo" ]] && erro="motivo ausente — exceção sem motivo não é auditável"

  for k in "${!EXC_ALVO[@]}"; do
    [[ -z "$erro" && "${EXC_ALVO[$k]}" == "$alvo" && "${EXC_TIPO[$k]}" == "$tipo" ]] &&
      erro="duplicata de '$tipo | $alvo' (já declarado na linha ${EXC_LINHA[$k]})"
  done

  if [[ -n "$erro" ]]; then formato "$erro"; continue; fi

  EXC_TIPO+=("$tipo"); EXC_ALVO+=("$alvo"); EXC_LINHA+=("$lineno"); EXC_USADA+=("")
done < "$EXCECOES"

# `trecho` e `secao` qualificam uma `divergencia` — sozinhos não isentam nada, e
# ao lado de um `drift`, que já isenta o par inteiro, não restringiriam nada.
declarou() {
  local tipo="$1" alvo="$2" k
  for k in "${!EXC_ALVO[@]}"; do
    [[ "${EXC_TIPO[$k]}" == "$tipo" && "${EXC_ALVO[$k]}" == "$alvo" ]] && return 0
  done
  return 1
}
for k in "${!TR_ALVO[@]}"; do
  lineno="${TR_LINHA[$k]}"
  declarou divergencia "${TR_ALVO[$k]}" ||
    formato "'${TR_TIPO[$k]}' sem 'divergencia' para o mesmo caminho: ${TR_ALVO[$k]}"
done
for k in "${!TR_ALVO[@]}"; do
  [[ "${TR_TIPO[$k]}" == "secao" && "${TR_LIT[$k]}" == "*" ]] || continue
  for j in "${!TR_ALVO[@]}"; do
    [[ "$j" != "$k" && "${TR_ALVO[$j]}" == "${TR_ALVO[$k]}" ]] || continue
    lineno="${TR_LINHA[$j]}"
    formato "'secao | ${TR_ALVO[$k]} | *' isenta o arquivo inteiro: esta linha não teria efeito"
  done
done
for k in "${!EXC_ALVO[@]}"; do
  lineno="${EXC_LINHA[$k]}"
  [[ "${EXC_TIPO[$k]}" == "divergencia" ]] && declarou drift "${EXC_ALVO[$k]}" &&
    formato "'divergencia' e 'drift' para o mesmo caminho: ${EXC_ALVO[$k]} — escolha um"
done

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

# Normaliza um lado do par: tira as seções declaradas (do título ATX igual ao
# literal, espaço do fim à parte, até a véspera do próximo título de nível
# igual ou superior, fora de bloco de código) e cada ocorrência dos trechos
# declarados; a linha que um trecho esvaziou sai junto, para que o mesmo texto
# partido em mais ou menos linhas de cada lado compare igual. Escreve em
# ACHOU o que casou: `T<n>` e `S<n>`, na ordem dos arquivos de literais. A
# `secao` de literal `---` é o frontmatter YAML: da linha 1, se ela for `---`,
# até o `---` seguinte, mais as linhas em branco logo depois dele.
cat > "$TMP/normalizar.awk" <<'AWK'
function corrida(s,   i) { i = 1; while (substr(s, i + 1, 1) == substr(s, 1, 1)) i++; return i }
BEGIN {
  while ((getline l < LITS) > 0) lit[++n] = l
  while ((getline l < SECS) > 0) sec[++m] = l
}
NR == 1 && $0 == "---" { for (k = 1; k <= m; k++) if (sec[k] == "---") { fm = 1; achou["S" k] = 1; next } }
fm == 1 { if ($0 == "---") fm = 2; next }
fm == 2 { if ($0 ~ /^[ \t]*$/) next; fm = 0 }
{
  linha = $0; titulo = 0
  match(linha, /^ */); recuo = RLENGTH; t = substr(linha, recuo + 1)
  if (cerca != "") {
    if (recuo <= 3 && substr(t, 1, 1) == cerca && corrida(t) >= tam &&
        substr(t, corrida(t) + 1) ~ /^[ \t]*$/) cerca = ""
  } else if (recuo <= 3 && (substr(t, 1, 3) == "```" || substr(t, 1, 3) == "~~~")) {
    cerca = substr(t, 1, 1); tam = corrida(t)
  } else if (recuo <= 3 && t ~ /^#+([ \t]|$)/ && corrida(t) <= 6) {
    titulo = 1; nivel = corrida(t)
  }
  if (titulo) {
    if (pulando && nivel <= nivel_pulo) pulando = 0
    sub(/[ \t]+$/, "", t)
    for (k = 1; !pulando && k <= m; k++)
      if (t == sec[k]) { pulando = 1; nivel_pulo = nivel; achou["S" k] = 1 }
  }
  if (pulando) next
  mudou = 0
  for (k = 1; k <= n; k++)
    while ((p = index(linha, lit[k])) > 0) {
      linha = substr(linha, 1, p - 1) substr(linha, p + length(lit[k])); mudou = 1; achou["T" k] = 1
    }
  if (mudou && linha ~ /^[ \t]*$/) next
  print linha
}
END { for (c in achou) print c > ACHOU }
AWK

# Compara o par fora do que as linhas `trecho` e `secao` do caminho declaram, e
# marca como usadas as que casaram em algum dos dois lados. Exit 0 = iguais,
# 1 = diferentes, 2 = sobrou menos de PISO_COMPARADO% das linhas de texto de um
# lado (isenção ampla que não foi declarada com `secao | ... | *`).
#
# O piso é medido, não escolhido no escuro: em 01/10/2026 o par real com menos
# texto comparado era `skills/agent-team/SKILL.md`, lado `.agents`, com 63%
# (207 de 327 linhas de texto); a `secao` de título nível 1 que a rodada 2 da
# revisão usou de contraexemplo deixava 2% (4 de 170). Par legítimo abaixo do
# piso se declara inteiro, com `*`, e aparece na lista.
readonly PISO_COMPARADO=50
INTEIROS=(); SOBROU=""
comparar_fora_do_trecho() {
  local a="$1" b="$2" rel="$3" k c lado
  local -a ids_t=() ids_s=()
  for k in "${!TR_ALVO[@]}"; do
    [[ "${TR_ALVO[$k]}" == "$rel" && "${TR_TIPO[$k]}" == "secao" && "${TR_LIT[$k]}" == "*" ]] || continue
    TR_USADA[$k]="sim"; INTEIROS+=("$rel"); return 0
  done
  # O trecho sai só do lado que ele declara: um literal de `.claude` que aparece
  # na cópia de `.agents` é texto comparado, e a troca de camada é acusada.
  : > "$TMP/secs"
  for k in "${!TR_ALVO[@]}"; do
    [[ "${TR_ALVO[$k]}" == "$rel" && "${TR_TIPO[$k]}" == "secao" ]] || continue
    printf '%s\n' "${TR_LIT[$k]}" >> "$TMP/secs"; ids_s+=("$k")
  done
  for lado in a b; do
    [[ "$lado" == a ]] && c="$a" || c="$b"
    : > "$TMP/lits.$lado"; : > "$TMP/achou.$lado"; ids_t=()
    for k in "${!TR_ALVO[@]}"; do
      [[ "${TR_ALVO[$k]}" == "$rel" && "${TR_TIPO[$k]}" == "trecho" ]] || continue
      [[ "${TR_LADO[$k]}" == "$c" ]] || continue
      printf '%s\n' "${TR_LIT[$k]}" >> "$TMP/lits.$lado"; ids_t+=("$k")
    done
    awk -v LITS="$TMP/lits.$lado" -v SECS="$TMP/secs" -v ACHOU="$TMP/achou.$lado" \
      -f "$TMP/normalizar.awk" "$REPO_ROOT/$c/$rel" > "$TMP/norm.$lado"
    while IFS= read -r c; do
      case "$c" in
        T*) TR_USADA[${ids_t[$(( ${c#T} - 1 ))]}]="sim" ;;
        S*) TR_USADA[${ids_s[$(( ${c#S} - 1 ))]}]="sim" ;;
      esac
    done < "$TMP/achou.$lado"
  done
  local bruto norm pct baixo=""
  SOBROU=""
  for lado in a b; do
    [[ "$lado" == a ]] && c="$a" || c="$b"
    bruto="$(grep -c '[^[:space:]]' "$REPO_ROOT/$c/$rel" || true)"
    norm="$(grep -c '[^[:space:]]' "$TMP/norm.$lado" || true)"
    pct=0; [[ "$bruto" -gt 0 ]] && pct=$(( norm * 100 / bruto ))
    SOBROU+="${SOBROU:+, }$c $pct% ($norm de $bruto)"
    [[ "$pct" -ge "$PISO_COMPARADO" ]] || baixo="sim"
  done
  [[ -z "$baixo" ]] || return 2
  cmp -s "$TMP/norm.a" "$TMP/norm.b"
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
      consumir "drift" "$rel" && continue
      if consumir "divergencia" "$rel"; then
        rc=0; comparar_fora_do_trecho "$A" "$B" "$rel" || rc=$?
        [[ "$rc" -eq 0 ]] && continue
        if [[ "$rc" -eq 2 ]]; then
          viol "ISENÇÃO AMPLA NÃO DECLARADA" "$A/$rel × $B/$rel" \
            "sobra para comparar $SOBROU, abaixo do piso de $PISO_COMPARADO% — declare menos, ou assuma a isenção total com 'secao | $rel | *'"
          continue
        fi
        viol "DRIFT FORA DO TRECHO" "$A/$rel × $B/$rel" \
          "a diferença passa do que 'trecho' e 'secao' declaram para '$rel' — reconcilie, ou declare o trecho em $(basename "$EXCECOES")"
        { diff "$TMP/norm.a" "$TMP/norm.b" | head -n 8 | sed 's/^/                         /' >&2; } || true
        continue
      fi
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

# O mesmo vale para o trecho: o que não casa em nenhum dos dois lados não está
# isentando nada, e deixá-lo ali faria a lista apodrecer em silêncio.
for k in "${!TR_ALVO[@]}"; do
  [[ -n "${TR_USADA[$k]}" ]] && continue
  tipo="${TR_TIPO[$k]}"; alvo="${TR_ALVO[$k]}"
  usada=""
  for j in "${!EXC_ALVO[@]}"; do
    [[ "${EXC_TIPO[$j]}" == "divergencia" && "${EXC_ALVO[$j]}" == "$alvo" ]] && usada="${EXC_USADA[$j]}"
  done
  if [[ -z "$usada" ]]; then
    causa="a 'divergencia' desse caminho não está em uso"
  elif [[ "$tipo" == "trecho" ]]; then
    causa="o literal não aparece no lado ${TR_LADO[$k]}, fora das seções isentas"
  else
    causa="nenhum título é igual a esse literal, em nenhum dos dois lados, fora de bloco de código"
  fi
  viol "EXCEÇÃO OBSOLETA" "linha ${TR_LINHA[$k]}: $tipo${TR_LADO[$k]:+ ${TR_LADO[$k]}} | $alvo | ${TR_LIT[$k]}" \
    "$causa — remova a linha de $(basename "$EXCECOES")"
done

# ---------------------------------------------------------------------------
# Regra 5 — nenhum arquivo versionado nas camadas aposentadas
# ---------------------------------------------------------------------------
# A lista sai antes do laço, e não por substituição de processo: um `ls-files`
# que falhasse ali deixaria o laço vazio e a regra aprovaria sem ter olhado.
aposentados="$(git -C "$REPO_ROOT" ls-files -- "${APOSENTADAS[@]}")" ||
  die "git ls-files falhou ao listar as camadas aposentadas." 5
while IFS= read -r f; do
  [[ -n "$f" ]] || continue
  viol "CAMADA APOSENTADA" "$f" \
    "a pasta saiu na TECH-852 (regra 5 do cabeçalho) — apague o arquivo, ou leve-o a .claude/ (rules, prompts) ou a .agents/skills/"
done <<<"$aposentados"

# ---------------------------------------------------------------------------
if [[ "$VIOLACOES" -gt 0 ]]; then
  printf '[pareamento] %s violação(ões). Pareamento reprovado.\n' "$VIOLACOES" >&2
  exit 2
fi

log "pareamento íntegro entre ${FAMILIAS[0]}/$ALCANCE ${FAMILIAS[1]}/$ALCANCE — ${#EXC_ALVO[@]} exceção(ões) declarada(s) e em uso; ${#TR_ALVO[@]} trecho(s) e seção(ões) de divergência, todos casados."
[[ "${#INTEIROS[@]}" -eq 0 ]] ||
  log "${#INTEIROS[@]} par(es) isento(s) por inteiro, declarado(s) por 'secao | ... | *': ${INTEIROS[*]}"
