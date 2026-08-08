#!/bin/bash
# ============================================
# 淼伊库服饰 — 工人工资二维码批量生成
# 服务器执行: bash gen_worker_qrcodes.sh
# 输出: worker_qrcodes.zip
# ============================================
set -e
cd "$(dirname "$0")"

TMPDIR="/tmp/qr_$$"
ZIP="worker_qrcodes.zip"
export TMPDIR
mkdir -p "$TMPDIR"

python3 << 'PYEOF'
import os, sys, urllib.parse
sys.path.insert(0, '.')
from database import SessionLocal
from models import SalaryWorker
import qrcode

BASE = "http://47.96.91.217/api/salary/share"
OUT = os.environ['TMPDIR']
db = SessionLocal()

try:
    workers = db.query(SalaryWorker).filter(SalaryWorker.is_active == 1).all()
    print(f"📋 {len(workers)} 名活跃工人")
    for w in workers:
        url = f"{BASE}?worker={urllib.parse.quote(w.name)}"
        qrcode.make(url).save(os.path.join(OUT, f"{w.name}.png"))
        print(f"  ✅ {w.name}")
    print(f"✅ 生成 {len(workers)} 个二维码")
finally:
    db.close()
PYEOF

COUNT=$(ls "$TMPDIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
if [ "$COUNT" -eq 0 ]; then
    echo "❌ 无文件生成"
    rm -rf "$TMPDIR"; exit 1
fi

rm -f "$ZIP"
cd "$TMPDIR"; zip -q "$OLDPWD/$ZIP" *.png; cd "$OLDPWD"
rm -rf "$TMPDIR"

echo "📦 ${ZIP} ($(ls -lh "$ZIP" | awk '{print $5}')) — ${COUNT} 个二维码"
echo "✅ 完成"
