-- WMS SQLite -> MySQL
USE wms_finance;

-- product_specs (17 rows)
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (1, '6094', 2, 1, '2026-08-01 14:28:59.772517');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (2, 'A款', 9, 1, '2026-08-01 14:28:59.773030');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (3, 'B款', 10, 1, '2026-08-01 14:28:59.773196');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (4, '儿童6094', 5, 1, '2026-08-01 14:28:59.773342');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (5, '儿童印花款', 15, 1, '2026-08-01 14:28:59.773480');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (6, '儿童钢丝', 8, 1, '2026-08-01 14:28:59.773614');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (7, '儿网背心', 16, 1, '2026-08-01 14:28:59.773747');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (8, '八包', 11, 1, '2026-08-01 14:28:59.773877');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (9, '包边', 12, 1, '2026-08-01 14:28:59.774007');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (10, '小三连', 13, 1, '2026-08-01 14:28:59.774138');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (11, '无钢丝', 3, 1, '2026-08-01 14:28:59.774266');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (12, '纲八', 6, 1, '2026-08-01 14:28:59.774395');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (13, '网背心', 1, 1, '2026-08-01 14:28:59.774524');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (14, '腰带', 14, 1, '2026-08-01 14:28:59.774651');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (15, '钢丝', 4, 1, '2026-08-01 14:28:59.774779');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (16, '黑鹰', 7, 1, '2026-08-01 14:28:59.774907');
INSERT IGNORE INTO product_specs (id, name, sort_order, is_active, created_at) VALUES (17, '三连包', 0, 1, '2026-08-01 20:33:37.323383');

-- colors (19 rows)
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (1, 'acu', NULL, 6, 1, '2026-08-01 14:28:59.775857');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (2, 'cp', NULL, 5, 1, '2026-08-01 14:28:59.775858');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (4, 'l/xl', NULL, 19, 1, '2026-08-01 14:28:59.775859');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (5, 's/m', NULL, 18, 1, '2026-08-01 14:28:59.775860');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (6, '俄', NULL, 10, 1, '2026-08-01 14:28:59.775861');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (7, '卡其', NULL, 4, 1, '2026-08-01 14:28:59.775861');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (8, '女', NULL, 16, 1, '2026-08-01 14:28:59.775862');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (9, '废墟', NULL, 12, 1, '2026-08-01 14:28:59.775863');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (10, '数码', NULL, 9, 1, '2026-08-01 14:28:59.775863');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (11, '男', NULL, 15, 1, '2026-08-01 14:28:59.775864');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (12, '绿', NULL, 3, 1, '2026-08-01 14:28:59.775865');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (13, '绿大花', NULL, 14, 1, '2026-08-01 14:28:59.775865');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (14, '荒漠数码', NULL, 17, 1, '2026-08-01 14:28:59.775866');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (15, '黄数码', NULL, 13, 1, '2026-08-01 14:28:59.775866');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (16, '黄蟒纹', NULL, 11, 1, '2026-08-01 14:28:59.775867');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (17, '黑', NULL, 1, 1, '2026-08-01 14:28:59.775868');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (19, '黑cp', NULL, 7, 1, '2026-08-01 14:28:59.775869');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (20, '黑中号', NULL, 2, 1, '2026-08-01 14:28:59.775870');
INSERT IGNORE INTO colors (id, name, code, sort_order, is_active, created_at) VALUES (21, '黑蟒纹', NULL, 8, 1, '2026-08-01 14:28:59.775870');

