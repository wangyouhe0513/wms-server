#!/usr/bin/env python3
"""生成所有工人工资二维码 → static/worker_qrcodes.zip"""
import os, sys, urllib.parse, zipfile, traceback

os.chdir(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, '.')

from database import SessionLocal
from models import SalaryWorker

BASE = "http://47.96.91.217/api/salary/share"
TMP = "/tmp/qr_codes"
ZIP = "static/worker_qrcodes.zip"

os.makedirs(TMP, exist_ok=True)

print("🔗 连接数据库...")
try:
    db = SessionLocal()
    print("✅ 数据库已连接")
except Exception as e:
    print(f"❌ 数据库连接失败: {e}")
    sys.exit(1)

try:
    workers = db.query(SalaryWorker).filter(SalaryWorker.is_active == 1).all()
    print(f"📋 {len(workers)} 名工人")
except Exception as e:
    print(f"❌ 查询失败: {e}")
    db.close()
    sys.exit(1)
finally:
    db.close()

print("🔧 导入 qrcode...")
try:
    import qrcode
    print("✅ qrcode 已就绪")
except ImportError:
    print("❌ qrcode 未安装！执行: pip3 install qrcode Pillow")
    sys.exit(1)

ok = 0
for w in workers:
    try:
        url = f"{BASE}?worker={urllib.parse.quote(w.name)}"
        path = os.path.join(TMP, f"{w.name}.png")
        qrcode.make(url).save(path)
        ok += 1
        if ok % 10 == 0:
            print(f"  ... {ok}/{len(workers)}")
    except Exception as e:
        print(f"  ⚠️ {w.name} 失败: {e}")

print(f"✅ 生成 {ok}/{len(workers)} 个二维码")

if ok == 0:
    print("❌ 无文件生成")
    sys.exit(1)

print("📦 打包 ZIP...")
with zipfile.ZipFile(ZIP, 'w') as z:
    for f in sorted(os.listdir(TMP)):
        if f.endswith('.png'):
            z.write(os.path.join(TMP, f), f)
            os.remove(os.path.join(TMP, f))

os.rmdir(TMP)
size_kb = os.path.getsize(ZIP) / 1024
print(f"✅ 完成 → {ZIP} ({size_kb:.0f}KB)")
print(f"🔗 下载: {BASE.replace('/api/salary/share','')}/static/worker_qrcodes.zip")
