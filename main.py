"""
工厂进销存管理系统 — API 后端
"""
import hashlib
import secrets
import io
from datetime import date, datetime, timedelta
from decimal import Decimal
from typing import List, Optional

import openpyxl
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form, Query, Header
from fastapi.responses import StreamingResponse, FileResponse, Response
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, extract

from database import init_db, get_db
from models import ProductSpec, Color, ProductSku, Salesperson, Transaction, InventoryLog, Admin, OperationLog, SystemConfig

app = FastAPI(title="工厂进销存管理系统")

# Session token store: {token: admin_id}
_active_tokens = {}


# ============================================================
# 工具函数
# ============================================================
def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


def generate_token() -> str:
    return secrets.token_hex(32)


def log_operation(db: Session, admin_id: int, admin_name: str, action: str, target: str, detail: str = "", ip: str = ""):
    log = OperationLog(
        admin_id=admin_id, admin_name=admin_name,
        action=action, target=target, detail=detail, ip_address=ip
    )
    db.add(log)


def get_config(db: Session, key: str, default: str = "") -> str:
    """读取系统配置值"""
    config = db.query(SystemConfig).filter(SystemConfig.key == key).first()
    return config.value if config else default


def set_config(db: Session, key: str, value: str):
    """写入系统配置值"""
    config = db.query(SystemConfig).filter(SystemConfig.key == key).first()
    if config:
        config.value = value
    else:
        config = SystemConfig(key=key, value=value)
        db.add(config)


def get_low_stock_threshold(db: Session) -> int:
    """获取全局默认低库存阈值"""
    val = get_config(db, "low_stock_threshold", "50")
    try:
        return int(val)
    except (ValueError, TypeError):
        return 50


