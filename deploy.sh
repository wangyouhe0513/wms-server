#!/bin/bash
# ========================================
# 工厂进销存系统 — 阿里云一键部署脚本
# ========================================
set -e

echo "🚀 开始部署工厂进销存系统..."

# 1. 安装 Docker（如果没有）
if ! command -v docker &>/dev/null; then
    echo "📦 安装 Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# 2. 安装 Docker Compose
if ! command -v docker-compose &>/dev/null; then
    echo "📦 安装 docker-compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 3. 拉取代码（如果在服务器上直接部署）
# git clone ... 或者手动上传

# 4. 创建数据目录
mkdir -p data imports

# 5. 构建并启动
echo "🔧 构建 Docker 镜像..."
docker-compose build

echo "🏃 启动服务..."
docker-compose up -d

# 6. 配置防火墙
echo "🔒 开放 8000 端口..."
if command -v ufw &>/dev/null; then
    ufw allow 8000
fi

echo ""
echo "✅ 部署完成！"
echo "📱 访问地址: http://你的服务器IP:8000"
echo ""
echo "📊 查看日志: docker-compose logs -f"
echo "🛑 停止服务: docker-compose down"
echo "🔄 重启服务: docker-compose restart"
