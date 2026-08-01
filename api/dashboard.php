<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance();

$today = date('Y-m-d');
$todayRows = $db->prepare('SELECT trans_type, quantity, amount FROM transactions WHERE trans_date = ?');
$todayRows->execute([$today]); $todayAll = $todayRows->fetchAll();

$todayOut = 0; $todayIn = 0;
foreach ($todayAll as $t) {
    if ($t['trans_type'] === '出库') $todayOut += (float)$t['amount'];
    else $todayIn += (int)$t['quantity'];
}

$monthStart = date('Y-m-01');
$monthTotal = $db->prepare("SELECT COALESCE(SUM(amount),0) as total FROM transactions WHERE trans_type='出库' AND trans_date >= ? AND trans_date <= ?");
$monthTotal->execute([$monthStart, $today]);

$th = $db->query("SELECT value FROM system_configs WHERE `key`='low_stock_threshold'")->fetch();
$defTh = $th ? (int)$th['value'] : 50;
$lowStock = $db->prepare('SELECT COUNT(*) as cnt FROM product_skus s JOIN product_specs ps ON s.spec_id=ps.id AND ps.is_active=1 JOIN colors c ON s.color_id=c.id AND c.is_active=1 WHERE s.current_stock < COALESCE(s.low_stock_threshold, ?)');
$lowStock->execute([$defTh]);

$totalSpecs = $db->query('SELECT COUNT(*) FROM product_specs WHERE is_active=1')->fetchColumn();
$totalColors = $db->query('SELECT COUNT(*) FROM colors WHERE is_active=1')->fetchColumn();

Response::json([
    'today_out_amount' => $todayOut,
    'today_in_qty' => $todayIn,
    'month_total' => (float)$monthTotal->fetchColumn(),
    'low_stock_count' => (int)$lowStock->fetchColumn(),
    'total_specs' => (int)$totalSpecs,
    'total_colors' => (int)$totalColors,
]);
