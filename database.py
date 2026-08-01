"""
数据库连接和会话管理
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./factory.db")

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {})
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
    Base.metadata.create_all(bind=engine)

    # 确保默认数据存在
    db = SessionLocal()
    try:
        from models import Admin, SystemConfig
        import hashlib

        # 默认管理员
        if not db.query(Admin).filter(Admin.username == "admin").first():
            admin = Admin(
                username="admin",
                password_hash=hashlib.sha256("admin123".encode()).hexdigest(),
                role="superadmin"
            )
            db.add(admin)

        # 默认预警阈值
        if not db.query(SystemConfig).filter(SystemConfig.key == "low_stock_threshold").first():
            db.add(SystemConfig(key="low_stock_threshold", value="50"))

        db.commit()
    finally:
        db.close()
