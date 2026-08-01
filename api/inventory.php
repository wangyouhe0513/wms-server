<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $method = $_SERVER['REQUEST_METHOD']; $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// 获取全局阈值
$th = $db->query("SELECT value FROM system_configs WHERE `key`='low_stock_threshold'")->fetch();
$defTh = $th ? (int)$th['value'] : 50;

// GET /api/inventory
if ($method === 'GET' && $path === '/api/inventory') {
    $specName = $_GET['spec_name'] ?? '';
    $sql = "SELECT s.id as sku_id, ps.name as spec, c.name as color, s.current_stock as stock, COALESCE(s.low_stock_threshold, $defTh) as threshold
            FROM product_skus s
            JOIN product_specs ps ON s.spec_id=ps.id AND ps.is_active=1
            JOIN colors c ON s.color_id=c.id AND c.is_active=1";
    $params = [];
    if ($specName) { $sql .= ' WHERE ps.name = ?'; $params[] = $specName; }
    $sql .= ' ORDER BY ps.sort_order, ps.id, c.sort_order, c.id';
    $stmt = $db->prepare($sql); $stmt->execute($params); $rows = $stmt->fetchAll();

    $groups = []; $lowStock = [];
    foreach ($rows as $r) {
        $spec = $r['spec'];
        if (!isset($groups[$spec])) $groups[$spec] = [];
        $groups[$spec][] = ['sku_id'=>(int)$r['sku_id'],'color'=>$r['color'],'stock'=>(int)$r['stock'],'threshold'=>(int)$r['threshold']];
        if ((int)$r['stock'] < (int)$r['threshold']) {
            $lowStock[] = "{$r['spec']}-{$r['color']}: {$r['stock']}（阈值{$r['threshold']}）";
        }
    }
    Response::json(['inventory'=>$groups,'low_stock'=>$lowStock,'total_specs'=>count($groups),'total_skus'=>count($rows)]);
}

// GET /api/inventory/{id}/history
if ($method === 'GET' && preg_match('#/api/inventory/(\d+)/history$#', $path, $m)) {
    $limit = (int)($_GET['limit'] ?? 50);
    $stmt = $db->prepare('SELECT change_qty, before_stock, after_stock, created_at FROM inventory_logs WHERE sku_id=? ORDER BY created_at DESC LIMIT ?');
    $stmt->execute([(int)$m[1], $limit]);
    $rows = $stmt->fetchAll();
    $result = [];
    foreach ($rows as $r) {
        $result[] = ['change_qty'=>(int)$r['change_qty'],'before_stock'=>(int)$r['before_stock'],
                     'after_stock'=>(int)$r['after_stock'],'time'=>date('Y-m-d H:i', strtotime($r['created_at']))];
    }
    Response::json($result);
}

// GET /api/inventory/snapshot
if ($method === 'GET' && $path === '/api/inventory/snapshot') {
    $user = Auth::require();
    $today = date('Y-m-d');
    $stmt = $db->query("SELECT ps.name as spec, c.name as color, s.current_stock as stock, COALESCE(s.low_stock_threshold, $defTh) as threshold
        FROM product_skus s JOIN product_specs ps ON s.spec_id=ps.id AND ps.is_active=1 JOIN colors c ON s.color_id=c.id AND c.is_active=1
        ORDER BY ps.id, c.id");
    $rows = $stmt->fetchAll();

    $groups = [];
    foreach ($rows as $r) {
        $spec = $r['spec'];
        if (!isset($groups[$spec])) $groups[$spec] = [];
        $groups[$spec][] = $r;
    }

    $rowsHtml = '';
    foreach ($groups as $spec => $items) {
        $itemsHtml = '';
        foreach ($items as $item) {
            $low = $item['stock'] < $item['threshold'];
            $style = $low ? 'color:red;font-weight:bold' : '';
            $itemsHtml .= "<td style=\"padding:6px 10px;text-align:center;$style\">{$item['color']}<br>{$item['stock']}</td>";
        }
        $rowsHtml .= "<tr><td style=\"padding:6px 10px;font-weight:600;white-space:nowrap\">$spec</td>$itemsHtml</tr>";
    }

    $watermark = "{$user['username']} ｜ 淼伊库服饰有限公司 ｜ $today";
    $cells = '';
    for ($r=0;$r<8;$r++) for ($c=0;$c<5;$c++) $cells .= "<span style=\"font-size:28px;color:#000;transform:rotate(-25deg);white-space:nowrap;padding:40px 30px;\">$watermark</span>";

    $html = "<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"UTF-8\"><title>库存快照 $today</title>
<style>@page{margin:15mm}body{font-family:'PingFang SC','Microsoft YaHei',sans-serif;margin:0;padding:20px}
h1{text-align:center;color:#333;margin-bottom:5px}.date{text-align:center;color:#999;font-size:13px;margin-bottom:20px}
table{width:100%;border-collapse:collapse;font-size:12px;position:relative;z-index:1;background:rgba(255,255,255,0.85)}
th{background:#f5f5f5;padding:8px 10px;border:1px solid #ddd}td{border:1px solid #ddd}
.watermark{position:fixed;top:-20px;left:-20px;width:calc(100%+40px);height:calc(100%+40px);pointer-events:none;z-index:0;
display:flex;flex-wrap:wrap;align-items:center;justify-content:center;align-content:center;opacity:0.06}
@media print{.watermark{display:flex}}</style></head><body>
<div class=\"watermark\">$cells</div>
<h1>📦 库存快照</h1><div class=\"date\">下载人：{$user['username']} ｜ 下载日期：$today</div>
<table><thead><tr><th>规格</th>";
    $maxColors = $groups ? max(array_map('count', $groups)) : 1;
    for ($i=0;$i<$maxColors;$i++) $html .= '<th>颜色/库存</th>';
    $html .= "</tr></thead><tbody>$rowsHtml</tbody></table></body></html>";

    header('Content-Type: text/html; charset=utf-8');
    header("Content-Disposition: attachment; filename=\"inventory_snapshot_$today.html\"");
    echo $html;
    exit;
}

Response::error('Not Found', 404);
