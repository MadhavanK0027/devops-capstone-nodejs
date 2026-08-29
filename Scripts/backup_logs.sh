#!/bin/bash

BACKUP_DIR="/home/ubuntu/capstone-backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/app_logs_$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

docker logs devops-node-app > "/tmp/app_logs_$DATE.log" 2>&1

tar -czf "$BACKUP_FILE" "/tmp/app_logs_$DATE.log"

rm -f "/tmp/app_logs_$DATE.log"

echo "$(date): Backup created: $BACKUP_FILE"