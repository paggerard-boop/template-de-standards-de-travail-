#!/usr/bin/env bash
# sync-claude-method.sh
# Synchronise ~/.claude/CLAUDE.md avec la dernière version du repo
# template-de-standards-de-travail- (méthode Paul).
#
# Usage :
#   ./scripts/sync-claude-method.sh [chemin-du-repo-template]
#
# Résolution du chemin du repo template (par ordre de priorité) :
#   1. argument $1
#   2. variable d'env $CLAUDE_TEMPLATE_REPO
#   3. repo git contenant ce script (git rev-parse)
#
# Effets :
#   - git pull --ff-only dans le repo template
#   - copie CLAUDE.md vers ~/.claude/CLAUDE.md
#   - backup horodaté de l'ancien fichier si différent
#
# NON modifié : ~/.claude/settings.json (le hook SessionStart). Pour mettre
# à jour le hook, l'éditer manuellement (rare, contenu ~stable).

set -euo pipefail

log()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
fail() { printf '[ERREUR] %s\n' "$*" >&2; exit 1; }

# --- 1. Localiser le repo template ---
if [[ $# -gt 0 ]]; then
  REPO="$1"
elif [[ -n "${CLAUDE_TEMPLATE_REPO:-}" ]]; then
  REPO="$CLAUDE_TEMPLATE_REPO"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  REPO="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
fi

[[ -n "${REPO:-}" && -d "$REPO/.git" ]] \
  || fail "Repo template introuvable. Fournir le chemin en argument ou via \$CLAUDE_TEMPLATE_REPO."

SRC="$REPO/CLAUDE.md"
[[ -f "$SRC" ]] || fail "CLAUDE.md absent du repo template ($SRC)."

# --- 2. Pull latest ---
log "Pull dans : $REPO"
git -C "$REPO" pull --ff-only

# --- 3. Préparer destination ---
DEST_DIR="$HOME/.claude"
DEST="$DEST_DIR/CLAUDE.md"
mkdir -p "$DEST_DIR"

# --- 4. Backup si fichier existe et diffère ---
if [[ -f "$DEST" ]]; then
  if cmp -s "$SRC" "$DEST"; then
    log "Déjà à jour : $DEST (aucune copie nécessaire)."
    exit 0
  fi
  BACKUP="$DEST.$(date +%Y%m%d-%H%M%S).bak"
  cp -p "$DEST" "$BACKUP"
  log "Backup : $BACKUP"
fi

# --- 5. Copie ---
cp "$SRC" "$DEST"
log "Copié : $SRC → $DEST"
log "OK. Effet immédiat à la prochaine session Claude Code."
