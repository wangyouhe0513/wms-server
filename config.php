<?php
/**
 * 系统配置文件
 */
return [
    'db' => [
        'host'     => '127.0.0.1',
        'port'     => 3306,
        'dbname'   => 'wms_finance',
        'username' => 'root',
        'password' => '',
        'charset'  => 'utf8mb4',
    ],
    'jwt_secret' => 'your-secret-key-change-in-production',
    'jwt_expire' => 86400, // token 有效期 24 小时
];
