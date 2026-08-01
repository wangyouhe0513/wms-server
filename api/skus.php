<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $method = $_SERVER['REQUEST_METHOD']; $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

$th = $db->query("SELECT value FROM system_configs WHERE `key`='low_stock_threshold'")->fetch();
$defTh = $th ? (int)$th['value'] : 50;

// GET /api/skus
if ($method === 'GET' && $path === '/api/skus') {
    $rows = $db->query("SELECT s.id as sku_id, s.spec_id, ps.name as spec_name, s.color_id, c.name as color_name,
        s.current_stock, s.low_stock_threshold
        FROM product_skus s JOIN product_specs ps ON s.spec_id=ps.id AND ps.is_active=1
        JOIN colors c ON s.color_id=c.id AND c.is_active=1 ORDER BY ps.sort_order, ps.id, c.sort_order, c.id")->fetchAll();
    $result = [];
    foreach ($rows as $r) {
        $thVal = (int)($r['low_stock_threshold'] ?? 0);
        $result[] = ['sku_id'=>(int)$r['sku_id'],'spec_id'=>(int)$r['spec_id'],'spec_name'=>$r['spec_name'],
            'color_id'=>(int)$r['color_id'],'color_name'=>$r['color_name'],'current_stock'=>(int)$r['current_stock'],
            'threshold'=>($thVal > 0 ? $thVal : $defTh),'is_custom'=>($thVal > 0)];
    }
    Response::json($result);
}

// PUT /api/skus/{id}/threshold
if ($method === 'PUT' && preg_match('#/api/skus/(\d+)/threshold$#', $path, $m)) {
    $user = Auth::require(); $id = (int)$m[1]; $threshold = (int)($_GET['threshold'] ?? 50);
    $sku = $db->prepare('SELECT s.id, ps.name as spec, c.name as color FROM product_skus s JOIN product_specs ps ON s.spec_id=ps.id JOIN colors c ON s.color_id=c.id WHERE s.id=?');
    $sku->execute([$id]); $s = $sku->fetch();
    if (!$s) Response::error('SKU 不存在', 404);
    $db->prepare('UPDATE product_skus SET low_stock_threshold = ? WHERE id = ?')->execute([$threshold, $id]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'update', 'threshold', "SKU {$s['spec']}-{$s['color']} 阈值设为 $threshold"]);
    Response::json(['ok'=>true,'sku_id'=>$id,'threshold'=>$threshold]);
}
Response::error('Not Found', 404);
