<?php
/**
 * 认证工具
 *
 * 简化版：使用 JWT（HMAC-SHA256）
 * 生产环境建议使用 firebase/php-jwt 库
 */
class Auth
{
    private static array $config = [];

    public static function init(): void
    {
        if (empty(self::$config)) {
            self::$config = require __DIR__ . '/../config.php';
        }
    }

    /**
     * 生成 JWT Token
     */
    public static function generateToken(array $payload): string
    {
        self::init();
        $header = self::base64UrlEncode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));

        $payload['iat'] = time();
        $payload['exp'] = time() + self::$config['jwt_expire'];
        $payloadEncoded = self::base64UrlEncode(json_encode($payload));

        $signature = self::base64UrlEncode(
            hash_hmac('sha256', "$header.$payloadEncoded", self::$config['jwt_secret'], true)
        );

        return "$header.$payloadEncoded.$signature";
    }

    /**
     * 验证 Token，返回 payload 或 null
     */
    public static function verifyToken(string $token): ?array
    {
        self::init();
        $parts = explode('.', $token);
        if (count($parts) !== 3) return null;

        [$header, $payload, $signature] = $parts;

        $validSig = self::base64UrlEncode(
            hash_hmac('sha256', "$header.$payload", self::$config['jwt_secret'], true)
        );

        if (!hash_equals($validSig, $signature)) return null;

        $data = json_decode(self::base64UrlDecode($payload), true);
        if (!$data || ($data['exp'] ?? 0) < time()) return null;

        return $data;
    }

    /**
     * 从请求头获取当前用户
     */
    public static function user(): ?array
    {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        if (!preg_match('/^Bearer\s+(.+)$/i', $header, $m)) return null;

        return self::verifyToken($m[1]);
    }

    /**
     * 要求登录，未登录直接返回 401
     */
    public static function require(): array
    {
        $user = self::user();
        if (!$user) {
            Response::error('请先登录', 401);
        }
        return $user;
    }

    private static function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $data): string
    {
        return base64_decode(strtr($data, '-_', '+/'));
    }
}
