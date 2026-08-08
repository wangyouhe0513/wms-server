#!/usr/bin/env python3
"""生成所有工人工资二维码 → worker_qrcodes.zip"""
import os, sys, urllib.parse, zipfile

os.chdir(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, '.')

from database import SessionLocal
from models import SalaryWorker
import qrcode

BASE = "http://47.96.91.217/api/salary/share"
TMP = "/tmp/qr_codes"
ZIP = "worker_qrcodes.zip"

os.makedirs(TMP, exist_ok=True)

db = SessionLocal()
try:
    workers = db.query(SalaryWorker).filter(SalaryWorker.is_active == 1).all()
    print(f"📋 {len(workers)} 名工人")
    for w in workers:
        url = f"{BASE}?worker={urllib.parse.quote(w.name)}"
        path = os.path.join(TMP, f"{w.name}.png")
        qrcode.make(url).save(path)
        print(f"  ✅ {w.name} → {w.name}.png")
finally:
    db.close()

# 打包
with zipfile.ZipFile(ZIP, 'w') as z:
    for f in sorted(os.listdir(TMP)):
        if f.endswith('.png'):
            z.write(os.path.join(TMP, f), f)
            os.remove(os.path.join(TMP, f))

os.rmdir(TMP)
size_kb = os.path.getsize(ZIP) / 1024
print(f"\n✅ 完成 → {ZIP} ({size_kb:.0f}KB, {len(workers)} 个二维码)")
