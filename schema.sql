CREATE TABLE product_specs (
	id INTEGER NOT NULL, 
	name VARCHAR(50) NOT NULL, 
	sort_order INTEGER, 
	is_active INTEGER, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
CREATE TABLE colors (
	id INTEGER NOT NULL, 
	name VARCHAR(30) NOT NULL, 
	code VARCHAR(10), 
	sort_order INTEGER, 
	is_active INTEGER, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
CREATE TABLE salespersons (
	id INTEGER NOT NULL, 
	name VARCHAR(30) NOT NULL, 
	type VARCHAR(10), 
	is_active INTEGER, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
CREATE TABLE product_skus (
	id INTEGER NOT NULL, 
	spec_id INTEGER NOT NULL, 
	color_id INTEGER NOT NULL, 
	current_stock INTEGER, 
	created_at DATETIME, low_stock_threshold INTEGER DEFAULT 50, 
	PRIMARY KEY (id), 
	FOREIGN KEY(spec_id) REFERENCES product_specs (id), 
	FOREIGN KEY(color_id) REFERENCES colors (id)
);
CREATE UNIQUE INDEX uk_spec_color ON product_skus (spec_id, color_id);
CREATE TABLE transactions (
	id INTEGER NOT NULL, 
	trans_date DATE NOT NULL, 
	trans_type VARCHAR(10) NOT NULL, 
	sku_id INTEGER NOT NULL, 
	quantity INTEGER NOT NULL, 
	unit_price DECIMAL(10, 2), 
	amount DECIMAL(12, 2), 
	salesperson_id INTEGER, 
	remark VARCHAR(200), 
	created_at DATETIME, entry_person VARCHAR(50) DEFAULT '', 
	PRIMARY KEY (id), 
	FOREIGN KEY(sku_id) REFERENCES product_skus (id), 
	FOREIGN KEY(salesperson_id) REFERENCES salespersons (id)
);
CREATE INDEX idx_date ON transactions (trans_date);
CREATE INDEX idx_sp ON transactions (salesperson_id);
CREATE INDEX idx_type ON transactions (trans_type);
CREATE TABLE inventory_logs (
	id INTEGER NOT NULL, 
	sku_id INTEGER NOT NULL, 
	transaction_id INTEGER NOT NULL, 
	change_qty INTEGER NOT NULL, 
	before_stock INTEGER NOT NULL, 
	after_stock INTEGER NOT NULL, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(sku_id) REFERENCES product_skus (id), 
	FOREIGN KEY(transaction_id) REFERENCES transactions (id)
);
CREATE TABLE admins (
	id INTEGER NOT NULL, 
	username VARCHAR(50) NOT NULL, 
	password_hash VARCHAR(200) NOT NULL, 
	role VARCHAR(20), 
	is_active INTEGER, 
	created_at DATETIME, 
	last_login DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE (username)
);
CREATE TABLE operation_logs (
	id INTEGER NOT NULL, 
	admin_id INTEGER, 
	admin_name VARCHAR(50), 
	action VARCHAR(50) NOT NULL, 
	target VARCHAR(100), 
	detail VARCHAR(500), 
	ip_address VARCHAR(50), 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(admin_id) REFERENCES admins (id)
);
CREATE INDEX idx_log_time ON operation_logs (created_at);
CREATE TABLE system_configs (
	id INTEGER NOT NULL, 
	"key" VARCHAR(50) NOT NULL, 
	value VARCHAR(200) NOT NULL, 
	updated_at DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE ("key")
);
-- 默认数据
INSERT OR IGNORE INTO admins (username, password_hash, role) VALUES ('admin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'superadmin');
INSERT OR IGNORE INTO system_configs (key, value) VALUES ('low_stock_threshold', '50');
