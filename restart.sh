#!/bin/bash
# 重启 WMS 服务
cd /home/admin/wms-server
git pull origin main
pkill -f "python.*main.py"
sleep 1
nohup python3 main.py > /tmp/wms-server.log 2>&1 &
sleep 2
echo "✅ 服务已重启"
curl -s http://localhost:8000/api/settings
