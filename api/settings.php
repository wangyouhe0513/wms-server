<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $method = $_SERVER['REQUEST_METHOD']; $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// GET /api/settings
if ($method === 'GET' && $path === '/api/settings') {
    $th = $db->query("SELECT value FROM system_configs WHERE `key`='low_stock_threshold'")->fetch();
    Response::json(['low_stock_threshold' => $th ? (int)$th['value'] : 50]);
}

// PUT /api/settings
if ($method === 'PUT' && $path === '/api/settings') {
    $user = Auth::require();
    $threshold = (int)($_GET['threshold'] ?? 50);
    if ($threshold < 0) Response::error('阈值不能为负数');

    $exists = $db->query("SELECT 1 FROM system_configs WHERE `key`='low_stock_threshold'")->fetch();
    if ($exists) {
        $db->prepare("UPDATE system_configs SET value = ?, updated_at = NOW() WHERE `key`='low_stock_threshold'")->execute([(string)$threshold]);
    } else {
        $db->prepare("INSERT INTO system_configs (`key`, value) VALUES ('low_stock_threshold', ?)")->execute([(string)$threshold]);
    }
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'update', 'settings', "全局默认低库存阈值设为 $threshold"]);
    Response::json(['ok'=>true,'low_stock_threshold'=>$threshold]);
}
Response::error('Not Found', 404);
