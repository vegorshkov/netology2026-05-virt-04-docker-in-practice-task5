#!/bin/bash

LOG_FILE="/var/log/mysql-backup.log"
BACKUP_DIR="/opt/backup"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$TIMESTAMP] Starting MySQL backup" >> "$LOG_FILE"

# Создаём директорию если нет
mkdir -p "$BACKUP_DIR"

# Загружаем переменные из .env
if [ -f "/opt/app/.env" ]; then
    source /opt/app/.env
    echo "[$TIMESTAMP] Loaded .env file" >> "$LOG_FILE"
else
    echo "[$TIMESTAMP] ERROR: .env file not found at /opt/app/.env" >> "$LOG_FILE"
    exit 1
fi

# Проверяем запущен ли контейнер mysql
if docker ps --format '{{.Names}}' | grep -q "mysql"; then
    CONTAINER_NAME="mysql"
elif docker ps --format '{{.Names}}' | grep -q "mysql-db"; then
    CONTAINER_NAME="mysql-db"
elif docker ps --format '{{.Names}}' | grep -q "db"; then
    CONTAINER_NAME="db"
else
    echo "[$TIMESTAMP] ERROR: MySQL container not found" >> "$LOG_FILE"
    exit 1
fi

echo "[$TIMESTAMP] Found MySQL container: $CONTAINER_NAME" >> "$LOG_FILE"

# Создаём имя файла бэкапа
BACKUP_FILE="${BACKUP_DIR}/backup_$(date +%Y%m%d_%H%M%S).sql.gz"

# Выполняем бэкап
echo "[$TIMESTAMP] Creating backup: $BACKUP_FILE" >> "$LOG_FILE"

if docker exec "$CONTAINER_NAME" mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" --all-databases 2>/dev/null | gzip > "$BACKUP_FILE"; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "[$TIMESTAMP] ✓ Backup created: $BACKUP_FILE ($FILE_SIZE)" >> "$LOG_FILE"
    
    # Удаляем старые бэкапы (оставляем последние 10)
    cd "$BACKUP_DIR"
    BACKUP_COUNT=$(ls -1 backup_*.sql.gz 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 10 ]; then
        OLD_FILES=$((BACKUP_COUNT - 10))
        echo "[$TIMESTAMP] Removing $OLD_FILES old backup(s)" >> "$LOG_FILE"
        ls -1t backup_*.sql.gz | tail -n $OLD_FILES | xargs -r rm -f
    fi
else
    echo "[$TIMESTAMP] ✗ Backup failed" >> "$LOG_FILE"
    rm -f "$BACKUP_FILE"
fi

echo "[$TIMESTAMP] Backup process completed" >> "$LOG_FILE"
