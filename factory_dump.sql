PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE product_specs (
	id INTEGER NOT NULL, 
	name VARCHAR(50) NOT NULL, 
	sort_order INTEGER, 
	is_active INTEGER, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO product_specs VALUES(1,'6094',1,1,'2026-08-01 14:28:59.772517');
INSERT INTO product_specs VALUES(2,'A款',2,1,'2026-08-01 14:28:59.773030');
INSERT INTO product_specs VALUES(3,'B款',3,1,'2026-08-01 14:28:59.773196');
INSERT INTO product_specs VALUES(4,'儿童6094',4,1,'2026-08-01 14:28:59.773342');
INSERT INTO product_specs VALUES(5,'儿童印花款',5,1,'2026-08-01 14:28:59.773480');
INSERT INTO product_specs VALUES(6,'儿童钢丝',6,1,'2026-08-01 14:28:59.773614');
INSERT INTO product_specs VALUES(7,'儿网背心',7,1,'2026-08-01 14:28:59.773747');
INSERT INTO product_specs VALUES(8,'八包',8,1,'2026-08-01 14:28:59.773877');
INSERT INTO product_specs VALUES(9,'包边',9,1,'2026-08-01 14:28:59.774007');
INSERT INTO product_specs VALUES(10,'小三连',10,1,'2026-08-01 14:28:59.774138');
INSERT INTO product_specs VALUES(11,'无钢丝',11,1,'2026-08-01 14:28:59.774266');
INSERT INTO product_specs VALUES(12,'纲八',12,1,'2026-08-01 14:28:59.774395');
INSERT INTO product_specs VALUES(13,'网背心',13,1,'2026-08-01 14:28:59.774524');
INSERT INTO product_specs VALUES(14,'腰带',14,1,'2026-08-01 14:28:59.774651');
INSERT INTO product_specs VALUES(15,'钢丝',15,1,'2026-08-01 14:28:59.774779');
INSERT INTO product_specs VALUES(16,'黑鹰',16,1,'2026-08-01 14:28:59.774907');
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
INSERT INTO colors VALUES(1,'acu',NULL,0,1,'2026-08-01 14:28:59.775857');
INSERT INTO colors VALUES(2,'cp',NULL,0,1,'2026-08-01 14:28:59.775858');
INSERT INTO colors VALUES(3,'hcp',NULL,0,1,'2026-08-01 14:28:59.775859');
INSERT INTO colors VALUES(4,'l/xl',NULL,0,1,'2026-08-01 14:28:59.775859');
INSERT INTO colors VALUES(5,'s/m',NULL,0,1,'2026-08-01 14:28:59.775860');
INSERT INTO colors VALUES(6,'俄',NULL,0,1,'2026-08-01 14:28:59.775861');
INSERT INTO colors VALUES(7,'卡其',NULL,0,1,'2026-08-01 14:28:59.775861');
INSERT INTO colors VALUES(8,'女',NULL,0,1,'2026-08-01 14:28:59.775862');
INSERT INTO colors VALUES(9,'废墟',NULL,0,1,'2026-08-01 14:28:59.775863');
INSERT INTO colors VALUES(10,'数码',NULL,0,1,'2026-08-01 14:28:59.775863');
INSERT INTO colors VALUES(11,'男',NULL,0,1,'2026-08-01 14:28:59.775864');
INSERT INTO colors VALUES(12,'绿',NULL,0,1,'2026-08-01 14:28:59.775865');
INSERT INTO colors VALUES(13,'绿大花',NULL,0,1,'2026-08-01 14:28:59.775865');
INSERT INTO colors VALUES(14,'荒漠数码',NULL,0,1,'2026-08-01 14:28:59.775866');
INSERT INTO colors VALUES(15,'黄数码',NULL,0,1,'2026-08-01 14:28:59.775866');
INSERT INTO colors VALUES(16,'黄蟒纹',NULL,0,1,'2026-08-01 14:28:59.775867');
INSERT INTO colors VALUES(17,'黑',NULL,0,1,'2026-08-01 14:28:59.775868');
INSERT INTO colors VALUES(19,'黑cp',NULL,0,1,'2026-08-01 14:28:59.775869');
INSERT INTO colors VALUES(20,'黑中号',NULL,0,1,'2026-08-01 14:28:59.775870');
INSERT INTO colors VALUES(21,'黑蟒纹',NULL,0,1,'2026-08-01 14:28:59.775870');
CREATE TABLE salespersons (
	id INTEGER NOT NULL, 
	name VARCHAR(30) NOT NULL, 
	type VARCHAR(10), 
	is_active INTEGER, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO salespersons VALUES(1,'王河','员工',1,'2026-07-31 12:59:10.686729');
INSERT INTO salespersons VALUES(2,'admin','员工',1,'2026-08-01 11:03:20.112900');
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
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(sku_id) REFERENCES product_skus (id), 
	FOREIGN KEY(salesperson_id) REFERENCES salespersons (id)
);
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
INSERT INTO admins VALUES(1,'admin','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9','superadmin',1,'2026-07-31 13:04:50.769347','2026-08-01 11:18:37.725202');
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
INSERT INTO operation_logs VALUES(1,1,'admin','login','auth','管理员登录','','2026-07-31 13:23:15.752469');
INSERT INTO operation_logs VALUES(2,1,'admin','login','auth','管理员登录','','2026-07-31 13:23:24.639902');
INSERT INTO operation_logs VALUES(3,1,'admin','create','spec','创建规格: test','','2026-07-31 13:23:24.691034');
INSERT INTO operation_logs VALUES(4,1,'admin','logout','auth','管理员登出','','2026-07-31 13:23:24.922123');
INSERT INTO operation_logs VALUES(5,1,'admin','login','auth','管理员登录','','2026-07-31 13:23:38.266798');
INSERT INTO operation_logs VALUES(6,1,'admin','import','stock','导入库存: 2026年库存.xlsx, 更新 47 SKU','','2026-07-31 13:23:38.420269');
INSERT INTO operation_logs VALUES(7,1,'admin','login','auth','管理员登录','','2026-07-31 13:35:40.759385');
INSERT INTO operation_logs VALUES(8,1,'admin','login','auth','管理员登录','','2026-07-31 13:43:23.403310');
INSERT INTO operation_logs VALUES(9,1,'admin','update','threshold','SKU 网背心-黑 阈值设为 100','','2026-07-31 13:43:23.424086');
INSERT INTO operation_logs VALUES(10,1,'admin','login','auth','管理员登录','','2026-07-31 13:46:54.003755');
INSERT INTO operation_logs VALUES(11,1,'admin','login','auth','管理员登录','','2026-07-31 13:47:59.984508');
INSERT INTO operation_logs VALUES(12,1,'admin','login','auth','管理员登录','','2026-07-31 13:48:37.293397');
INSERT INTO operation_logs VALUES(13,1,'admin','logout','auth','管理员登出','','2026-07-31 13:48:37.321101');
INSERT INTO operation_logs VALUES(14,1,'admin','login','auth','管理员登录','','2026-07-31 13:49:32.028062');
INSERT INTO operation_logs VALUES(15,1,'admin','login','auth','管理员登录','','2026-07-31 16:58:13.760053');
INSERT INTO operation_logs VALUES(16,1,'admin','create','transaction','批量录入 1 条出入库记录','','2026-07-31 17:00:51.083955');
INSERT INTO operation_logs VALUES(17,1,'admin','create','transaction','批量录入 1 条出入库记录','','2026-07-31 17:01:19.002728');
INSERT INTO operation_logs VALUES(18,1,'admin','create','transaction','批量录入 1 条出入库记录','','2026-07-31 17:02:48.376980');
INSERT INTO operation_logs VALUES(19,1,'admin','login','auth','管理员登录','','2026-07-31 17:05:36.677677');
INSERT INTO operation_logs VALUES(20,1,'admin','logout','auth','管理员登出','','2026-07-31 17:05:36.806637');
INSERT INTO operation_logs VALUES(21,1,'admin','login','auth','管理员登录','','2026-07-31 17:05:38.239693');
INSERT INTO operation_logs VALUES(22,1,'admin','login','auth','管理员登录','','2026-07-31 17:15:32.551259');
INSERT INTO operation_logs VALUES(23,1,'admin','logout','auth','管理员登出','','2026-07-31 17:15:32.592211');
INSERT INTO operation_logs VALUES(24,1,'admin','login','auth','管理员登录','','2026-07-31 17:15:33.868333');
INSERT INTO operation_logs VALUES(25,1,'admin','login','auth','管理员登录','','2026-08-01 10:33:35.863186');
INSERT INTO operation_logs VALUES(26,1,'admin','logout','auth','管理员登出','','2026-08-01 10:33:35.899219');
INSERT INTO operation_logs VALUES(27,1,'admin','login','auth','管理员登录','','2026-08-01 10:33:40.306782');
INSERT INTO operation_logs VALUES(28,1,'admin','update','settings','全局默认低库存阈值设为 50','','2026-08-01 10:33:49.950032');
INSERT INTO operation_logs VALUES(29,1,'admin','update','settings','全局默认低库存阈值设为 50','','2026-08-01 10:33:52.903116');
INSERT INTO operation_logs VALUES(30,1,'admin','update','settings','全局默认低库存阈值设为 50','','2026-08-01 10:33:53.508550');
INSERT INTO operation_logs VALUES(31,1,'admin','update','settings','全局默认低库存阈值设为 50','','2026-08-01 10:33:53.720373');
INSERT INTO operation_logs VALUES(32,1,'admin','update','settings','全局默认低库存阈值设为 51','','2026-08-01 10:33:55.708799');
INSERT INTO operation_logs VALUES(33,1,'admin','update','settings','全局默认低库存阈值设为 51','','2026-08-01 10:33:56.107905');
INSERT INTO operation_logs VALUES(34,1,'admin','update','settings','全局默认低库存阈值设为 51','','2026-08-01 10:33:56.300434');
INSERT INTO operation_logs VALUES(35,1,'admin','update','settings','全局默认低库存阈值设为 51','','2026-08-01 10:33:56.478050');
INSERT INTO operation_logs VALUES(36,1,'admin','update','settings','全局默认低库存阈值设为 51','','2026-08-01 10:33:56.660425');
INSERT INTO operation_logs VALUES(37,1,'admin','update','settings','全局默认低库存阈值设为 51','','2026-08-01 10:33:57.134745');
INSERT INTO operation_logs VALUES(38,1,'admin','update','settings','全局默认低库存阈值设为 51','','2026-08-01 10:34:15.236589');
INSERT INTO operation_logs VALUES(39,1,'admin','login','auth','管理员登录','','2026-08-01 10:36:03.859123');
INSERT INTO operation_logs VALUES(40,1,'admin','update','settings','全局默认低库存阈值设为 99','','2026-08-01 10:36:04.030656');
INSERT INTO operation_logs VALUES(41,1,'admin','update','threshold','SKU 网背心-黑 阈值设为 77','','2026-08-01 10:36:04.075547');
INSERT INTO operation_logs VALUES(42,1,'admin','login','auth','管理员登录','','2026-08-01 10:40:37.160764');
INSERT INTO operation_logs VALUES(43,1,'admin','logout','auth','管理员登出','','2026-08-01 10:40:37.180140');
INSERT INTO operation_logs VALUES(44,1,'admin','login','auth','管理员登录','','2026-08-01 10:40:49.611580');
INSERT INTO operation_logs VALUES(45,1,'admin','login','auth','管理员登录','','2026-08-01 10:55:36.678465');
INSERT INTO operation_logs VALUES(46,1,'admin','logout','auth','管理员登出','','2026-08-01 10:55:36.740716');
INSERT INTO operation_logs VALUES(47,1,'admin','login','auth','管理员登录','','2026-08-01 10:55:40.389245');
INSERT INTO operation_logs VALUES(48,1,'admin','create','transaction','批量录入 1 条出入库记录','','2026-08-01 10:56:20.868601');
INSERT INTO operation_logs VALUES(49,1,'admin','login','auth','管理员登录','','2026-08-01 11:03:20.054463');
INSERT INTO operation_logs VALUES(50,1,'admin','create','transaction','批量录入 1 条出入库记录','','2026-08-01 11:03:20.115307');
INSERT INTO operation_logs VALUES(51,1,'admin','login','auth','管理员登录','','2026-08-01 11:06:45.277033');
INSERT INTO operation_logs VALUES(52,1,'admin','logout','auth','管理员登出','','2026-08-01 11:06:45.321489');
INSERT INTO operation_logs VALUES(53,1,'admin','login','auth','管理员登录','','2026-08-01 11:06:49.297811');
INSERT INTO operation_logs VALUES(54,1,'admin','create','transaction','批量录入 1 条出入库记录','','2026-08-01 11:07:01.730720');
INSERT INTO operation_logs VALUES(55,1,'admin','login','auth','管理员登录','','2026-08-01 11:12:08.620740');
INSERT INTO operation_logs VALUES(56,1,'admin','create','transaction','批量录入 1 条出入库记录','','2026-08-01 11:12:09.025647');
INSERT INTO operation_logs VALUES(57,1,'admin','delete','transaction','撤销 入库 记录: 网背心-黑 x10','','2026-08-01 11:12:09.353781');
INSERT INTO operation_logs VALUES(58,1,'admin','login','auth','管理员登录','','2026-08-01 11:18:33.000748');
INSERT INTO operation_logs VALUES(59,1,'admin','logout','auth','管理员登出','','2026-08-01 11:18:33.036393');
INSERT INTO operation_logs VALUES(60,1,'admin','login','auth','管理员登录','','2026-08-01 11:18:37.726501');
INSERT INTO operation_logs VALUES(61,1,'admin','update','settings','全局默认低库存阈值设为 50','','2026-08-01 12:39:53.682296');
INSERT INTO operation_logs VALUES(62,1,'admin','update','threshold','SKU 网背心-黑中号 阈值设为 100','','2026-08-01 12:39:59.290811');
CREATE TABLE system_configs (
	id INTEGER NOT NULL, 
	"key" VARCHAR(50) NOT NULL, 
	value VARCHAR(200) NOT NULL, 
	updated_at DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE ("key")
);
INSERT INTO system_configs VALUES(1,'low_stock_threshold','50','2026-08-01 10:39:39.219358');
CREATE UNIQUE INDEX uk_spec_color ON product_skus (spec_id, color_id);
CREATE INDEX idx_date ON transactions (trans_date);
CREATE INDEX idx_sp ON transactions (salesperson_id);
CREATE INDEX idx_type ON transactions (trans_type);
CREATE INDEX idx_log_time ON operation_logs (created_at);
COMMIT;
