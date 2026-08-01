<?php
/**
 * 认证 API
 * POST /api/auth/login     — 登录
 * POST /api/auth/logout    — 登出
 * PUT  /api/auth/change-password — 修改密码
 */
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';

$method = $_SERVER['REQUEST_METHOD'];
$uri = $_SERVER['REQUEST_URI'];
$path = parse_url($uri, PHP_URL_PATH);
$db = Database::getInstance();

// 登录
if ($method === 'POST' && str_ends_with($path, '/api/auth/login')) {
    $body = json_decode(file_get_contents('php://input'), true);
    $username = $body['username'] ?? '';
    $password = $body['password'] ?? '';
    if (!$username || !$password) Response::error('用户名和密码不能为空');

    $stmt = $db->prepare('SELECT id, username, password_hash, role FROM admins WHERE username = ? AND is_active = 1');
    $stmt->execute([$username]);
    $admin = $stmt->fetch();
    if (!$admin || hash('sha256', $password) !== $admin['password_hash']) Response::error('用户名或密码错误', 401);

    $token = Auth::generateToken(['admin_id' => $admin['id'], 'username' => $admin['username'], 'role' => $admin['role']]);
    $db->prepare('UPDATE admins SET last_login = NOW() WHERE id = ?')->execute([$admin['id']]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail, ip_address) VALUES (?,?,?,?,?,?)')
       ->execute([$admin['id'], $admin['username'], 'login', 'auth', '管理员登录', $_SERVER['REMOTE_ADDR'] ?? '']);

    Response::json(['token' => $token, 'username' => $admin['username'], 'role' => $admin['role']]);
}

// 登出
if ($method === 'POST' && str_ends_with($path, '/api/auth/logout')) {
    $user = Auth::require();
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail, ip_address) VALUES (?,?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'logout', 'auth', '管理员登出', $_SERVER['REMOTE_ADDR'] ?? '']);
    Response::json(['ok' => true]);
}

// 修改密码
if ($method === 'PUT' && str_ends_with($path, '/api/auth/change-password')) {
    $user = Auth::require();
    $old = $_GET['old_password'] ?? '';
    $new = $_GET['new_password'] ?? '';

    $stmt = $db->prepare('SELECT password_hash FROM admins WHERE id = ?');
    $stmt->execute([$user['admin_id']]);
    $admin = $stmt->fetch();
    if (hash('sha256', $old) !== $admin['password_hash']) Response::error('原密码错误');

    $db->prepare('UPDATE admins SET password_hash = ? WHERE id = ?')->execute([hash('sha256', $new), $user['admin_id']]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'update', 'auth', '修改密码']);
    Response::json(['ok' => true]);
}

Response::error('Not Found', 404);
