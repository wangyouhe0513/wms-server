CREATE TABLE IF NOT EXISTS salary_spec_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    spec_name VARCHAR(40) NOT NULL,
    item_name VARCHAR(60) NOT NULL,
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_spec_item (spec_name, item_name),
    INDEX idx_ssi_spec (spec_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
