#!/bin/bash
# 工厂进销存系统 — MySQL 数据库自动备份脚本
# 用法: ./backup.sh 或通过 cron 定时执行

set -e

# 配置
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$PROJECT_DIR/backups"
KEEP_DAYS=30

# MySQL 连接信息（可通过环境变量覆盖）
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-}"
DB_NAME="${DB_NAME:-wms_finance}"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SQL_FILE="$BACKUP_DIR/wms_$TIMESTAMP.sql"

# mysqldump 导出
MYSQL_PWD="$DB_PASS" mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" \
    --single-transaction --routines --triggers \
    --default-character-set=utf8mb4 \
    "$DB_NAME" > "$SQL_FILE" 2>/dev/null

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份完成: $SQL_FILE ($(wc -c < "$SQL_FILE") bytes)"

# 清理旧备份
find "$BACKUP_DIR" -name "wms_*.sql" -mtime +$KEEP_DAYS -delete 2>/dev/null

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 清理完成，保留最近 ${KEEP_DAYS} 天"
