-- 新增表结构（不影响现有数据）
-- 在服务器执行: mysql -u root wms_finance < update_tables.sql

CREATE TABLE IF NOT EXISTS salary_workers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    job_type VARCHAR(20) DEFAULT '机工',
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS salary_prices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(60) NOT NULL UNIQUE,
    unit_price DECIMAL(10,2) DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS salary_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    worker_id INT NOT NULL,
    month VARCHAR(7) NOT NULL,
    item_name VARCHAR(60) DEFAULT '',
    quantity INT DEFAULT 0,
    unit_price DECIMAL(10,2) DEFAULT 0,
    amount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(10) DEFAULT '微信',
    paid TINYINT DEFAULT 0,
    remark VARCHAR(100) DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (worker_id) REFERENCES salary_workers(id),
    INDEX idx_salary_month (month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS finance_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    sort_order INT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 默认财务类别
INSERT IGNORE INTO finance_categories (name, sort_order) VALUES 
('货款',1),('日杂',2),('辅料',3),('运费',4),('印花',5),('布',6),('货拉拉',7),('其他',8);

CREATE TABLE IF NOT EXISTS finance_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(10) NOT NULL COMMENT '收入/支出',
    date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    category VARCHAR(30) DEFAULT '',
    detail VARCHAR(200) DEFAULT '',
    person VARCHAR(30) DEFAULT '',
    receipt VARCHAR(2000) DEFAULT '',
    status VARCHAR(10) DEFAULT '已审核',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_finance_date (date),
    INDEX idx_finance_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
