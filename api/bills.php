<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $method = $_SERVER['REQUEST_METHOD']; $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// GET /api/bills/personal
if ($method === 'GET' && str_ends_with($path, '/api/bills/personal')) {
    $sp = $_GET['salesperson'] ?? ''; $year = (int)($_GET['year'] ?? 0); $month = (int)($_GET['month'] ?? 0);
    if (!$sp || !$year || !$month) Response::error('参数不全');

    $rows = $db->prepare("SELECT t.*, ps.name as spec, c.name as color
        FROM transactions t JOIN product_skus s ON t.sku_id=s.id
        JOIN product_specs ps ON s.spec_id=ps.id JOIN colors c ON s.color_id=c.id
        JOIN salespersons sp ON t.salesperson_id=sp.id
        WHERE sp.name=? AND t.trans_type='出库' AND YEAR(t.trans_date)=? AND MONTH(t.trans_date)=?
        ORDER BY t.trans_date, t.id");
    $rows->execute([$sp, $year, $month]);
    $all = $rows->fetchAll();

    $items = []; $totalQty = 0; $totalAmt = 0;
    foreach ($all as $t) {
        $items[] = ['date'=>$t['trans_date'],'spec'=>$t['spec'],'color'=>$t['color'],
            'quantity'=>(int)$t['quantity'],'unit_price'=>(float)$t['unit_price'],'amount'=>(float)$t['amount']];
        $totalQty += $t['quantity']; $totalAmt += $t['amount'];
    }
    Response::json(['salesperson'=>$sp,'year'=>$year,'month'=>$month,'items'=>$items,'total_qty'=>$totalQty,'total_amount'=>(float)$totalAmt]);
}

// GET /api/bills/inbound
if ($method === 'GET' && str_ends_with($path, '/api/bills/inbound')) {
    $year = (int)($_GET['year'] ?? 0); $month = (int)($_GET['month'] ?? 0);
    if (!$year || !$month) Response::error('参数不全');

    $rows = $db->prepare("SELECT t.*, ps.name as spec, c.name as color, sp.name as sp_name
        FROM transactions t JOIN product_skus s ON t.sku_id=s.id
        JOIN product_specs ps ON s.spec_id=ps.id JOIN colors c ON s.color_id=c.id
        LEFT JOIN salespersons sp ON t.salesperson_id=sp.id
        WHERE t.trans_type='入库' AND YEAR(t.trans_date)=? AND MONTH(t.trans_date)=?
        ORDER BY t.trans_date, t.id");
    $rows->execute([$year, $month]);
    $all = $rows->fetchAll();

    $items = []; $totalQty = 0;
    foreach ($all as $t) {
        $items[] = ['date'=>$t['trans_date'],'spec'=>$t['spec'],'color'=>$t['color'],
            'quantity'=>(int)$t['quantity'],'salesperson'=>$t['sp_name']??'','remark'=>$t['remark']??''];
        $totalQty += $t['quantity'];
    }
    Response::json(['year'=>$year,'month'=>$month,'items'=>$items,'total_qty'=>$totalQty]);
}

Response::error('Not Found', 404);
