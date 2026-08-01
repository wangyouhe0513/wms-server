-- WMS 进销存系统 MySQL 建表语句
-- 与 Python 版本表结构完全一致

CREATE DATABASE IF NOT EXISTS wms_finance DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE wms_finance;

-- 规格
CREATE TABLE IF NOT EXISTS product_specs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    sort_order INT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 颜色
CREATE TABLE IF NOT EXISTS colors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    code VARCHAR(10) DEFAULT '',
    sort_order INT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- SKU（规格+颜色组合）
CREATE TABLE IF NOT EXISTS product_skus (
    id INT AUTO_INCREMENT PRIMARY KEY,
    spec_id INT NOT NULL,
    color_id INT NOT NULL,
    current_stock INT DEFAULT 0,
    low_stock_threshold INT DEFAULT 50,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_spec_color (spec_id, color_id),
    FOREIGN KEY (spec_id) REFERENCES product_specs(id),
    FOREIGN KEY (color_id) REFERENCES colors(id)
) ENGINE=InnoDB;

-- 销售人员
CREATE TABLE IF NOT EXISTS salespersons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    type VARCHAR(10) DEFAULT '员工',
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 出入库记录
CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trans_date DATE NOT NULL,
    trans_type VARCHAR(10) NOT NULL COMMENT '出库/入库',
    sku_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) DEFAULT 0,
    amount DECIMAL(12,2) DEFAULT 0,
    salesperson_id INT,
    entry_person VARCHAR(50) DEFAULT '',
    remark VARCHAR(200) DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sku_id) REFERENCES product_skus(id),
    FOREIGN KEY (salesperson_id) REFERENCES salespersons(id),
    INDEX idx_date (trans_date),
    INDEX idx_type (trans_type),
    INDEX idx_sp (salesperson_id)
) ENGINE=InnoDB;

-- 库存流水
CREATE TABLE IF NOT EXISTS inventory_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sku_id INT NOT NULL,
    transaction_id INT NOT NULL,
    change_qty INT NOT NULL,
    before_stock INT NOT NULL,
    after_stock INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sku_id) REFERENCES product_skus(id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id)
) ENGINE=InnoDB;

-- 管理员
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(200) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin',
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME
) ENGINE=InnoDB;

-- 操作日志
CREATE TABLE IF NOT EXISTS operation_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT,
    admin_name VARCHAR(50) DEFAULT '',
    action VARCHAR(50) NOT NULL,
    target VARCHAR(100) DEFAULT '',
    detail VARCHAR(500) DEFAULT '',
    ip_address VARCHAR(50) DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id),
    INDEX idx_log_time (created_at)
) ENGINE=InnoDB;

-- 系统配置
CREATE TABLE IF NOT EXISTS system_configs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `key` VARCHAR(50) NOT NULL UNIQUE,
    value VARCHAR(200) NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 默认管理员 admin/admin123
INSERT IGNORE INTO admins (username, password_hash, role) VALUES ('admin', SHA2('admin123', 256), 'superadmin');
-- 默认预警阈值
INSERT IGNORE INTO system_configs (`key`, value) VALUES ('low_stock_threshold', '50');
