"""
数据模型定义
"""
from sqlalchemy import Column, Integer, String, DECIMAL, Date, DateTime, ForeignKey, Enum, Index
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime


class ProductSpec(Base):
    __tablename__ = "product_specs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(50), unique=True, nullable=False, comment="规格名称")
    sort_order = Column(Integer, default=0)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.now)

    skus = relationship("ProductSku", back_populates="spec")


class Color(Base):
    __tablename__ = "colors"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(30), unique=True, nullable=False, comment="颜色名称")
    code = Column(String(10), comment="缩写代号")
    sort_order = Column(Integer, default=0)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.now)

    skus = relationship("ProductSku", back_populates="color")


class ProductSku(Base):
    __tablename__ = "product_skus"

    id = Column(Integer, primary_key=True, autoincrement=True)
    spec_id = Column(Integer, ForeignKey("product_specs.id"), nullable=False)
    color_id = Column(Integer, ForeignKey("colors.id"), nullable=False)
    current_stock = Column(Integer, default=0, comment="实时库存")
    low_stock_threshold = Column(Integer, default=50, comment="低库存阈值，默认50")
    created_at = Column(DateTime, default=datetime.now)

    spec = relationship("ProductSpec", back_populates="skus")
    color = relationship("Color", back_populates="skus")
    transactions = relationship("Transaction", back_populates="sku")
    inventory_logs = relationship("InventoryLog", back_populates="sku")

    __table_args__ = (Index("uk_spec_color", "spec_id", "color_id", unique=True),)


class Salesperson(Base):
    __tablename__ = "salespersons"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(30), unique=True, nullable=False)
    type = Column(String(10), default="员工", comment="员工/渠道/电商")
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.now)


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    trans_date = Column(Date, nullable=False, comment="业务日期")
    trans_type = Column(String(10), nullable=False, comment="出库/入库")
    sku_id = Column(Integer, ForeignKey("product_skus.id"), nullable=False)
    quantity = Column(Integer, nullable=False, comment="数量")
    unit_price = Column(DECIMAL(10, 2), default=0, comment="单价")
    amount = Column(DECIMAL(12, 2), default=0, comment="金额")
    salesperson_id = Column(Integer, ForeignKey("salespersons.id"), nullable=True)
    entry_person = Column(String(50), default="", comment="录入人（操作员）")
    remark = Column(String(200))
    created_at = Column(DateTime, default=datetime.now)

    sku = relationship("ProductSku", back_populates="transactions")
    salesperson = relationship("Salesperson")

    __table_args__ = (
        Index("idx_date", "trans_date"),
        Index("idx_type", "trans_type"),
        Index("idx_sp", "salesperson_id"),
    )


class InventoryLog(Base):
    __tablename__ = "inventory_logs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    sku_id = Column(Integer, ForeignKey("product_skus.id"), nullable=False)
    transaction_id = Column(Integer, ForeignKey("transactions.id"), nullable=False)
    change_qty = Column(Integer, nullable=False, comment="变化量(+入/-出)")
    before_stock = Column(Integer, nullable=False)
    after_stock = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=datetime.now)

    sku = relationship("ProductSku", back_populates="inventory_logs")


class Admin(Base):
    __tablename__ = "admins"

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False, comment="用户名")
    password_hash = Column(String(200), nullable=False, comment="密码哈希")
    role = Column(String(20), default="admin", comment="admin/superadmin")
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.now)
    last_login = Column(DateTime, nullable=True)


class OperationLog(Base):
    __tablename__ = "operation_logs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    admin_id = Column(Integer, ForeignKey("admins.id"), nullable=True)
    admin_name = Column(String(50), comment="操作人用户名")
    action = Column(String(50), nullable=False, comment="操作类型: login/logout/create/update/delete/import")
    target = Column(String(100), comment="操作对象: transaction/spec/color/admin/stock")
    detail = Column(String(500), comment="操作详情")
    ip_address = Column(String(50))
    created_at = Column(DateTime, default=datetime.now)

    __table_args__ = (Index("idx_log_time", "created_at"),)


class SystemConfig(Base):
    __tablename__ = "system_configs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    key = Column(String(50), unique=True, nullable=False, comment="配置键")
    value = Column(String(200), nullable=False, comment="配置值")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)


class FinanceRecord(Base):
    __tablename__ = "finance_records"

    id = Column(Integer, primary_key=True, autoincrement=True)
    type = Column(String(10), nullable=False, comment="收入/支出")
    date = Column(Date, nullable=False, comment="日期")
    amount = Column(DECIMAL(12, 2), nullable=False, comment="金额")
    category = Column(String(30), default="", comment="类别")
    detail = Column(String(200), default="", comment="明细")
    person = Column(String(30), default="", comment="责任人")
    receipt = Column(String(2000), default="", comment="凭证截图路径，逗号分隔多张")
    status = Column(String(10), default="已审核", comment="已审核")
    created_at = Column(DateTime, default=datetime.now)

    __table_args__ = (Index("idx_finance_date", "date"), Index("idx_finance_type", "type"))


class FinanceCategory(Base):
    __tablename__ = "finance_categories"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(30), unique=True, nullable=False)
    sort_order = Column(Integer, default=0)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.now)


# === 工资模块 ===
class SalaryWorker(Base):
    __tablename__ = "salary_workers"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(30), unique=True, nullable=False)
    job_type = Column(String(20), default="机工", comment="工种")
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.now)


class SalaryPrice(Base):
    __tablename__ = "salary_prices"

    id = Column(Integer, primary_key=True, autoincrement=True)
    item_name = Column(String(60), unique=True, nullable=False, comment="工序名称")
    unit_price = Column(DECIMAL(10, 2), default=0, comment="标准单价")
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.now)


class SalaryRecord(Base):
    __tablename__ = "salary_records"

    id = Column(Integer, primary_key=True, autoincrement=True)
    worker_id = Column(Integer, ForeignKey("salary_workers.id"), nullable=False)
    month = Column(String(7), nullable=False, comment="月份 2026-08")
    item_name = Column(String(60), default="", comment="工序")
    quantity = Column(Integer, default=0, comment="数量")
    unit_price = Column(DECIMAL(10, 2), default=0, comment="单价(可手动修改)")
    amount = Column(DECIMAL(10, 2), default=0, comment="金额=数量×单价")
    payment_method = Column(String(10), default="微信", comment="支付方式")
    paid = Column(Integer, default=0, comment="0未付/1已付")
    remark = Column(String(100), default="")
    created_at = Column(DateTime, default=datetime.now)

    worker = relationship("SalaryWorker")

    __table_args__ = (Index("idx_salary_month", "month"),)
