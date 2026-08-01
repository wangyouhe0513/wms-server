#!/bin/bash
# 工厂进销存系统 — 数据库自动备份脚本
# 用法: ./backup.sh 或通过 cron 定时执行

set -e

# 配置
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_FILE="$PROJECT_DIR/factory.db"
BACKUP_DIR="$PROJECT_DIR/backups"
KEEP_DAYS=30  # 保留最近30天的备份

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份文件名：factory_YYYYMMDD_HHMMSS.db
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/factory_$TIMESTAMP.db"
SQL_FILE="$BACKUP_DIR/factory_$TIMESTAMP.sql"

# SQLite .dump 导出（纯文本，兼容性好）
sqlite3 "$DB_FILE" ".dump" > "$SQL_FILE"

# 同时复制一份 .db 二进制文件
cp "$DB_FILE" "$BACKUP_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份完成: $SQL_FILE ($(wc -c < "$SQL_FILE") bytes)"

# 清理超过 KEEP_DAYS 天的旧备份
find "$BACKUP_DIR" -name "factory_*.db" -mtime +$KEEP_DAYS -delete 2>/dev/null
find "$BACKUP_DIR" -name "factory_*.sql" -mtime +$KEEP_DAYS -delete 2>/dev/null

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 清理完成，保留最近 ${KEEP_DAYS} 天"
