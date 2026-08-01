<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $method = $_SERVER['REQUEST_METHOD']; $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($method === 'GET' && $path === '/api/admins') {
    $user = Auth::require(); if ($user['role'] !== 'superadmin') Response::error('权限不足', 403);
    $rows = $db->query('SELECT id, username, role, is_active, last_login, created_at FROM admins ORDER BY id')->fetchAll();
    Response::json($rows);
}
if ($method === 'POST' && $path === '/api/admins') {
    $user = Auth::require(); if ($user['role'] !== 'superadmin') Response::error('权限不足', 403);
    $body = json_decode(file_get_contents('php://input'), true);
    $username = $body['username'] ?? ''; $password = $body['password'] ?? '';
    if (!$username || !$password) Response::error('用户名和密码不能为空');
    $ex = $db->prepare('SELECT id, is_active FROM admins WHERE username=?'); $ex->execute([$username]); $r = $ex->fetch();
    if ($r) {
        if ($r['is_active']==0) { $db->prepare('UPDATE admins SET is_active=1, password_hash=? WHERE id=?')->execute([hash('sha256',$password),$r['id']]); Response::json(['ok'=>true,'reactivated'=>true]); }
        Response::error('管理员已存在');
    }
    $db->prepare('INSERT INTO admins (username, password_hash, role) VALUES (?,?,?)')->execute([$username, hash('sha256',$password), 'admin']);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'create', 'admin', "创建管理员: $username"]);
    Response::json(['ok'=>true]);
}
if ($method === 'PUT' && preg_match('#/api/admins/(\d+)/password$#', $path, $m)) {
    $user = Auth::require(); if ($user['role'] !== 'superadmin') Response::error('权限不足', 403);
    $body = json_decode(file_get_contents('php://input'), true); $pwd = $body['password'] ?? '';
    if (!$pwd) Response::error('密码不能为空');
    $t = $db->prepare('SELECT username FROM admins WHERE id=?'); $t->execute([(int)$m[1]]); $target = $t->fetch();
    if (!$target) Response::error('管理员不存在', 404);
    $db->prepare('UPDATE admins SET password_hash=? WHERE id=?')->execute([hash('sha256',$pwd),(int)$m[1]]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'update', 'admin', "重置密码: {$target['username']}"]);
    Response::json(['ok'=>true]);
}
if ($method === 'DELETE' && preg_match('#/api/admins/(\d+)$#', $path, $m)) {
    $user = Auth::require(); if ($user['role'] !== 'superadmin') Response::error('权限不足', 403);
    $id = (int)$m[1];
    $t = $db->prepare('SELECT username FROM admins WHERE id=?'); $t->execute([$id]); $target = $t->fetch();
    if (!$target) Response::error('管理员不存在', 404);
    $db->prepare('UPDATE admins SET is_active=0 WHERE id=?')->execute([$id]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'delete', 'admin', "删除管理员: {$target['username']}"]);
    Response::json(['ok'=>true]);
}
Response::error('Not Found', 404);
