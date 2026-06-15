#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd "$(dirname "$0")/.." && pwd)"
VERSIONS_FILE="${VERSIONS_FILE:-$ROOT_DIR/deploy/versions.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$ROOT_DIR/docker-compose.yml}"
BASE_URL="${BASE_URL:-http://localhost:8080}"

if [ ! -f "$VERSIONS_FILE" ]; then
  echo "Fichier de versions introuvable: $VERSIONS_FILE" >&2
  echo "Copiez deploy/versions.env.example vers deploy/versions.env" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$VERSIONS_FILE"

STABLE_API_TAG="${STABLE_API_TAG:-starter}"
STABLE_FRONTEND_TAG="${STABLE_FRONTEND_TAG:-starter}"
API_IMAGE="${API_IMAGE:-shoplite-api}"
FRONTEND_IMAGE="${FRONTEND_IMAGE:-shoplite-frontend}"

echo "Rollback ShopLite — restauration des images stables (base PostgreSQL inchangée)"
echo "  API:      ${API_IMAGE}:${STABLE_API_TAG}"
echo "  Frontend: ${FRONTEND_IMAGE}:${STABLE_FRONTEND_TAG}"

for image_ref in "${API_IMAGE}:${STABLE_API_TAG}" "${FRONTEND_IMAGE}:${STABLE_FRONTEND_TAG}"; do
  if ! docker image inspect "$image_ref" >/dev/null 2>&1; then
    echo "Image introuvable: $image_ref" >&2
    echo "Construisez-la avec: API_TAG=${STABLE_API_TAG} FRONTEND_TAG=${STABLE_FRONTEND_TAG} docker compose build api frontend" >&2
    exit 1
  fi
done

export API_IMAGE
export FRONTEND_IMAGE
export API_TAG="$STABLE_API_TAG"
export FRONTEND_TAG="$STABLE_FRONTEND_TAG"
export APP_VERSION="$STABLE_API_TAG"

cd "$ROOT_DIR"

# Redéploie uniquement les services applicatifs — le volume shoplite_pgdata n'est pas touché.
docker compose -f "$COMPOSE_FILE" up -d --no-deps --no-build api frontend proxy

echo "Vérification post-rollback..."
sleep 2
BASE_URL="$BASE_URL" "$ROOT_DIR/scripts/smoke-test.sh"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT INT TERM

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    CURRENT_API_TAG=*) printf '%s\n' "CURRENT_API_TAG=$STABLE_API_TAG" ;;
    CURRENT_FRONTEND_TAG=*) printf '%s\n' "CURRENT_FRONTEND_TAG=$STABLE_FRONTEND_TAG" ;;
    *) printf '%s\n' "$line" ;;
  esac
done < "$VERSIONS_FILE" > "$tmp_file"

mv "$tmp_file" "$VERSIONS_FILE"
trap - EXIT INT TERM

echo "Rollback terminé — données PostgreSQL préservées (volume shoplite_pgdata intact)."
