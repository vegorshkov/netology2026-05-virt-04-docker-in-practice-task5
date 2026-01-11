#!/bin/bash

BACKUP_DIR="/opt/backup"
CONTAINER="mysql-db"
DB_NAME="virtd"
ENV_FILE="/opt/app/.env"

# читаем пароль
DB_PASS=$(grep MYSQL_PASSWORD "$ENV_FILE" | cut -d= -f2)

# имя файла
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"

# делаем бэкап
docker exec "$CONTAINER" mysqldump -u app -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"

# оставляем только последние 10 бэкапов
cd "$BACKUP_DIR"
ls -1t backup_*.sql 2>/dev/null | tail -n +11 | xargs -r rm -f

echo "Backup created: $BACKUP_FILE"

