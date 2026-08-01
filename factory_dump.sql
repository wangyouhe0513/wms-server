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
INSERT INTO product_specs VALUES(1,'网背心',0,1,'2026-07-31 12:36:50.194479');
INSERT INTO product_specs VALUES(2,'6094',0,1,'2026-07-31 12:39:41.865957');
INSERT INTO product_specs VALUES(3,'无钢丝',0,1,'2026-07-31 12:39:41.877243');
INSERT INTO product_specs VALUES(4,'钢丝',0,1,'2026-07-31 12:39:41.882236');
INSERT INTO product_specs VALUES(5,'儿童6094',0,1,'2026-07-31 12:39:41.885581');
INSERT INTO product_specs VALUES(6,'纲八',0,1,'2026-07-31 12:39:41.895438');
INSERT INTO product_specs VALUES(7,'黑鹰',0,1,'2026-07-31 12:39:41.897233');
INSERT INTO product_specs VALUES(8,'儿童钢丝',0,1,'2026-07-31 12:39:41.898377');
INSERT INTO product_specs VALUES(9,'A款',0,1,'2026-07-31 12:39:41.900310');
INSERT INTO product_specs VALUES(10,'B款',0,1,'2026-07-31 12:39:41.901340');
INSERT INTO product_specs VALUES(11,'八包',0,1,'2026-07-31 12:39:41.902360');
INSERT INTO product_specs VALUES(12,'test',0,1,'2026-07-31 13:23:24.691737');
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
INSERT INTO colors VALUES(1,'黑',NULL,0,1,'2026-07-31 12:36:50.197030');
INSERT INTO colors VALUES(2,'黑中号',NULL,0,1,'2026-07-31 12:36:50.200101');
INSERT INTO colors VALUES(3,'绿',NULL,0,1,'2026-07-31 12:36:50.201586');
INSERT INTO colors VALUES(4,'卡其',NULL,0,1,'2026-07-31 12:36:50.202618');
INSERT INTO colors VALUES(5,'cp',NULL,0,1,'2026-07-31 12:36:50.203774');
INSERT INTO colors VALUES(6,'acu',NULL,0,1,'2026-07-31 12:36:50.204820');
INSERT INTO colors VALUES(7,'黑cp',NULL,0,1,'2026-07-31 12:36:50.205853');
INSERT INTO colors VALUES(8,'黑蟒纹',NULL,0,1,'2026-07-31 12:36:50.206873');
INSERT INTO colors VALUES(9,'黑CP',NULL,0,1,'2026-07-31 12:36:50.207903');
INSERT INTO colors VALUES(10,'数码',NULL,0,1,'2026-07-31 12:36:50.208910');
INSERT INTO colors VALUES(11,'俄',NULL,0,1,'2026-07-31 12:36:50.209919');
INSERT INTO colors VALUES(12,'黄蟒纹',NULL,0,1,'2026-07-31 12:36:50.210924');
INSERT INTO colors VALUES(13,'废墟',NULL,0,1,'2026-07-31 12:36:50.211959');
INSERT INTO colors VALUES(14,'黄数码',NULL,0,1,'2026-07-31 12:36:50.212973');
INSERT INTO colors VALUES(15,'绿大花',NULL,0,1,'2026-07-31 12:36:50.214054');
INSERT INTO colors VALUES(16,'男',NULL,0,1,'2026-07-31 12:36:50.215089');
INSERT INTO colors VALUES(17,'hcp',NULL,0,1,'2026-07-31 12:36:50.216232');
INSERT INTO colors VALUES(18,'s/m',NULL,0,1,'2026-07-31 12:36:50.217330');
INSERT INTO colors VALUES(19,'l/xl',NULL,0,1,'2026-07-31 12:36:50.218329');
INSERT INTO colors VALUES(20,'荒漠数码',NULL,0,1,'2026-07-31 12:36:50.219323');
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
INSERT INTO product_skus VALUES(1,1,1,1890,'2026-07-31 12:36:50.199331',100);
INSERT INTO product_skus VALUES(2,1,2,203,'2026-07-31 12:36:50.200972',50);
INSERT INTO product_skus VALUES(3,1,3,564,'2026-07-31 12:36:50.202035',50);
INSERT INTO product_skus VALUES(4,1,4,834,'2026-07-31 12:36:50.203134',50);
INSERT INTO product_skus VALUES(5,1,5,224,'2026-07-31 12:36:50.204232',50);
INSERT INTO product_skus VALUES(6,1,6,493,'2026-07-31 12:36:50.205265',50);
INSERT INTO product_skus VALUES(7,1,7,615,'2026-07-31 12:36:50.206291',50);
INSERT INTO product_skus VALUES(8,1,8,770,'2026-07-31 12:36:50.207319',50);
INSERT INTO product_skus VALUES(9,1,9,258,'2026-07-31 12:36:50.208337',50);
INSERT INTO product_skus VALUES(10,1,10,356,'2026-07-31 12:36:50.209341',50);
INSERT INTO product_skus VALUES(11,1,11,1064,'2026-07-31 12:36:50.210350',50);
INSERT INTO product_skus VALUES(12,1,12,914,'2026-07-31 12:36:50.211378',50);
INSERT INTO product_skus VALUES(13,1,13,1477,'2026-07-31 12:36:50.212394',50);
INSERT INTO product_skus VALUES(14,1,14,497,'2026-07-31 12:36:50.213417',50);
INSERT INTO product_skus VALUES(15,1,15,705,'2026-07-31 12:36:50.214517',50);
INSERT INTO product_skus VALUES(16,1,16,2,'2026-07-31 12:36:50.215601',50);
INSERT INTO product_skus VALUES(17,1,17,1320,'2026-07-31 12:36:50.216717',50);
INSERT INTO product_skus VALUES(18,1,18,-1207,'2026-07-31 12:36:50.217763',50);
INSERT INTO product_skus VALUES(19,1,19,-1463,'2026-07-31 12:36:50.218754',50);
INSERT INTO product_skus VALUES(20,1,20,-30,'2026-07-31 12:36:50.219804',50);
INSERT INTO product_skus VALUES(21,2,1,1010,'2026-07-31 12:39:41.867722',50);
INSERT INTO product_skus VALUES(22,2,3,416,'2026-07-31 12:39:41.868687',50);
INSERT INTO product_skus VALUES(23,2,4,389,'2026-07-31 12:39:41.869499',50);
INSERT INTO product_skus VALUES(24,2,5,379,'2026-07-31 12:39:41.870280',50);
INSERT INTO product_skus VALUES(25,2,8,218,'2026-07-31 12:39:41.871045',50);
INSERT INTO product_skus VALUES(26,2,6,215,'2026-07-31 12:39:41.872239',50);
INSERT INTO product_skus VALUES(27,2,9,129,'2026-07-31 12:39:41.873192',50);
INSERT INTO product_skus VALUES(28,2,10,178,'2026-07-31 12:39:41.874242',50);
INSERT INTO product_skus VALUES(29,2,11,267,'2026-07-31 12:39:41.875057',50);
INSERT INTO product_skus VALUES(30,2,12,49,'2026-07-31 12:39:41.875852',50);
INSERT INTO product_skus VALUES(31,2,13,170,'2026-07-31 12:39:41.876619',50);
INSERT INTO product_skus VALUES(32,3,1,654,'2026-07-31 12:39:41.878282',50);
INSERT INTO product_skus VALUES(33,3,3,182,'2026-07-31 12:39:41.879282',50);
INSERT INTO product_skus VALUES(34,3,4,544,'2026-07-31 12:39:41.880154',50);
INSERT INTO product_skus VALUES(35,3,5,45,'2026-07-31 12:39:41.880993',50);
INSERT INTO product_skus VALUES(36,3,6,195,'2026-07-31 12:39:41.881791',50);
INSERT INTO product_skus VALUES(37,4,1,346,'2026-07-31 12:39:41.882870',50);
INSERT INTO product_skus VALUES(38,4,3,53,'2026-07-31 12:39:41.883634',50);
INSERT INTO product_skus VALUES(39,4,4,147,'2026-07-31 12:39:41.884388',50);
INSERT INTO product_skus VALUES(40,4,5,108,'2026-07-31 12:39:41.885151',50);
INSERT INTO product_skus VALUES(41,5,1,994,'2026-07-31 12:39:41.886184',50);
INSERT INTO product_skus VALUES(42,5,7,644,'2026-07-31 12:39:41.886936',50);
INSERT INTO product_skus VALUES(43,5,5,702,'2026-07-31 12:39:41.887696',50);
INSERT INTO product_skus VALUES(44,5,13,453,'2026-07-31 12:39:41.888741',50);
INSERT INTO product_skus VALUES(45,5,6,225,'2026-07-31 12:39:41.889606',50);
INSERT INTO product_skus VALUES(46,5,4,527,'2026-07-31 12:39:41.890380',50);
INSERT INTO product_skus VALUES(47,5,8,323,'2026-07-31 12:39:41.891157',50);
INSERT INTO product_skus VALUES(48,5,3,682,'2026-07-31 12:39:41.891923',50);
INSERT INTO product_skus VALUES(49,5,11,303,'2026-07-31 12:39:41.892700',50);
INSERT INTO product_skus VALUES(50,5,14,286,'2026-07-31 12:39:41.893471',50);
INSERT INTO product_skus VALUES(51,5,12,487,'2026-07-31 12:39:41.894231',50);
INSERT INTO product_skus VALUES(52,5,15,377,'2026-07-31 12:39:41.894990',50);
INSERT INTO product_skus VALUES(53,6,3,102,'2026-07-31 12:39:41.896059',50);
INSERT INTO product_skus VALUES(54,6,1,69,'2026-07-31 12:39:41.896817',50);
INSERT INTO product_skus VALUES(55,7,1,236,'2026-07-31 12:39:41.897840',50);
INSERT INTO product_skus VALUES(56,8,1,218,'2026-07-31 12:39:41.899109',50);
INSERT INTO product_skus VALUES(57,8,5,94,'2026-07-31 12:39:41.899877',50);
INSERT INTO product_skus VALUES(58,9,1,156,'2026-07-31 12:39:41.900930',50);
INSERT INTO product_skus VALUES(59,10,1,210,'2026-07-31 12:39:41.901948',50);
INSERT INTO product_skus VALUES(60,11,16,1,'2026-07-31 12:39:41.902959',50);
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
INSERT INTO transactions VALUES(1,'2026-07-31','入库',21,10,0,0,NULL,'','2026-07-31 17:00:51.082450');
INSERT INTO transactions VALUES(2,'2026-07-31','出库',21,5,46,230,NULL,'','2026-07-31 17:01:19.000887');
INSERT INTO transactions VALUES(3,'2026-07-31','出库',21,3,46,138,1,'','2026-07-31 17:02:48.375437');
INSERT INTO transactions VALUES(4,'2026-08-01','出库',1,40,40,1600,1,'','2026-08-01 10:56:20.866789');
INSERT INTO transactions VALUES(5,'2026-08-01','入库',1,20,0,0,2,'','2026-08-01 11:07:01.729167');
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
INSERT INTO inventory_logs VALUES(1,21,1,10,1008,1018,'2026-07-31 17:00:51.085379');
INSERT INTO inventory_logs VALUES(2,21,2,-5,1018,1013,'2026-07-31 17:01:19.003552');
INSERT INTO inventory_logs VALUES(3,21,3,-3,1013,1010,'2026-07-31 17:02:48.377407');
INSERT INTO inventory_logs VALUES(4,1,4,-40,1870,1830,'2026-08-01 10:56:20.870354');
INSERT INTO inventory_logs VALUES(5,1,5,20,1870,1890,'2026-08-01 11:07:01.731603');
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
