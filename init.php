<?php
/**
 * 初始化脚本
 *
 * 使用方法: php init.php
 *
 * 功能:
 *   1. 创建数据库和表结构（如果未创建）
 *   2. 初始化管理员密码
 *   3. 插入默认仓库
 */

require __DIR__ . '/includes/Database.php';

echo "==================================\n";
echo "  财务仓储系统 - 初始化\n";
echo "==================================\n\n";

// ── 1. 创建数据库 ──
$config = require __DIR__ . '/config.php';
$db = $config['db'];

try {
    $dsn = sprintf('mysql:host=%s;port=%d;charset=%s', $db['host'], $db['port'], $db['charset']);
    $pdo = new PDO($dsn, $db['username'], $db['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
    echo "[OK] 数据库连接成功\n";

    // 创建数据库
    $pdo->exec("CREATE DATABASE IF NOT EXISTS `{$db['dbname']}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    echo "[OK] 数据库 `{$db['dbname']}` 已就绪\n";

    // 选择数据库
    $pdo->exec("USE `{$db['dbname']}`");

    // 导入 SQL
    $sqlFile = __DIR__ . '/../wms_finance.sql';
    if (file_exists($sqlFile)) {
        $sql = file_get_contents($sqlFile);
        // 执行 SQL（分句执行，跳过注释和空行）
        $pdo->exec($sql);
        echo "[OK] 表结构导入完成\n";
    } else {
        echo "[WARN] 未找到 wms_finance.sql，跳过表结构导入\n";
    }

} catch (PDOException $e) {
    echo "[ERROR] 数据库操作失败: " . $e->getMessage() . "\n";
    exit(1);
}

// ── 2. 初始化管理员密码 ──
echo "\n--- 管理员设置 ---\n";
echo "请输入管理员账号 [默认: admin]: ";
$username = trim(fgets(STDIN)) ?: 'admin';

echo "请输入管理员密码: ";
system('stty -echo');
$password = trim(fgets(STDIN));
system('stty echo');
echo "\n";

if (empty($password)) {
    echo "[ERROR] 密码不能为空\n";
    exit(1);
}

$passwordHash = password_hash($password, PASSWORD_BCRYPT);

// 更新或插入管理员
$stmt = $pdo->prepare('SELECT id FROM admin WHERE username = ?');
$stmt->execute([$username]);
if ($stmt->fetch()) {
    $pdo->prepare('UPDATE admin SET password_hash = ?, status = 1 WHERE username = ?')
        ->execute([$passwordHash, $username]);
    echo "[OK] 管理员 `{$username}` 密码已更新\n";
} else {
    $pdo->prepare('INSERT INTO admin (username, password_hash, real_name, role) VALUES (?, ?, ?, ?)')
        ->execute([$username, $passwordHash, '系统管理员', 'super_admin']);
    echo "[OK] 管理员 `{$username}` 已创建\n";
}

// ── 3. 确保默认仓库存在 ──
$stmt = $pdo->query('SELECT COUNT(*) FROM warehouse');
if ((int)$stmt->fetchColumn() === 0) {
    $pdo->exec("INSERT INTO warehouse (warehouse_name, warehouse_code) VALUES ('默认仓库', 'WH-001')");
    echo "[OK] 默认仓库已创建\n";
}

echo "\n==================================\n";
echo "  初始化完成！\n";
echo "  启动服务: php -S 0.0.0.0:8080 -t " . __DIR__ . "\n";
echo "==================================\n";
