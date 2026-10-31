#!/usr/bin/env bash
#
# check-pontos-de-entrada.sh
#
# Os dois pontos de entrada, .claude/CLAUDE.md e .agents/README.md, dizem a
# mesma coisa para harnesses diferentes. O gate de pareamento só olha skills/,
# então até 31/10/2026 só a disciplina os mantinha iguais (TECH-1311).
#
# Este gate tira de cada lado os literais que
# scripts/validate/pontos-de-entrada-excecoes.txt declara para aquele lado,
# descarta a linha que ficou vazia por causa da remoção e compara o resto
# linha a linha. Formato de cada linha do arquivo de exceções:
#
#   .claude | <literal>     sai de .claude/CLAUDE.md
#   .agents | <literal>     sai de .agents/README.md
#
# O literal vai cru depois do primeiro " | "; `#` no começo da linha é
# comentário. Literal que não casa no seu lado é exceção obsoleta e reprova.
#
# Exit: 0 iguais · 2 diferença fora do declarado ou exceção obsoleta ·
#       3 arquivo ausente ou exceção malformada · 5 sem python3
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
command -v python3 >/dev/null || { echo "[pontos-de-entrada] python3 ausente" >&2; exit 5; }
python3 - <<'PY'
import sys
A, B, X = ".claude/CLAUDE.md", ".agents/README.md", "scripts/validate/pontos-de-entrada-excecoes.txt"
try:
    side = {".claude": open(A, encoding="utf-8").read(), ".agents": open(B, encoding="utf-8").read()}
    linhas = open(X, encoding="utf-8").read().splitlines()
except OSError as e:
    print(f"[pontos-de-entrada] {e}", file=sys.stderr); sys.exit(3)
lit = {".claude": [], ".agents": []}
for n, l in enumerate(linhas, 1):
    if not l.strip() or l.lstrip().startswith("#"):
        continue
    if " | " not in l or l.split(" | ", 1)[0].strip() not in lit:
        print(f"[pontos-de-entrada] exceção malformada na linha {n}: {l}", file=sys.stderr); sys.exit(3)
    k, v = l.split(" | ", 1)
    lit[k.strip()].append(v.strip())
obsoletas, limpo = [], {}
for k, txt in side.items():
    out = []
    for linha in txt.splitlines():
        nova = linha
        for v in lit[k]:
            nova = nova.replace(v, "")
        if nova != linha and not nova.strip():
            continue
        out.append(nova)
    for v in lit[k]:
        if v not in txt:
            obsoletas.append(f"{k} | {v}")
    limpo[k] = out
rc = 0
for o in obsoletas:
    print(f"[pontos-de-entrada] EXCEÇÃO OBSOLETA  {o}"); rc = 2
if limpo[".claude"] != limpo[".agents"]:
    import difflib
    print("[pontos-de-entrada] DIFERENÇA FORA DO DECLARADO entre .claude/CLAUDE.md e .agents/README.md")
    for d in difflib.unified_diff(limpo[".claude"], limpo[".agents"], ".claude/CLAUDE.md", ".agents/README.md", lineterm="", n=0):
        print("   " + d)
    rc = 2
if rc == 0:
    print(f"[pontos-de-entrada] iguais fora do declarado — {sum(map(len, lit.values()))} literal(is) em uso")
sys.exit(rc)
PY