-- product_skus (66 rows)
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (1, 13, 17, 1714, '2026-08-01 14:49:09.865349', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (2, 13, 20, 3, '2026-08-01 14:49:09.865357', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (3, 13, 12, 215, '2026-08-01 14:49:09.865358', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (4, 13, 7, 824, '2026-08-01 14:49:09.865358', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (5, 13, 2, 598, '2026-08-01 14:49:09.865359', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (6, 13, 1, 470, '2026-08-01 14:49:09.865362', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (7, 13, 19, 595, '2026-08-01 14:49:09.865362', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (8, 1, 17, 1017, '2026-08-01 14:49:09.865363', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (9, 1, 12, 396, '2026-08-01 14:49:09.865363', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (10, 1, 7, 374, '2026-08-01 14:49:09.865364', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (11, 1, 2, 375, '2026-08-01 14:49:09.865365', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (12, 1, 21, 218, '2026-08-01 14:49:09.865365', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (13, 1, 1, 214, '2026-08-01 14:49:09.865366', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (14, 1, 19, 129, '2026-08-01 14:49:09.865366', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (15, 1, 10, 178, '2026-08-01 14:49:09.865367', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (16, 1, 6, 242, '2026-08-01 14:49:09.865367', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (17, 1, 16, 49, '2026-08-01 14:49:09.865368', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (18, 1, 9, 150, '2026-08-01 14:49:09.865368', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (19, 11, 17, 590, '2026-08-01 14:49:09.865369', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (20, 11, 12, 161, '2026-08-01 14:49:09.865369', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (21, 11, 7, 543, '2026-08-01 14:49:09.865370', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (22, 11, 2, 45, '2026-08-01 14:49:09.865370', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (23, 11, 1, 195, '2026-08-01 14:49:09.865371', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (24, 11, 19, 0, '2026-08-01 14:49:09.865371', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (25, 15, 17, 436, '2026-08-01 14:49:09.865372', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (26, 15, 12, 43, '2026-08-01 14:49:09.865372', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (27, 15, 7, 147, '2026-08-01 14:49:09.865373', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (28, 15, 2, 200, '2026-08-01 14:49:09.865373', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (29, 4, 17, 845, '2026-08-01 14:49:09.865374', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (30, 4, 19, 565, '2026-08-01 14:49:09.865374', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (31, 4, 2, 903, '2026-08-01 14:49:09.865375', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (32, 4, 9, 407, '2026-08-01 14:49:09.865375', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (33, 4, 1, 509, '2026-08-01 14:49:09.865376', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (34, 4, 7, 698, '2026-08-01 14:49:09.865376', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (35, 4, 21, 157, '2026-08-01 14:49:09.865377', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (36, 4, 12, 637, '2026-08-01 14:49:09.865377', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (37, 4, 6, 276, '2026-08-01 14:49:09.865378', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (38, 4, 15, 241, '2026-08-01 14:49:09.865378', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (39, 4, 16, 406, '2026-08-01 14:49:09.865379', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (40, 4, 13, 345, '2026-08-01 14:49:09.865379', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (41, 12, 12, 102, '2026-08-01 14:49:09.865380', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (42, 12, 17, 68, '2026-08-01 14:49:09.865380', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (43, 16, 17, 89, '2026-08-01 14:49:09.865381', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (44, 6, 17, 218, '2026-08-01 14:49:09.865381', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (45, 6, 2, 64, '2026-08-01 14:49:09.865382', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (46, 2, 17, 155, '2026-08-01 14:49:09.865382', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (47, 3, 17, 205, '2026-08-01 14:49:09.865383', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (48, 8, 11, 1, '2026-08-01 14:49:09.865383', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (49, 8, 8, 0, '2026-08-01 14:49:09.865384', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (50, 9, 17, 157, '2026-08-01 14:49:09.865384', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (51, 9, 2, 1516, '2026-08-01 14:49:09.865385', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (52, 9, 19, 1620, '2026-08-01 14:49:09.865385', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (53, 9, 21, 50, '2026-08-01 14:49:09.865386', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (54, 9, 14, 158, '2026-08-01 14:49:09.865386', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (55, 9, 1, 55, '2026-08-01 14:49:09.865387', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (56, 9, 16, 121, '2026-08-01 14:49:09.865387', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (57, 10, 17, 415, '2026-08-01 14:49:09.865388', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (58, 14, 17, 0, '2026-08-01 14:49:09.865388', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (59, 14, 2, 0, '2026-08-01 14:49:09.865389', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (60, 14, 7, 0, '2026-08-01 14:49:09.865389', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (61, 14, 12, 0, '2026-08-01 14:49:09.865390', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (62, 5, 5, 0, '2026-08-01 14:49:09.865390', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (63, 5, 4, 0, '2026-08-01 14:49:09.865391', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (64, 7, 17, 0, '2026-08-01 14:49:09.865391', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (65, 1, 13, 10, '2026-08-01 17:47:38.717759', 50);
INSERT IGNORE INTO product_skus (id, spec_id, color_id, current_stock, created_at, low_stock_threshold) VALUES (66, 15, 9, 164, '2026-08-01 17:47:38.725612', 50);

-- salespersons (2 rows)
INSERT IGNORE INTO salespersons (id, name, type, is_active, created_at) VALUES (1, '王河', '员工', 1, '2026-07-31 12:59:10.686729');
INSERT IGNORE INTO salespersons (id, name, type, is_active, created_at) VALUES (2, 'admin', '员工', 1, '2026-08-01 11:03:20.112900');

-- admins (1 rows)
INSERT IGNORE INTO admins (id, username, password_hash, role, is_active, created_at, last_login) VALUES (1, 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'superadmin', 1, '2026-07-31 13:04:50.769347', '2026-08-01 20:32:12.832679');

-- system_configs (1 rows)
INSERT IGNORE INTO system_configs (id, key, value, updated_at) VALUES (1, 'low_stock_threshold', '50', '2026-08-01 10:39:39.219358');

-- transactions (2 rows)
INSERT IGNORE INTO transactions (id, trans_date, trans_type, sku_id, quantity, unit_price, amount, salesperson_id, remark, created_at, entry_person) VALUES (1, '2026-08-01', '出库', 1, 1, 40, 40, 1, '', '2026-08-01 21:02:53.331914', 'admin');
INSERT IGNORE INTO transactions (id, trans_date, trans_type, sku_id, quantity, unit_price, amount, salesperson_id, remark, created_at, entry_person) VALUES (2, '2026-08-01', '出库', 10, 1, 80, 80, 1, '', '2026-08-01 21:02:53.337163', 'admin');

-- inventory_logs (2 rows)
INSERT IGNORE INTO inventory_logs (id, sku_id, transaction_id, change_qty, before_stock, after_stock, created_at) VALUES (1, 1, 1, -1, 1715, 1714, '2026-08-01 21:02:53.337015');
INSERT IGNORE INTO inventory_logs (id, sku_id, transaction_id, change_qty, before_stock, after_stock, created_at) VALUES (2, 10, 2, -1, 375, 374, '2026-08-01 21:02:53.337917');
