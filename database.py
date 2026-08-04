"""
数据库连接和会话管理 — MySQL
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os

# MySQL 连接：环境变量或默认值
DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_USER = os.getenv("DB_USER", "root")
DB_PASS = os.getenv("DB_PASS", "")
DB_NAME = os.getenv("DB_NAME", "wms_finance")

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4"
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_recycle=3600)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """创建所有表并插入默认数据"""
    # 先创建数据库（如果不存在）
    try:
        import pymysql
        conn = pymysql.connect(
            host=DB_HOST, port=int(DB_PORT),
            user=DB_USER, password=DB_PASS,
            charset='utf8mb4'
        )
        with conn.cursor() as cur:
            cur.execute(f"CREATE DATABASE IF NOT EXISTS `{DB_NAME}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        conn.close()
    except Exception as e:
        print(f"[init_db] 创建数据库警告: {e}")

    Base.metadata.create_all(bind=engine)

    # 确保默认数据存在
    db = SessionLocal()
    try:
        from models import Admin, SystemConfig
        import hashlib

        if not db.query(Admin).filter(Admin.username == "admin").first():
            admin = Admin(
                username="admin",
                password_hash=hashlib.sha256("admin123".encode()).hexdigest(),
                role="superadmin"
            )
            db.add(admin)

        if not db.query(SystemConfig).filter(SystemConfig.key == "low_stock_threshold").first():
            db.add(SystemConfig(key="low_stock_threshold", value="50"))

        db.commit()
        print("[init_db] 数据库初始化完成")
    finally:
        db.close()
