#!/bin/bash
# ============================================
# 淼伊库服饰 — 工人工资本二维码批量生成
# 用法: bash gen_worker_qrcodes.sh
# 输出: worker_qrcodes.zip
# ============================================
set -e

IP="${1:-47.96.91.217}"
BASE="http://${IP}"
ZIP="worker_qrcodes.zip"
TMPDIR="/tmp/qr_$$"
mkdir -p "$TMPDIR"

echo "🔐 登录 ${IP}..."

TOKEN=$(curl -sf -X POST "${BASE}/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

echo "📋 获取工人列表 & 生成二维码..."

python3 << PYEOF
import urllib.request, urllib.parse, json, qrcode, os, sys

# 获取活跃工人
req = urllib.request.Request(
    "${BASE}/api/salespersons",
    headers={"Authorization": "Bearer ${TOKEN}"}
)
workers = json.loads(urllib.request.urlopen(req).read())
active = [w['name'] for w in workers if w.get('is_active')]

outdir = "$TMPDIR"
print(f"找到 {len(active)} 名工人")

for name in active:
    url = f"${BASE}/api/salary/share?worker={urllib.parse.quote(name)}"
    img = qrcode.make(url)
    fname = os.path.join(outdir, f"{name}.png")
    img.save(fname)
    print(f"  ✅ {name}")

print(f"\n共生成 {len(active)} 个二维码")
PYEOF

COUNT=$(ls "$TMPDIR"/*.png 2>/dev/null | wc -l | tr -d ' ')

if [ "$COUNT" -eq 0 ]; then
  echo "❌ 没有生成任何文件"
  rm -rf "$TMPDIR"
  exit 1
fi

echo ""
echo "📦 打包 ${COUNT} 个文件 → ${ZIP} ..."
rm -f "$ZIP"
cd "$TMPDIR" && zip -q "$OLDPWD/$ZIP" *.png && cd "$OLDPWD"

SIZE=$(ls -lh "$ZIP" | awk '{print $5}')
echo ""
echo "========================================="
echo "  ✅ 完成！${COUNT} 个二维码 → ${ZIP} (${SIZE})"
echo "========================================="

rm -rf "$TMPDIR"
