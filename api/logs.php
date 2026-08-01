<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($_SERVER['REQUEST_METHOD'] === 'GET' && str_ends_with($path, '/api/logs')) {
    Auth::require();
    $limit = (int)($_GET['limit'] ?? 200);
    $stmt = $db->prepare('SELECT id, admin_name, action, target, detail, created_at FROM operation_logs ORDER BY created_at DESC LIMIT ?');
    $stmt->execute([$limit]);
    Response::json($stmt->fetchAll());
}
Response::error('Not Found', 404);
