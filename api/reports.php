<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $method = $_SERVER['REQUEST_METHOD']; $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// GET /api/reports/sales-summary
if ($method === 'GET' && str_ends_with($path, '/api/reports/sales-summary')) {
    $year = (int)($_GET['year'] ?? 0); $month = (int)($_GET['month'] ?? 0);

    $sql = "SELECT t.amount, sp.name as sp_name, ps.name as spec_name, MONTH(t.trans_date) as m
            FROM transactions t
            JOIN product_skus s ON t.sku_id=s.id
            JOIN product_specs ps ON s.spec_id=ps.id
            LEFT JOIN salespersons sp ON t.salesperson_id=sp.id
            WHERE t.trans_type='出库' AND YEAR(t.trans_date)=?";
    $params = [$year];
    if ($month > 0) { $sql .= ' AND MONTH(t.trans_date)=?'; $params[] = $month; }
    $stmt = $db->prepare($sql); $stmt->execute($params); $rows = $stmt->fetchAll();

    $bySp = []; $bySpec = []; $byMonth = []; $total = 0;
    foreach ($rows as $r) {
        $amt = (float)$r['amount']; $total += $amt;
        $spName = $r['sp_name'] ?: '未知';
        $bySp[$spName] = ($bySp[$spName] ?? 0) + $amt;
        $bySpec[$r['spec_name']] = ($bySpec[$r['spec_name']] ?? 0) + $amt;
        $mKey = (string)(int)$r['m'];
        $byMonth[$mKey] = ($byMonth[$mKey] ?? 0) + $amt;
    }
    Response::json(['total'=>(float)$total,'by_salesperson'=>$bySp,'by_spec'=>$bySpec,'by_month'=>$byMonth]);
}

// GET /api/months
if ($method === 'GET' && str_ends_with($path, '/api/months')) {
    $rows = $db->query('SELECT DISTINCT YEAR(trans_date) as year, MONTH(trans_date) as month FROM transactions ORDER BY year, month')->fetchAll();
    $result = [];
    foreach ($rows as $r) $result[] = ['year'=>(int)$r['year'],'month'=>(int)$r['month']];
    Response::json($result);
}

Response::error('Not Found', 404);
