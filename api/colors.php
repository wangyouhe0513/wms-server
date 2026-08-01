<?php
// 颜色 CRUD: GET/POST /api/colors, PUT/DELETE /api/colors/{id}
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';

$db = Database::getInstance();
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($method === 'GET' && $path === '/api/colors') {
    $rows = $db->query('SELECT id, name, code FROM colors WHERE is_active = 1 ORDER BY sort_order, id')->fetchAll();
    Response::json($rows);
}

if ($method === 'POST' && $path === '/api/colors') {
    $user = Auth::require();
    $name = $_GET['name'] ?? '';
    $code = $_GET['code'] ?? '';
    if (!$name) Response::error('名称不能为空');

    $existing = $db->prepare('SELECT id, is_active FROM colors WHERE name = ?');
    $existing->execute([$name]);
    $row = $existing->fetch();

    if ($row) {
        if ($row['is_active'] == 0) {
            $db->prepare('UPDATE colors SET is_active = 1 WHERE id = ?')->execute([$row['id']]);
            $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
               ->execute([$user['admin_id'], $user['username'], 'create', 'color', "重新激活颜色: $name"]);
            Response::json(['id' => (int)$row['id'], 'name' => $name, 'reactivated' => true]);
        }
        Response::error('颜色已存在');
    }

    $maxSort = $db->query('SELECT COALESCE(MAX(sort_order),0) FROM colors')->fetchColumn();
    $db->prepare('INSERT INTO colors (name, code, sort_order) VALUES (?, ?, ?)')->execute([$name, $code, $maxSort + 1]);
    $id = $db->lastInsertId();
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'create', 'color', "创建颜色: $name"]);
    Response::json(['id' => (int)$id, 'name' => $name]);
}

if ($method === 'PUT' && preg_match('#/api/colors/(\d+)$#', $path, $m)) {
    $user = Auth::require();
    $id = (int)$m[1];
    $name = $_GET['name'] ?? '';
    $code = $_GET['code'] ?? '';
    $row = $db->prepare('SELECT * FROM colors WHERE id = ?'); $row->execute([$id]); $c = $row->fetch();
    if (!$c) Response::error('颜色不存在', 404);
    $old = $c['name'];
    $db->prepare('UPDATE colors SET name = ?, code = ? WHERE id = ?')->execute([$name, $code, $id]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'update', 'color', "修改颜色: $old -> $name"]);
    Response::json(['ok' => true]);
}

if ($method === 'DELETE' && preg_match('#/api/colors/(\d+)$#', $path, $m)) {
    $user = Auth::require();
    $id = (int)$m[1];
    $row = $db->prepare('SELECT * FROM colors WHERE id = ?'); $row->execute([$id]); $c = $row->fetch();
    if (!$c) Response::error('颜色不存在', 404);

    $stock = $db->prepare('SELECT 1 FROM product_skus WHERE color_id = ? AND current_stock > 0 LIMIT 1');
    $stock->execute([$id]);
    if ($stock->fetch()) Response::error("颜色「{$c['name']}」下还有库存，不能删除");

    $txn = $db->prepare('SELECT 1 FROM transactions t JOIN product_skus s ON t.sku_id = s.id WHERE s.color_id = ? LIMIT 1');
    $txn->execute([$id]);
    if ($txn->fetch()) Response::error("颜色「{$c['name']}」下有交易记录，不能删除");

    $db->prepare('UPDATE colors SET is_active = 0 WHERE id = ?')->execute([$id]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'delete', 'color', "删除颜色: {$c['name']}"]);
    Response::json(['ok' => true]);
}

Response::error('Not Found', 404);
