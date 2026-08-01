<?php
// 规格 CRUD: GET/POST /api/specs, PUT/DELETE /api/specs/{id}
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';

$db = Database::getInstance();
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// GET /api/specs
if ($method === 'GET' && $path === '/api/specs') {
    $rows = $db->query('SELECT id, name, sort_order FROM product_specs WHERE is_active = 1 ORDER BY sort_order, id')->fetchAll();
    Response::json($rows);
}

// POST /api/specs
if ($method === 'POST' && $path === '/api/specs') {
    $user = Auth::require();
    $name = $_GET['name'] ?? '';
    if (!$name) Response::error('名称不能为空');

    $existing = $db->prepare('SELECT id, is_active FROM product_specs WHERE name = ?');
    $existing->execute([$name]);
    $row = $existing->fetch();

    if ($row) {
        if ($row['is_active'] == 0) {
            $db->prepare('UPDATE product_specs SET is_active = 1 WHERE id = ?')->execute([$row['id']]);
            $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
               ->execute([$user['admin_id'], $user['username'], 'create', 'spec', "重新激活规格: $name"]);
            Response::json(['id' => (int)$row['id'], 'name' => $name, 'reactivated' => true]);
        }
        Response::error('规格已存在');
    }

    $maxSort = $db->query('SELECT COALESCE(MAX(sort_order),0) FROM product_specs')->fetchColumn();
    $db->prepare('INSERT INTO product_specs (name, sort_order) VALUES (?, ?)')->execute([$name, $maxSort + 1]);
    $id = $db->lastInsertId();
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'create', 'spec', "创建规格: $name"]);
    Response::json(['id' => (int)$id, 'name' => $name]);
}

// PUT /api/specs/{id}
if ($method === 'PUT' && preg_match('#/api/specs/(\d+)$#', $path, $m)) {
    $user = Auth::require();
    $id = (int)$m[1];
    $name = $_GET['name'] ?? '';
    $spec = $db->prepare('SELECT * FROM product_specs WHERE id = ?');
    $spec->execute([$id]);
    $row = $spec->fetch();
    if (!$row) Response::error('规格不存在', 404);
    $old = $row['name'];
    $db->prepare('UPDATE product_specs SET name = ? WHERE id = ?')->execute([$name, $id]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'update', 'spec', "修改规格: $old -> $name"]);
    Response::json(['ok' => true]);
}

// DELETE /api/specs/{id}
if ($method === 'DELETE' && preg_match('#/api/specs/(\d+)$#', $path, $m)) {
    $user = Auth::require();
    $id = (int)$m[1];
    $spec = $db->prepare('SELECT * FROM product_specs WHERE id = ?');
    $spec->execute([$id]);
    $row = $spec->fetch();
    if (!$row) Response::error('规格不存在', 404);

    // 检查库存
    $stock = $db->prepare('SELECT 1 FROM product_skus WHERE spec_id = ? AND current_stock > 0 LIMIT 1');
    $stock->execute([$id]);
    if ($stock->fetch()) Response::error("规格「{$row['name']}」下还有库存，不能删除");

    // 检查交易记录
    $txn = $db->prepare('SELECT 1 FROM transactions t JOIN product_skus s ON t.sku_id = s.id WHERE s.spec_id = ? LIMIT 1');
    $txn->execute([$id]);
    if ($txn->fetch()) Response::error("规格「{$row['name']}」下有交易记录，不能删除");

    $db->prepare('UPDATE product_specs SET is_active = 0 WHERE id = ?')->execute([$id]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'delete', 'spec', "删除规格: {$row['name']}"]);
    Response::json(['ok' => true]);
}

Response::error('Not Found', 404);
