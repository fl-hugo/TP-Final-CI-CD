#!/bin/sh
set -eu

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <tag> [base_url]" >&2
  echo "Exemple: $0 v1.0.1" >&2
  exit 1
fi

TAG="$1"
BASE_URL="${2:-${BASE_URL:-http://localhost:8080}}"

ROOT_DIR="$(CDPATH= cd "$(dirname "$0")/.." && pwd)"
VERSIONS_FILE="${VERSIONS_FILE:-$ROOT_DIR/deploy/versions.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$ROOT_DIR/docker-compose.yml}"

if [ ! -f "$VERSIONS_FILE" ]; then
  echo "Fichier de versions introuvable: $VERSIONS_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$VERSIONS_FILE"

API_IMAGE="${API_IMAGE:-shoplite-api}"
FRONTEND_IMAGE="${FRONTEND_IMAGE:-shoplite-frontend}"

echo "Déploiement ShopLite tag=$TAG (STABLE inchangé — rollback possible)"

export API_IMAGE
export FRONTEND_IMAGE
export API_TAG="$TAG"
export FRONTEND_TAG="$TAG"
export APP_VERSION="$TAG"

cd "$ROOT_DIR"

docker compose -f "$COMPOSE_FILE" build api frontend
docker compose -f "$COMPOSE_FILE" up -d --no-deps api frontend proxy

echo "Vérification post-déploiement..."
sleep 2
BASE_URL="$BASE_URL" "$ROOT_DIR/scripts/smoke-test.sh"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT INT TERM

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    CURRENT_API_TAG=*) printf '%s\n' "CURRENT_API_TAG=$TAG" ;;
    CURRENT_FRONTEND_TAG=*) printf '%s\n' "CURRENT_FRONTEND_TAG=$TAG" ;;
    *) printf '%s\n' "$line" ;;
  esac
done < "$VERSIONS_FILE" > "$tmp_file"

mv "$tmp_file" "$VERSIONS_FILE"
trap - EXIT INT TERM

echo "Déploiement $TAG terminé. Validez puis lancez scripts/promote-stable.sh pour figer la version stable."
