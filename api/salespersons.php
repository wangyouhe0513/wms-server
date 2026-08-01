<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $method = $_SERVER['REQUEST_METHOD']; $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($method === 'GET' && $path === '/api/salespersons') {
    $rows = $db->query('SELECT id, name, type FROM salespersons WHERE is_active = 1 ORDER BY id')->fetchAll();
    Response::json($rows);
}
if ($method === 'POST' && $path === '/api/salespersons') {
    $user = Auth::require(); $name = $_GET['name'] ?? ''; $sp_type = $_GET['sp_type'] ?? '员工';
    if (!$name) Response::error('名称不能为空');
    $ex = $db->prepare('SELECT id, is_active FROM salespersons WHERE name = ?'); $ex->execute([$name]); $r = $ex->fetch();
    if ($r) {
        if ($r['is_active']==0) { $db->prepare('UPDATE salespersons SET is_active=1 WHERE id=?')->execute([$r['id']]); Response::json(['id'=>(int)$r['id'],'name'=>$name,'reactivated'=>true]); }
        Response::error('销售人员已存在');
    }
    $db->prepare('INSERT INTO salespersons (name, type) VALUES (?,?)')->execute([$name, $sp_type]);
    $id = $db->lastInsertId();
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'create', 'salesperson', "创建人员: $name"]);
    Response::json(['id'=>(int)$id,'name'=>$name]);
}
if ($method === 'DELETE' && preg_match('#/api/salespersons/(\d+)$#', $path, $m)) {
    $user = Auth::require(); $id = (int)$m[1];
    $sp = $db->prepare('SELECT * FROM salespersons WHERE id=?'); $sp->execute([$id]); $s = $sp->fetch();
    if (!$s) Response::error('人员不存在', 404);
    $db->prepare('UPDATE salespersons SET is_active=0 WHERE id=?')->execute([$id]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'delete', 'salesperson', "删除人员: {$s['name']}"]);
    Response::json(['ok'=>true]);
}
Response::error('Not Found', 404);
