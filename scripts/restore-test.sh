#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd "$(dirname "$0")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$ROOT_DIR/.env"
  set +a
fi

DB_CONTAINER="${POSTGRES_CONTAINER:-shoplite_db}"
POSTGRES_DB="${POSTGRES_DB:-shoplite}"
POSTGRES_USER="${POSTGRES_USER:-shoplite}"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups}"
TEST_DB="${RESTORE_TEST_DB:-shoplite_restore_test}"

if [ "$#" -ge 1 ]; then
  backup_file="$1"
else
  backup_file="$(ls -1t "$BACKUP_DIR"/shoplite_*.sql 2>/dev/null | head -1 || true)"
fi

if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
  echo "Aucun fichier de backup trouvé." >&2
  echo "Usage: $0 [chemin/vers/backup.sql]" >&2
  echo "Ou lancez d'abord: scripts/backup.sh" >&2
  exit 1
fi

if ! docker inspect --format '{{.State.Running}}' "$DB_CONTAINER" 2>/dev/null | grep -q true; then
  echo "Conteneur PostgreSQL introuvable ou arrêté: $DB_CONTAINER" >&2
  exit 1
fi

echo "Test de restauration — base temporaire $TEST_DB"
echo "  Source: $backup_file"
echo "  Production ($POSTGRES_DB) non modifiée"

docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -v ON_ERROR_STOP=1 -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$TEST_DB' AND pid <> pg_backend_pid();" \
  >/dev/null 2>&1 || true

docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -v ON_ERROR_STOP=1 -c \
  "DROP DATABASE IF EXISTS $TEST_DB;"

docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -v ON_ERROR_STOP=1 -c \
  "CREATE DATABASE $TEST_DB;"

container_backup="/tmp/shoplite_restore_test.sql"
docker cp "$backup_file" "$DB_CONTAINER:$container_backup"

docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d "$TEST_DB" -v ON_ERROR_STOP=1 -f "$container_backup"
docker exec "$DB_CONTAINER" rm -f "$container_backup"

product_count="$(docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d "$TEST_DB" -tAc \
  "SELECT COUNT(*) FROM products;")"

if [ -z "$product_count" ] || [ "$product_count" -lt 1 ]; then
  echo "Échec: la table products est vide après restauration." >&2
  docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -v ON_ERROR_STOP=1 -c \
    "DROP DATABASE IF EXISTS $TEST_DB;" || true
  exit 1
fi

echo "Vérification OK — $product_count produit(s) restauré(s) dans $TEST_DB"

docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -v ON_ERROR_STOP=1 -c \
  "DROP DATABASE $TEST_DB;"

echo "Test de restauration terminé — base temporaire supprimée."
