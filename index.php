<?php
/**
 * WMS 进销存系统 — 前端入口
 * 所有非 /api/ 请求返回 Vue SPA 页面
 */
// 如果是 /api/ 请求但没有被 .htaccess 正确路由，返回 404
if (str_starts_with($_SERVER['REQUEST_URI'], '/api/')) {
    http_response_code(404);
    header('Content-Type: application/json');
    echo json_encode(['detail' => 'API Not Found'], JSON_UNESCAPED_UNICODE);
    exit;
}

// 返回前端 SPA
readfile(__DIR__ . '/static/index.html');
