#!/usr/bin/env bash
# weekly-achievement-log — instalador de la skill.
#
#   curl -fsSL https://raw.githubusercontent.com/propiter/weekly-achievement-log/main/install.sh | bash
#
# Deja la skill en todos los agentes que encuentre en la maquina (Hermes, Claude
# Code, Codex, OpenCode, Cursor). Es idempotente: correrlo de nuevo actualiza.
set -euo pipefail

REPO="${WAL_REPO:-propiter/weekly-achievement-log}"
BRANCH="${WAL_BRANCH:-main}"
TARBALL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
NOMBRE="weekly-achievement-log"

say() { printf '%s\n' "$*"; }
die() { printf '\nerror: %s\n' "$*" >&2; exit 1; }

say ""
say "  weekly-achievement-log — logros semanales con evidencia"
say "  ----------------------------------------------------"

# Origen: si corremos desde un checkout (hay skill/ al lado), usamos eso. Si no,
# bajamos el repo. Asi el mismo script sirve para probar y para instalar de verdad.
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$AQUI/skill/SKILL.md" ]; then
  ORIGEN="$AQUI/skill"
  say "  origen: checkout local"
else
  command -v curl >/dev/null 2>&1 || die "hace falta curl"
  command -v tar  >/dev/null 2>&1 || die "hace falta tar"
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  say "  bajando ${REPO}@${BRANCH} ..."
  curl -fsSL "$TARBALL" | tar -xz -C "$TMP" || die "no se pudo bajar el repo"
  ORIGEN="$(find "$TMP" -maxdepth 3 -type d -name skill | head -1)"
  [ -n "$ORIGEN" ] && [ -f "$ORIGEN/SKILL.md" ] || die "el paquete no trae skill/SKILL.md"
fi

if [ -n "${SKILL_DIRS:-}" ]; then
  IFS=':' read -r -a candidatos <<< "$SKILL_DIRS"
else
  candidatos=(
    "${HERMES_HOME:-$HOME/.hermes}/skills/productivity"
    "$HOME/.claude/skills"
    "${CODEX_HOME:-$HOME/.codex}/skills"
    "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"
    "$HOME/.cursor/skills"
  )
fi

n=0
for dir in "${candidatos[@]}"; do
  [ -n "$dir" ] || continue
  [ -d "$(dirname "$dir")" ] || continue          # solo si ese agente existe
  mkdir -p "$dir/$NOMBRE/references"
  cp -f "$ORIGEN/SKILL.md" "$dir/$NOMBRE/SKILL.md"
  cp -f "$ORIGEN"/references/*.md "$dir/$NOMBRE/references/" 2>/dev/null || true
  say "  instalada -> $dir/$NOMBRE"
  n=$((n+1))
done

[ "$n" -gt 0 ] || die "no encontre ningun agente. Pasa los directorios a mano:
  SKILL_DIRS=/ruta/a/skills:/otra/ruta ./install.sh"

say ""
say "  listo: instalada en $n agentes."
say "  Tu agente la carga solo cuando el tema aparece — no hay que invocarla."