def get_current_admin(authorization: str = Header(None), db: Session = Depends(get_db)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(401, "请先登录")
    token = authorization[7:]
    admin_id = _active_tokens.get(token)
    if not admin_id:
        raise HTTPException(401, "登录已过期，请重新登录")
    admin = db.query(Admin).filter(Admin.id == admin_id, Admin.is_active == 1).first()
    if not admin:
        raise HTTPException(401, "账户已被禁用")
    return admin


# ============================================================
# 启动时初始化数据库
# ============================================================
@app.on_event("startup")
def startup():
    init_db()
    db = next(get_db())
    try:
        # 创建默认管理员（首次启动）
        existing = db.query(Admin).filter(Admin.username == "admin").first()
        if not existing:
            admin = Admin(username="admin", password_hash=hash_password("admin123"), role="superadmin")
            db.add(admin)
            db.commit()
            print("✅ 默认管理员已创建: admin / admin123")
    finally:
        db.close()


# ============================================================
# 认证 API — 登录 / 登出
# ============================================================
from pydantic import BaseModel as PydanticBaseModel


class LoginRequest(PydanticBaseModel):
    username: str
    password: str


@app.post("/api/auth/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    admin = db.query(Admin).filter(Admin.username == req.username, Admin.is_active == 1).first()
    if not admin or admin.password_hash != hash_password(req.password):
        raise HTTPException(401, "用户名或密码错误")
    token = generate_token()
    _active_tokens[token] = admin.id
    admin.last_login = datetime.now()
    log_operation(db, admin.id, admin.username, "login", "auth", f"管理员登录")
    db.commit()
    return {
        "token": token,
        "username": admin.username,
        "role": admin.role,
    }


@app.post("/api/auth/logout")
def logout(admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    # Remove all tokens for this admin
    expired = [k for k, v in _active_tokens.items() if v == admin.id]
    for k in expired:
        del _active_tokens[k]
    log_operation(db, admin.id, admin.username, "logout", "auth", "管理员登出")
    db.commit()
    return {"ok": True}


@app.get("/api/auth/me")
def me(admin: Admin = Depends(get_current_admin)):
    return {"username": admin.username, "role": admin.role}


# ============================================================
# 管理员 CRUD API（仅 superadmin 可操作）
# ============================================================
@app.get("/api/admins")
def list_admins(admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    if admin.role != "superadmin":
        raise HTTPException(403, "仅超级管理员可操作")
    admins = db.query(Admin).filter(Admin.is_active == 1).all()
    return [{"id": a.id, "username": a.username, "role": a.role, "last_login": str(a.last_login) if a.last_login else None, "created_at": str(a.created_at)} for a in admins]


@app.post("/api/admins")
def create_admin(req: LoginRequest, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    if admin.role != "superadmin":
        raise HTTPException(403, "仅超级管理员可操作")
    existing = db.query(Admin).filter(Admin.username == req.username).first()
    if existing:
        if existing.is_active == 0:
            existing.is_active = 1
            existing.password_hash = hash_password(req.password)
            db.commit()
            log_operation(db, admin.id, admin.username, "create", "admin", f"重新激活管理员: {req.username}")
            return {"ok": True, "reactivated": True}
        raise HTTPException(400, "用户名已存在")
    new_admin = Admin(username=req.username, password_hash=hash_password(req.password), role="admin")
    db.add(new_admin)
    db.commit()
    log_operation(db, admin.id, admin.username, "create", "admin", f"创建管理员: {req.username}")
    return {"ok": True, "id": new_admin.id}


class ResetPasswordRequest(PydanticBaseModel):
    password: str


@app.put("/api/admins/{admin_id}/password")
def reset_password(admin_id: int, req: ResetPasswordRequest, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    if admin.role != "superadmin":
        raise HTTPException(403, "仅超级管理员可操作")
    target = db.query(Admin).filter(Admin.id == admin_id).first()
    if not target:
        raise HTTPException(404, "管理员不存在")
    target.password_hash = hash_password(req.password)
    db.commit()
    log_operation(db, admin.id, admin.username, "update", "admin", f"重置密码: {target.username}")
    return {"ok": True}


@app.delete("/api/admins/{admin_id}")
def delete_admin(admin_id: int, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    if admin.role != "superadmin":
        raise HTTPException(403, "仅超级管理员可操作")
    if admin_id == admin.id:
        raise HTTPException(400, "不能删除自己")
    target = db.query(Admin).filter(Admin.id == admin_id).first()
    if not target:
        raise HTTPException(404, "管理员不存在")
    target.is_active = 0
    db.commit()
    # Remove their tokens
    expired = [k for k, v in _active_tokens.items() if v == admin_id]
    for k in expired:
        del _active_tokens[k]
    log_operation(db, admin.id, admin.username, "delete", "admin", f"删除管理员: {target.username}")
    return {"ok": True}


@app.put("/api/auth/change-password")
def change_password(old_password: str, new_password: str, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    if admin.password_hash != hash_password(old_password):
        raise HTTPException(400, "原密码错误")
    admin.password_hash = hash_password(new_password)
    db.commit()
    log_operation(db, admin.id, admin.username, "update", "auth", "修改密码")
    return {"ok": True}


# ============================================================
# 操作日志 API
# ============================================================
@app.get("/api/logs")
def get_logs(limit: int = 100, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    logs = db.query(OperationLog).order_by(OperationLog.created_at.desc()).limit(limit).all()
    return [{
        "id": l.id,
        "admin_name": l.admin_name,
        "action": l.action,
        "target": l.target,
        "detail": l.detail,
        "ip_address": l.ip_address,
        "created_at": str(l.created_at),
    } for l in logs]
@app.get("/api/specs")
def list_specs(db: Session = Depends(get_db)):
    specs = db.query(ProductSpec).filter(ProductSpec.is_active == 1).order_by(ProductSpec.sort_order, ProductSpec.id).all()
    return [{"id": s.id, "name": s.name, "sort_order": s.sort_order} for s in specs]


@app.post("/api/specs")
def create_spec(name: str, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    existing = db.query(ProductSpec).filter(ProductSpec.name == name).first()
    if existing:
        if existing.is_active == 0:
            existing.is_active = 1
            log_operation(db, admin.id, admin.username, "create", "spec", f"重新激活规格: {name}")
            db.commit()
            return {"id": existing.id, "name": existing.name, "reactivated": True}
        raise HTTPException(400, "规格已存在")
    spec = ProductSpec(name=name)
    db.add(spec)
    log_operation(db, admin.id, admin.username, "create", "spec", f"创建规格: {name}")
    db.commit()
    db.refresh(spec)
    return {"id": spec.id, "name": spec.name}


@app.put("/api/specs/{spec_id}")
def update_spec(spec_id: int, name: str, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    spec = db.query(ProductSpec).filter(ProductSpec.id == spec_id).first()
    if not spec:
        raise HTTPException(404, "规格不存在")
    old = spec.name
    spec.name = name
    log_operation(db, admin.id, admin.username, "update", "spec", f"修改规格: {old} -> {name}")
    db.commit()
    return {"ok": True}


@app.delete("/api/specs/{spec_id}")
def delete_spec(spec_id: int, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    spec = db.query(ProductSpec).filter(ProductSpec.id == spec_id).first()
    if not spec:
        raise HTTPException(404, "规格不存在")

    # 检查是否有库存或交易记录的 SKU
    has_stock = db.query(ProductSku).filter(
        ProductSku.spec_id == spec_id,
        ProductSku.current_stock > 0
    ).first()
    if has_stock:
        raise HTTPException(400, f"规格「{spec.name}」下还有库存，不能删除")

    has_txn = db.query(Transaction).join(ProductSku).filter(
        ProductSku.spec_id == spec_id
    ).first()
    if has_txn:
        raise HTTPException(400, f"规格「{spec.name}」下有交易记录，不能删除")

    spec.is_active = 0
    log_operation(db, admin.id, admin.username, "delete", "spec", f"删除规格: {spec.name}")
    db.commit()
    return {"ok": True}


# ============================================================
# 基础数据管理 — 颜色
# ============================================================
@app.get("/api/colors")
def list_colors(db: Session = Depends(get_db)):
    colors = db.query(Color).filter(Color.is_active == 1).order_by(Color.sort_order, Color.id).all()
    return [{"id": c.id, "name": c.name, "code": c.code} for c in colors]


@app.post("/api/colors")
def create_color(name: str, code: str = "", admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    existing = db.query(Color).filter(Color.name == name).first()
    if existing:
        if existing.is_active == 0:
            existing.is_active = 1
            log_operation(db, admin.id, admin.username, "create", "color", f"重新激活颜色: {name}")
            db.commit()
            return {"id": existing.id, "name": existing.name, "reactivated": True}
        raise HTTPException(400, "颜色已存在")
    color = Color(name=name, code=code)
    db.add(color)
    log_operation(db, admin.id, admin.username, "create", "color", f"创建颜色: {name}")
    db.commit()
    db.refresh(color)
    return {"id": color.id, "name": color.name}


@app.put("/api/colors/{color_id}")
def update_color(color_id: int, name: str, code: str = "", admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    color = db.query(Color).filter(Color.id == color_id).first()
    if not color:
        raise HTTPException(404, "颜色不存在")
    old = color.name
    color.name = name
    color.code = code
    log_operation(db, admin.id, admin.username, "update", "color", f"修改颜色: {old} -> {name}")
    db.commit()
    return {"ok": True}


@app.delete("/api/colors/{color_id}")
def delete_color(color_id: int, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    color = db.query(Color).filter(Color.id == color_id).first()
    if not color:
        raise HTTPException(404, "颜色不存在")

    # 检查是否有库存或交易记录的 SKU
    has_stock = db.query(ProductSku).filter(
        ProductSku.color_id == color_id,
        ProductSku.current_stock > 0
    ).first()
    if has_stock:
        raise HTTPException(400, f"颜色「{color.name}」下还有库存，不能删除")

    has_txn = db.query(Transaction).join(ProductSku).filter(
        ProductSku.color_id == color_id
    ).first()
    if has_txn:
        raise HTTPException(400, f"颜色「{color.name}」下有交易记录，不能删除")

    color.is_active = 0
    log_operation(db, admin.id, admin.username, "delete", "color", f"删除颜色: {color.name}")
    db.commit()
    return {"ok": True}


# ============================================================
# 基础数据管理 — 销售人员
# ============================================================
@app.get("/api/salespersons")
def list_salespersons(db: Session = Depends(get_db)):
    sps = db.query(Salesperson).filter(Salesperson.is_active == 1).order_by(Salesperson.id).all()
    return [{"id": s.id, "name": s.name, "type": s.type} for s in sps]


@app.post("/api/salespersons")
def create_salesperson(name: str, sp_type: str = "员工", admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    existing = db.query(Salesperson).filter(Salesperson.name == name).first()
    if existing:
        if existing.is_active == 0:
            existing.is_active = 1
            log_operation(db, admin.id, admin.username, "create", "salesperson", f"重新激活人员: {name}")
            db.commit()
            return {"id": existing.id, "name": existing.name, "reactivated": True}
        raise HTTPException(400, "销售人员已存在")
    sp = Salesperson(name=name, type=sp_type)
    db.add(sp)
    log_operation(db, admin.id, admin.username, "create", "salesperson", f"创建人员: {name}")
    db.commit()
    db.refresh(sp)
    return {"id": sp.id, "name": sp.name, "type": sp.type}


@app.put("/api/salespersons/{sp_id}")
def update_salesperson(sp_id: int, name: str, sp_type: str = "员工", admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    sp = db.query(Salesperson).filter(Salesperson.id == sp_id).first()
    if not sp:
        raise HTTPException(404, "销售人员不存在")
    sp.name = name
    sp.type = sp_type
    log_operation(db, admin.id, admin.username, "update", "salesperson", f"修改人员: {name}")
    db.commit()
    return {"ok": True}


@app.delete("/api/salespersons/{sp_id}")
def delete_salesperson(sp_id: int, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    sp = db.query(Salesperson).filter(Salesperson.id == sp_id).first()
    if not sp:
        raise HTTPException(404, "销售人员不存在")
    sp.is_active = 0
    log_operation(db, admin.id, admin.username, "delete", "salesperson", f"删除人员: {sp.name}")
    db.commit()
    return {"ok": True}


# ============================================================
# 核心：获取或创建 SKU
# ============================================================
def get_or_create_sku(db: Session, spec_name: str, color_name: str) -> ProductSku:
    # 找或建规格
    spec = db.query(ProductSpec).filter(ProductSpec.name == spec_name, ProductSpec.is_active == 1).first()
    if not spec:
        spec = ProductSpec(name=spec_name)
        db.add(spec)
        db.flush()

    # 找或建颜色
    color = db.query(Color).filter(Color.name == color_name, Color.is_active == 1).first()
    if not color:
        color = Color(name=color_name)
        db.add(color)
        db.flush()

    # 找或建 SKU
    sku = db.query(ProductSku).filter(
        ProductSku.spec_id == spec.id,
        ProductSku.color_id == color.id,
    ).first()
    if not sku:
        sku = ProductSku(spec_id=spec.id, color_id=color.id, current_stock=0)
        db.add(sku)
        db.flush()

    return sku


# ============================================================
# 每日录入 — 批量提交出入库记录
# ============================================================
from pydantic import BaseModel


class TransactionItem(BaseModel):
    trans_date: str  # "2026-08-01"
    trans_type: str  # "出库" / "入库"
    spec_name: str
    color_name: str
    quantity: int
    unit_price: float = 0
    amount: float = 0
    salesperson_name: Optional[str] = ""
    remark: Optional[str] = ""


class TransactionBatch(BaseModel):
    items: List[TransactionItem]


@app.post("/api/transactions/batch")
def create_transactions(batch: TransactionBatch, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    results = []
    try:
        for item in batch.items:
            trans_date = datetime.strptime(item.trans_date, "%Y-%m-%d").date()

            # 获取或创建 SKU
            sku = get_or_create_sku(db, item.spec_name, item.color_name)

            # 获取销售人员
            sp_name = item.salesperson_name.strip() if item.salesperson_name else ""
            sp_id = None
            if not sp_name:
                sp_name = admin.username  # 没填则默认当前用户
            if sp_name:
                sp = db.query(Salesperson).filter(
                    Salesperson.name == sp_name,
                    Salesperson.is_active == 1
                ).first()
                if not sp:
                    sp = Salesperson(name=sp_name)
                    db.add(sp)
                    db.flush()
                sp_id = sp.id

            # 计算金额
            amount = Decimal(str(item.quantity)) * Decimal(str(item.unit_price))

            # 插入记录
            t = Transaction(
                trans_date=trans_date,
                trans_type=item.trans_type,
                entry_person=admin.username,
                sku_id=sku.id,
                quantity=item.quantity,
                unit_price=item.unit_price,
                amount=amount,
                salesperson_id=sp_id,
                remark=item.remark or "",
            )
            db.add(t)
            db.flush()

            # 更新库存
            old_stock = sku.current_stock
            if item.trans_type == "出库":
                new_stock = old_stock - item.quantity
                change = -item.quantity
            else:
                new_stock = old_stock + item.quantity
                change = item.quantity
            sku.current_stock = new_stock

            # 写日志
            log = InventoryLog(
                sku_id=sku.id,
                transaction_id=t.id,
                change_qty=change,
                before_stock=old_stock,
                after_stock=new_stock,
            )
            db.add(log)

            results.append({
                "id": t.id,
                "sku": f"{item.spec_name}-{item.color_name}",
                "stock_after": new_stock,
            })

        log_operation(db, admin.id, admin.username, "create", "transaction", f"批量录入 {len(results)} 条出入库记录")
        db.commit()
        return {"ok": True, "count": len(results), "results": results}

    except Exception as e:
        db.rollback()
        raise HTTPException(500, f"录入失败: {str(e)}")


# ============================================================
# 每日进出报表
# ============================================================
@app.get("/api/reports/daily")
def daily_report(
    trans_date: str = Query(..., description="日期 YYYY-MM-DD"),
    db: Session = Depends(get_db),
):
    d = datetime.strptime(trans_date, "%Y-%m-%d").date()
    rows = (
        db.query(Transaction)
        .filter(Transaction.trans_date == d)
        .order_by(Transaction.trans_type, Transaction.id)
        .all()
    )

    out_list = []
    in_list = []
    out_total = Decimal("0")
    in_total_qty = 0

    for t in rows:
        sku = db.query(ProductSku).filter(ProductSku.id == t.sku_id).first()
        spec = db.query(ProductSpec).filter(ProductSpec.id == sku.spec_id).first()
        color = db.query(Color).filter(Color.id == sku.color_id).first()
        sp = db.query(Salesperson).filter(Salesperson.id == t.salesperson_id).first() if t.salesperson_id else None

        item = {
            "id": t.id,
            "spec": spec.name if spec else "",
            "color": color.name if color else "",
            "quantity": t.quantity,
            "unit_price": float(t.unit_price),
            "amount": float(t.amount),
            "salesperson": sp.name if sp else "",
            "entry_person": t.entry_person or "",
            "remark": t.remark or "",
        }
        if t.trans_type == "出库":
            out_list.append(item)
            out_total += t.amount
        else:
            in_list.append(item)
            in_total_qty += t.quantity

    return {
        "date": trans_date,
        "outbound": out_list,
        "outbound_total": float(out_total),
        "outbound_count": len(out_list),
        "inbound": in_list,
        "inbound_total_qty": in_total_qty,
        "inbound_count": len(in_list),
    }


@app.delete("/api/transactions/{txn_id}")
def delete_transaction(txn_id: int, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    """撤销一笔出入库记录，恢复库存"""
    txn = db.query(Transaction).filter(Transaction.id == txn_id).first()
    if not txn:
        raise HTTPException(404, "记录不存在")

    sku = db.query(ProductSku).filter(ProductSku.id == txn.sku_id).first()
    spec = db.query(ProductSpec).filter(ProductSpec.id == sku.spec_id).first()
    color = db.query(Color).filter(Color.id == sku.color_id).first()
    label = f"{spec.name}-{color.name}" if spec and color else "未知"

    # 1. 撤销库存变动
    if txn.trans_type == "出库":
        sku.current_stock += txn.quantity
    else:
        sku.current_stock -= txn.quantity

    # 2. 删除关联的库存流水
    db.query(InventoryLog).filter(InventoryLog.transaction_id == txn_id).delete()

    # 3. 删除交易记录
    db.delete(txn)

    # 4. 记录操作日志
    log_operation(db, admin.id, admin.username, "delete", "transaction",
                  f"撤销 {txn.trans_type} 记录: {label} x{txn.quantity}")

    db.commit()
    return {"ok": True, "deleted_id": txn_id}


# ============================================================
# 实时库存
# ============================================================
@app.get("/api/inventory")
def inventory_list(spec_name: str = "", db: Session = Depends(get_db)):
    default_threshold = get_low_stock_threshold(db)

    query = (
        db.query(ProductSku)
        .options(joinedload(ProductSku.spec), joinedload(ProductSku.color))
        .join(ProductSpec)
        .join(Color)
        .filter(ProductSpec.is_active == 1, Color.is_active == 1)
    )
    if spec_name:
        query = query.filter(ProductSpec.name == spec_name)

    skus = query.order_by(ProductSpec.sort_order, ProductSpec.id, Color.sort_order, Color.id).all()

    # 按规格分组
    groups = {}
    for sku in skus:
        spec = sku.spec.name
        color = sku.color.name
        if spec not in groups:
            groups[spec] = []
        groups[spec].append({
            "sku_id": sku.id,
            "color": color,
            "stock": sku.current_stock,
            "threshold": sku.low_stock_threshold or default_threshold,
        })

    low_stock = []
    for sku in skus:
        threshold = sku.low_stock_threshold or default_threshold
        if sku.current_stock < threshold:
            low_stock.append(f"{sku.spec.name}-{sku.color.name}: {sku.current_stock}（阈值{threshold}）")

    return {
        "inventory": groups,
        "low_stock": low_stock,
        "total_specs": len(groups),
        "total_skus": len(skus),
    }


@app.get("/api/skus")
def list_skus(db: Session = Depends(get_db)):
    """返回所有 SKU 平铺列表（含规格、颜色、库存、阈值）"""
    default_threshold = get_low_stock_threshold(db)
    skus = (
        db.query(ProductSku)
        .options(joinedload(ProductSku.spec), joinedload(ProductSku.color))
        .join(ProductSpec).join(Color)
        .filter(ProductSpec.is_active == 1, Color.is_active == 1)
        .order_by(ProductSpec.sort_order, ProductSpec.id, Color.sort_order, Color.id)
        .all()
    )
    return [{
        "sku_id": sku.id,
        "spec_id": sku.spec_id,
        "spec_name": sku.spec.name,
        "color_id": sku.color_id,
        "color_name": sku.color.name,
        "current_stock": sku.current_stock,
        "threshold": sku.low_stock_threshold or default_threshold,
        "is_custom": sku.low_stock_threshold is not None and sku.low_stock_threshold > 0,
    } for sku in skus]


@app.put("/api/skus/{sku_id}/threshold")
def set_threshold(sku_id: int, threshold: int, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    sku = db.query(ProductSku).filter(ProductSku.id == sku_id).first()
    if not sku:
        raise HTTPException(404, "SKU 不存在")
    sku.low_stock_threshold = threshold
    log_operation(db, admin.id, admin.username, "update", "threshold", f"SKU {sku.spec.name}-{sku.color.name} 阈值设为 {threshold}")
    db.commit()
    return {"ok": True, "sku_id": sku_id, "threshold": threshold}


@app.get("/api/inventory/snapshot")
def inventory_snapshot_download(admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    """生成带水印的库存快照 HTML，浏览器可直接打印为 PDF"""
    from datetime import date as dt_date
    today_str = dt_date.today().strftime("%Y-%m-%d")
    default_threshold = get_low_stock_threshold(db)

    skus = (
        db.query(ProductSku)
        .options(joinedload(ProductSku.spec), joinedload(ProductSku.color))
        .join(ProductSpec).join(Color)
        .filter(ProductSpec.is_active == 1, Color.is_active == 1)
        .order_by(ProductSpec.id, Color.id)
        .all()
    )

    # 按规格分组
    groups = {}
    for sku in skus:
        spec = sku.spec.name
        if spec not in groups:
            groups[spec] = []
        groups[spec].append({
            "color": sku.color.name,
            "stock": sku.current_stock,
            "threshold": sku.low_stock_threshold or default_threshold,
        })

    # 构建表格行
    rows_html = ""
    for spec, items in groups.items():
        items_html = ""
        for item in items:
            low = item["stock"] < item["threshold"]
            items_html += (
                f'<td style="padding:6px 10px;text-align:center;'
                f'{"color:red;font-weight:bold" if low else ""}'
                f'">{item["color"]}<br>{item["stock"]}</td>'
            )
        rows_html += f'<tr><td style="padding:6px 10px;font-weight:600;white-space:nowrap">{spec}</td>{items_html}</tr>'

    # 生成铺满的水印网格
    watermark_text = f"{admin.username} ｜ {today_str}"
    cells = ""
    for r in range(12):
        for c in range(8):
            cells += f'<span style="font-size:24px;color:#000;transform:rotate(-25deg);white-space:nowrap;padding:30px 20px;">{watermark_text}</span>'

    html = f"""<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="UTF-8">
<title>库存快照 {today_str}</title>
<style>
@page {{ margin: 15mm; }}
body {{ font-family: 'PingFang SC','Microsoft YaHei',sans-serif; margin:0; padding:20px; }}
h1 {{ text-align:center; color:#333; margin-bottom:5px; }}
.date {{ text-align:center; color:#999; font-size:13px; margin-bottom:20px; }}
table {{ width:100%; border-collapse:collapse; font-size:12px; position:relative; z-index:1; background:rgba(255,255,255,0.85); }}
th {{ background:#f5f5f5; padding:8px 10px; border:1px solid #ddd; }}
td {{ border:1px solid #ddd; }}
.watermark {{ position:fixed; top:-20px; left:-20px; width:calc(100% + 40px); height:calc(100% + 40px); pointer-events:none; z-index:0;
  display:flex; flex-wrap:wrap; align-items:center; justify-content:center; align-content:center; opacity:0.06; }}
@media print {{ .watermark {{ display:flex; }} }}
</style></head>
<body>
<div class="watermark">{cells}</div>
<h1>📦 库存快照</h1>
<div class="date">下载人：{admin.username} ｜ 日期：{today_str}</div>
<table><thead><tr><th>规格</th>"""
    # 表头：取最大颜色数列
    max_colors = max(len(items) for items in groups.values()) if groups else 1
    for i in range(max_colors):
        html += f'<th>颜色/库存</th>'
    html += '</tr></thead><tbody>' + rows_html + '</tbody></table>'
    html += '</body></html>'

    filename = f'inventory_snapshot_{today_str}.html'
    return Response(
        content=html.encode('utf-8'),
        media_type="text/html; charset=utf-8",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'}
    )


@app.get("/api/inventory/{sku_id}/history")
def inventory_history(sku_id: int, limit: int = 50, db: Session = Depends(get_db)):
    logs = (
        db.query(InventoryLog)
        .filter(InventoryLog.sku_id == sku_id)
        .order_by(InventoryLog.created_at.desc())
        .limit(limit)
        .all()
    )
    return [{
        "change_qty": l.change_qty,
        "before_stock": l.before_stock,
        "after_stock": l.after_stock,
        "time": l.created_at.strftime("%Y-%m-%d %H:%M"),
    } for l in logs]


# ============================================================
# 个人出库账单
# ============================================================
@app.get("/api/bills/personal")
def personal_bill(
    salesperson: str,
    year: int,
    month: int,
    db: Session = Depends(get_db),
):
    sp = db.query(Salesperson).filter(Salesperson.name == salesperson).first()
    if not sp:
        raise HTTPException(404, "销售人员不存在")

    rows = (
        db.query(Transaction)
        .filter(
            Transaction.salesperson_id == sp.id,
            Transaction.trans_type == "出库",
            extract("year", Transaction.trans_date) == year,
            extract("month", Transaction.trans_date) == month,
        )
        .order_by(Transaction.trans_date, Transaction.id)
        .all()
    )

    items = []
    total_amount = Decimal("0")
    total_qty = 0
    for t in rows:
        sku = db.query(ProductSku).filter(ProductSku.id == t.sku_id).first()
        spec = db.query(ProductSpec).filter(ProductSpec.id == sku.spec_id).first()
        color = db.query(Color).filter(Color.id == sku.color_id).first()
        items.append({
            "date": t.trans_date.strftime("%Y-%m-%d"),
            "spec": spec.name if spec else "",
            "color": color.name if color else "",
            "quantity": t.quantity,
            "unit_price": float(t.unit_price),
            "amount": float(t.amount),
        })
        total_amount += t.amount
        total_qty += t.quantity

    return {
        "salesperson": salesperson,
        "year": year,
        "month": month,
        "items": items,
        "total_qty": total_qty,
        "total_amount": float(total_amount),
    }


@app.get("/api/bills/inbound")
def inbound_records(
    year: int,
    month: int,
    db: Session = Depends(get_db),
):
    """入库记录列表，可按年月筛选"""
    rows = (
        db.query(Transaction)
        .filter(
            Transaction.trans_type == "入库",
            extract("year", Transaction.trans_date) == year,
            extract("month", Transaction.trans_date) == month,
        )
        .order_by(Transaction.trans_date, Transaction.id)
        .all()
    )

    items = []
    total_qty = 0
    for t in rows:
        sku = db.query(ProductSku).filter(ProductSku.id == t.sku_id).first()
        spec = db.query(ProductSpec).filter(ProductSpec.id == sku.spec_id).first()
        color = db.query(Color).filter(Color.id == sku.color_id).first()
        sp = db.query(Salesperson).filter(Salesperson.id == t.salesperson_id).first() if t.salesperson_id else None
        items.append({
            "date": t.trans_date.strftime("%Y-%m-%d"),
            "spec": spec.name if spec else "",
            "color": color.name if color else "",
            "quantity": t.quantity,
            "salesperson": sp.name if sp else "",
            "remark": t.remark,
        })
        total_qty += t.quantity

    return {
        "year": year,
        "month": month,
        "items": items,
        "total_qty": total_qty,
    }


# ============================================================
# 销售额汇总
# ============================================================
@app.get("/api/reports/sales-summary")
def sales_summary(year: int, month: int = 0, db: Session = Depends(get_db)):
    q = db.query(Transaction).filter(
        Transaction.trans_type == "出库",
        extract("year", Transaction.trans_date) == year,
    )
    if month > 0:
        q = q.filter(extract("month", Transaction.trans_date) == month)

    rows = q.all()

    by_sp = {}
    by_spec = {}
    by_month = {}
    by_day = {}
    total = Decimal("0")

    for t in rows:
        # 金额
        amt = t.amount
        total += amt

        # 按人员
        sp = db.query(Salesperson).filter(Salesperson.id == t.salesperson_id).first()
        sp_name = sp.name if sp else "未知"
        by_sp[sp_name] = by_sp.get(sp_name, 0) + float(amt)

        # 按规格
        sku = db.query(ProductSku).filter(ProductSku.id == t.sku_id).first()
        if sku:
            spec = db.query(ProductSpec).filter(ProductSpec.id == sku.spec_id).first()
            spec_name = spec.name if spec else "未知"
            by_spec[spec_name] = by_spec.get(spec_name, 0) + float(amt)

        # 按月/按日
        m_key = t.trans_date.strftime("%Y-%m")
        by_month[m_key] = by_month.get(m_key, 0) + float(amt)
        d_key = t.trans_date.strftime("%m-%d")
        by_day[d_key] = by_day.get(d_key, 0) + float(amt)

    return {
        "year": year,
        "month": month or "全部",
        "total": float(total),
        "by_salesperson": dict(sorted(by_sp.items(), key=lambda x: x[1], reverse=True)),
        "by_spec": dict(sorted(by_spec.items(), key=lambda x: x[1], reverse=True)),
        "by_month": dict(sorted(by_month.items())),
        "by_day": dict(sorted(by_day.items())),
    }


# ============================================================
# 🔥 一次性库存导入接口（读取 Excel）
# ============================================================
@app.post("/api/import/stock")
def import_stock(file: UploadFile = File(...), admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    """
    导入库存 Excel，格式：
    - 每个产品品类一个区块
    - R1: 品类名（如"网背心"、"6094"等）
    - R2: 列头（日期 | 颜色1 | 颜色2 | ... | 入 | 出）
    - R3+: 每日变动数据（正数=入库，负数=出库）
    - 最后一个非"合计"行 = 当前库存状态

    系统遍历每个品类区块的所有行，累加变化量，得出最终库存。
    """
    if not file.filename.endswith(".xlsx"):
        raise HTTPException(400, "只支持 .xlsx 文件")

    content = file.file.read()
    wb = openpyxl.load_workbook(io.BytesIO(content), data_only=True)

    imported = 0
    errors = []
    skipped_specs = 0

    last_sheet_name = wb.sheetnames[-1]
    ws = wb[last_sheet_name]

    print(f"\n=== 导入库存: {file.filename} → Sheet: {last_sheet_name} ===")

    # Step 1: 扫描 R1 行，找出所有品类的起始列位置
    spec_positions = []  # [(列索引, 品类名)]
    prev_spec = None
    for col_idx in range(1, ws.max_column + 1):
        val = ws.cell(row=1, column=col_idx).value
        if val and str(val).strip():
            name = str(val).strip()
            if name != prev_spec:  # 去重（合并单元格可能重复）
                spec_positions.append((col_idx, name))
                prev_spec = name
        else:
            prev_spec = None

    print(f"  发现 {len(spec_positions)} 个品类: {[s[1] for s in spec_positions]}")

    # Step 2: 对每个品类，找出对应的颜色列，解析库存
    for idx, (spec_col, spec_name) in enumerate(spec_positions):
        if idx + 1 < len(spec_positions):
            next_col = spec_positions[idx + 1][0]
        else:
            next_col = ws.max_column + 1

        # 解析 R2 列头：扫描 spec_col 到 next_col-1 之间，找颜色列名
        color_cols = []  # [(列索引, 颜色名)]
        for c in range(spec_col, next_col):
            h = ws.cell(row=2, column=c).value
            if h is None:
                continue
            h_str = str(h).strip()
            if h_str in ("入", "出", "日期", ""):
                continue
            color_cols.append((c, h_str))

        if not color_cols:
            skipped_specs += 1
            continue

        # 策略：读取 R3 "合计"行 获取当前库存快照
        final_stock = {}
        r3_has_data = False
        for (cc, color_name) in color_cols:
            val = ws.cell(row=3, column=cc).value
            if val is not None:
                try:
                    qty = int(val)
                    if qty != 0:
                        final_stock[color_name] = qty
                        r3_has_data = True
                except (ValueError, TypeError):
                    pass

        # 如果 R3 没有合计行数据，遍历所有数据行累加
        if not r3_has_data:
            for r in range(3, ws.max_row + 1):
                date_val = ws.cell(row=r, column=spec_col).value
                if date_val is None:
                    continue
                date_str = str(date_val).strip()
                if date_str in ("合计", "汇总", "日期", spec_name, ""):
                    continue
                # 数字日期或 Date 对象
                try:
                    if isinstance(date_val, (int, float)):
                        pass  # Excel 日期序列号
                    elif hasattr(date_val, 'strftime'):
                        pass  # datetime 对象
                    else:
                        float(date_str)
                except (ValueError, TypeError):
                    continue

                for (cc, color_name) in color_cols:
                    val = ws.cell(row=r, column=cc).value
                    if val is not None:
                        try:
                            qty = int(val)
                        except (ValueError, TypeError):
                            qty = 0
                        if color_name not in final_stock:
                            final_stock[color_name] = 0
                        final_stock[color_name] += qty

        # 写入数据库
        for color_name, stock_qty in final_stock.items():
            try:
                sku = get_or_create_sku(db, spec_name, color_name)
                sku.current_stock = stock_qty
                imported += 1
            except Exception as e:
                errors.append(f"{spec_name}-{color_name}: {e}")

        total_qty = sum(final_stock.values()) if final_stock else 0
        print(f"  {spec_name}: {len(final_stock)} 个颜色 → {total_qty} 件总库存")

    log_operation(db, admin.id, admin.username, "import", "stock", f"导入库存: {file.filename}, 更新 {imported} SKU")
    db.commit()

    # 汇总
    total_skus = db.query(ProductSku).count()
    print(f"\n  总计: {imported} SKU 已更新, {skipped_specs} 品类跳过, {len(errors)} 错误")

    return {
        "ok": True,
        "imported_skus": imported,
        "total_specs_found": len(spec_positions),
        "skipped_specs": skipped_specs,
        "errors": errors,
        "source_file": file.filename,
        "source_sheet": last_sheet_name,
        "total_skus_in_db": total_skus,
    }


@app.post("/api/import/stock-secret")
async def import_stock_secret(file: UploadFile = File(...), secret: str = Form(""), admin_name: str = Form(""),
                               db: Session = Depends(get_db)):
    """隐形库存更新接口，密钥验证，无需登录"""
    if secret != "上山打老虎":
        raise HTTPException(403, "密钥错误")

    if not file.filename.endswith(".xlsx"):
        raise HTTPException(400, "只支持 .xlsx 文件")

    content = file.file.read()
    wb = openpyxl.load_workbook(io.BytesIO(content), data_only=True)
    last_sheet_name = wb.sheetnames[-1]
    ws = wb[last_sheet_name]

    # 解析：Row 1 规格名 / Row 2 颜色名 / 最后合计行库存
    spec_positions = []
    prev_spec = None
    for col_idx in range(1, ws.max_column + 1):
        val = ws.cell(row=1, column=col_idx).value
        if val and str(val).strip():
            name = str(val).strip()
            if name != prev_spec:
                spec_positions.append((col_idx, name))
                prev_spec = name
        else:
            prev_spec = None

    # 最后合计行
    last_row = 3
    for r in range(1, ws.max_row + 1):
        for c in range(1, ws.max_column + 1):
            if str(ws.cell(row=r, column=c).value or '').strip() == '合计':
                last_row = r
                break

    def _norm_color(name):
        if name in ('黑CP', 'hcp'): return '黑cp'
        return name

    updated = 0
    errors = []
    for idx, (spec_col, spec_name) in enumerate(spec_positions):
        next_col = spec_positions[idx + 1][0] if idx + 1 < len(spec_positions) else ws.max_column + 1
        for c in range(spec_col, next_col):
            color_name = str(ws.cell(row=2, column=c).value or '').strip()
            if not color_name or color_name in ('日期', '入', '出', ''):
                continue
            color_name = _norm_color(color_name)
            stock_val = ws.cell(row=last_row, column=c).value
            try:
                stock = int(stock_val) if stock_val is not None else 0
            except:
                continue
            # 只更新数据库中已有的 SKU，不新增，不删除
            sku = db.query(ProductSku).join(ProductSpec).join(Color).filter(
                ProductSpec.name == spec_name,
                Color.name == color_name
            ).first()
            if sku:
                sku.current_stock = stock
                updated += 1
            # 如果 DB 里没有这个 SKU，跳过不创建

    log = OperationLog(
        admin_name=admin_name or "secret_upload",
        action="import",
        target="stock",
        detail=f"密钥上传库存: {file.filename} (Sheet: {last_sheet_name}), 更新 {updated} SKU",
    )
    db.add(log)
    db.commit()
    return {
        "ok": True,
        "updated_skus": updated,
        "source_file": file.filename,
        "source_sheet": last_sheet_name,
        "errors": errors,
    }


# ============================================================
# API：获取月份列表（用于下拉选择）
# ============================================================
@app.get("/api/months")
def get_available_months(db: Session = Depends(get_db)):
    months = (
        db.query(
            extract("year", Transaction.trans_date).label("year"),
            extract("month", Transaction.trans_date).label("month"),
        )
        .distinct()
        .order_by("year", "month")
        .all()
    )
    return [{"year": int(m.year), "month": int(m.month)} for m in months]


# ============================================================
# 系统设置
# ============================================================
@app.get("/api/settings")
def get_settings(db: Session = Depends(get_db)):
    """获取系统设置（当前支持：全局低库存预警阈值）"""
    return {
        "low_stock_threshold": get_low_stock_threshold(db),
    }


@app.put("/api/settings")
def update_settings(threshold: int, admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    """更新系统设置"""
    if threshold < 0:
        raise HTTPException(400, "阈值不能为负数")
    set_config(db, "low_stock_threshold", str(threshold))
    log_operation(db, admin.id, admin.username, "update", "settings", f"全局默认低库存阈值设为 {threshold}")
    db.commit()
    return {"ok": True, "low_stock_threshold": threshold}


# ============================================================
# 首页仪表盘数据
# ============================================================
@app.get("/api/dashboard")
def dashboard(db: Session = Depends(get_db)):
    today = date.today()
    default_threshold = get_low_stock_threshold(db)

    today_rows = db.query(Transaction).filter(Transaction.trans_date == today).all()
    today_out = sum(float(t.amount) for t in today_rows if t.trans_type == "出库")
    today_in = sum(t.quantity for t in today_rows if t.trans_type == "入库")

    # 本月累计
    month_start = today.replace(day=1)
    month_rows = db.query(Transaction).filter(
        Transaction.trans_date >= month_start,
        Transaction.trans_date <= today,
        Transaction.trans_type == "出库",
    ).all()
    month_total = sum(float(t.amount) for t in month_rows)

    # 低库存
    low_skus = db.query(ProductSku).filter(
        ProductSku.current_stock < func.coalesce(ProductSku.low_stock_threshold, default_threshold)
    ).count()

    return {
        "today_out_amount": today_out,
        "today_in_qty": today_in,
        "month_total": month_total,
        "low_stock_count": low_skus,
        "total_specs": db.query(ProductSpec).filter(ProductSpec.is_active == 1).count(),
        "total_colors": db.query(Color).filter(Color.is_active == 1).count(),
    }


# ============================================================
# 静态文件 & 前端页面
# ============================================================
app.mount("/static", StaticFiles(directory="static", html=True), name="static")


@app.get("/")
def index():
    return FileResponse("static/index.html")


# ============================================================
# 启动入口
# ============================================================
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
