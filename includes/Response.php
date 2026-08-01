<?php
/**
 * JSON 响应 — 匹配 Python FastAPI 格式
 * 成功: 直接返回数据
 * 错误: {"detail": "error message"} + HTTP 错误码
 */
class Response
{
    public static function json(mixed $data, int $code = 200): never
    {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function error(string $message, int $code = 400): never
    {
        self::json(['detail' => $message], $code);
    }
}
