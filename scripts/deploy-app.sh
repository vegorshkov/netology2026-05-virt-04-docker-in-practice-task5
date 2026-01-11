#!/bin/bash
set -e

echo "---=== Deploy App ===---"
echo "Date: $(date)"

cd /opt/app

# Проверяем есть ли compose.yaml или docker-compose.yml
if [ -f "compose.yaml" ]; then
    echo "Found compose.yaml"
    docker compose up -d --build
elif [ -f "docker-compose.yml" ]; then
    echo "Found docker-compose.yml"
    docker-compose up -d --build
else
    echo "ERROR: No compose.yaml or docker-compose.yml found in /opt/app/"
    echo "Available files:"
    ls -la
    exit 1
fi

sleep 3

echo "---=== Service Status ===---"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "---=== Deployment completed ===---"
