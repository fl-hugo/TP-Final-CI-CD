#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd "$(dirname "$0")/.." && pwd)"
VERSIONS_FILE="${VERSIONS_FILE:-$ROOT_DIR/deploy/versions.env}"

if [ ! -f "$VERSIONS_FILE" ]; then
  echo "Fichier de versions introuvable: $VERSIONS_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$VERSIONS_FILE"

CURRENT_API_TAG="${CURRENT_API_TAG:-starter}"
CURRENT_FRONTEND_TAG="${CURRENT_FRONTEND_TAG:-starter}"

echo "Promotion de la version courante vers stable:"
echo "  API:      $CURRENT_API_TAG"
echo "  Frontend: $CURRENT_FRONTEND_TAG"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT INT TERM

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    STABLE_API_TAG=*) printf '%s\n' "STABLE_API_TAG=$CURRENT_API_TAG" ;;
    STABLE_FRONTEND_TAG=*) printf '%s\n' "STABLE_FRONTEND_TAG=$CURRENT_FRONTEND_TAG" ;;
    *) printf '%s\n' "$line" ;;
  esac
done < "$VERSIONS_FILE" > "$tmp_file"

mv "$tmp_file" "$VERSIONS_FILE"
trap - EXIT INT TERM

echo "Version stable mise à jour — rollback.sh ciblera ces tags."
