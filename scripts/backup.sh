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
BACKUP_RETENTION_COUNT="${BACKUP_RETENTION_COUNT:-14}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

mkdir -p "$BACKUP_DIR"

if ! docker inspect --format '{{.State.Running}}' "$DB_CONTAINER" 2>/dev/null | grep -q true; then
  echo "Conteneur PostgreSQL introuvable ou arrêté: $DB_CONTAINER" >&2
  echo "Lancez la stack avec: docker compose up -d" >&2
  exit 1
fi

timestamp="$(date -u +%Y%m%d_%H%M%S)"
backup_file="$BACKUP_DIR/shoplite_${timestamp}.sql"

echo "Backup PostgreSQL — $POSTGRES_DB @ $DB_CONTAINER"
docker exec "$DB_CONTAINER" pg_dump \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  --no-owner \
  --no-acl \
  > "$backup_file"

if [ ! -s "$backup_file" ]; then
  echo "Échec du backup: fichier vide ($backup_file)" >&2
  rm -f "$backup_file"
  exit 1
fi

echo "Backup créé: $backup_file ($(wc -c < "$backup_file" | tr -d ' ') octets)"

if [ "$BACKUP_RETENTION_DAYS" -gt 0 ] 2>/dev/null; then
  find "$BACKUP_DIR" -maxdepth 1 -type f -name 'shoplite_*.sql' -mtime +"$BACKUP_RETENTION_DAYS" -delete 2>/dev/null || true
  echo "Rétention: fichiers > ${BACKUP_RETENTION_DAYS}j supprimés"
fi

if [ "$BACKUP_RETENTION_COUNT" -gt 0 ] 2>/dev/null; then
  kept=0
  for old_file in $(ls -1t "$BACKUP_DIR"/shoplite_*.sql 2>/dev/null); do
    kept=$((kept + 1))
    if [ "$kept" -gt "$BACKUP_RETENTION_COUNT" ]; then
      rm -f "$old_file"
      echo "Rétention: supprimé $old_file"
    fi
  done
  echo "Rétention: max ${BACKUP_RETENTION_COUNT} backups conservés"
fi

echo "Backup terminé."
