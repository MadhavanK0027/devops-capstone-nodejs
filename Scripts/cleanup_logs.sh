#!/bin/bash

BACKUP_DIR="/home/ubuntu/capstone-backups"

find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -delete

echo "$(date): Old backups cleaned up successfully"