<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $method = $_SERVER['REQUEST_METHOD']; $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// DELETE /api/transactions/{id} - 撤销记录
if ($method === 'DELETE' && preg_match('#/api/transactions/(\d+)$#', $path, $m)) {
    $user = Auth::require(); $id = (int)$m[1];
    $txn = $db->prepare('SELECT t.*, s.spec_id, s.color_id FROM transactions t JOIN product_skus s ON t.sku_id=s.id WHERE t.id=?');
    $txn->execute([$id]); $t = $txn->fetch();
    if (!$t) Response::error('记录不存在', 404);

    $spec = $db->prepare('SELECT name FROM product_specs WHERE id=?'); $spec->execute([$t['spec_id']]); $sp = $spec->fetch();
    $color = $db->prepare('SELECT name FROM colors WHERE id=?'); $color->execute([$t['color_id']]); $co = $color->fetch();
    $label = ($sp['name']??'?').'-'.($co['name']??'?');

    // 恢复库存
    if ($t['trans_type'] === '出库') {
        $db->prepare('UPDATE product_skus SET current_stock = current_stock + ? WHERE id = ?')->execute([$t['quantity'], $t['sku_id']]);
    } else {
        $db->prepare('UPDATE product_skus SET current_stock = current_stock - ? WHERE id = ?')->execute([$t['quantity'], $t['sku_id']]);
    }

    $db->prepare('DELETE FROM inventory_logs WHERE transaction_id = ?')->execute([$id]);
    $db->prepare('DELETE FROM transactions WHERE id = ?')->execute([$id]);
    $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
       ->execute([$user['admin_id'], $user['username'], 'delete', 'transaction', "撤销 {$t['trans_type']} 记录: $label x{$t['quantity']}"]);
    Response::json(['ok' => true, 'deleted_id' => $id]);
}

// POST /api/transactions/batch - 批量录入
if ($method === 'POST' && str_ends_with($path, '/api/transactions/batch')) {
    $user = Auth::require();
    $body = json_decode(file_get_contents('php://input'), true);
    $items = $body['items'] ?? [];
    $results = [];

    $db->beginTransaction();
    try {
        foreach ($items as $item) {
            $transDate = $item['trans_date'];
            $transType = $item['trans_type'];
            $specName = trim($item['spec_name']);
            $colorName = trim($item['color_name']);
            $qty = (int)($item['quantity'] ?? 0);
            $price = (float)($item['unit_price'] ?? 0);
            $amount = $qty * $price;
            $spName = trim($item['salesperson_name'] ?? '');
            $remark = $item['remark'] ?? '';

            // 获取/创建 SKU
            $spec = $db->prepare('SELECT id FROM product_specs WHERE name = ? AND is_active = 1');
            $spec->execute([$specName]); $s = $spec->fetch();
            if (!$s) { $db->prepare('INSERT INTO product_specs (name) VALUES (?)')->execute([$specName]); $s = ['id'=>$db->lastInsertId()]; }

            $color = $db->prepare('SELECT id FROM colors WHERE name = ? AND is_active = 1');
            $color->execute([$colorName]); $c = $color->fetch();
            if (!$c) { $db->prepare('INSERT INTO colors (name) VALUES (?)')->execute([$colorName]); $c = ['id'=>$db->lastInsertId()]; }

            $sku = $db->prepare('SELECT id, current_stock FROM product_skus WHERE spec_id=? AND color_id=?');
            $sku->execute([$s['id'], $c['id']]); $sk = $sku->fetch();
            if (!$sk) {
                $db->prepare('INSERT INTO product_skus (spec_id, color_id, current_stock) VALUES (?,?,0)')->execute([$s['id'], $c['id']]);
                $sk = ['id' => $db->lastInsertId(), 'current_stock' => 0];
            }

            // 销售人员
            $spId = null;
            if ($spName) {
                $sp = $db->prepare('SELECT id FROM salespersons WHERE name=? AND is_active=1');
                $sp->execute([$spName]); $spRow = $sp->fetch();
                if (!$spRow) { $db->prepare('INSERT INTO salespersons (name) VALUES (?)')->execute([$spName]); $spRow = ['id'=>$db->lastInsertId()]; }
                $spId = $spRow['id'];
            }

            // 更新库存
            $oldStock = (int)$sk['current_stock'];
            $newStock = $transType === '出库' ? $oldStock - $qty : $oldStock + $qty;
            $changeQty = $transType === '出库' ? -$qty : $qty;

            $db->prepare('UPDATE product_skus SET current_stock = ? WHERE id = ?')->execute([$newStock, $sk['id']]);

            // 插入交易
            $db->prepare('INSERT INTO transactions (trans_date, trans_type, sku_id, quantity, unit_price, amount, salesperson_id, entry_person, remark) VALUES (?,?,?,?,?,?,?,?,?)')
               ->execute([$transDate, $transType, $sk['id'], $qty, $price, $amount, $spId, $user['username'], $remark]);
            $txnId = $db->lastInsertId();

            // 库存流水
            $db->prepare('INSERT INTO inventory_logs (sku_id, transaction_id, change_qty, before_stock, after_stock) VALUES (?,?,?,?,?)')
               ->execute([$sk['id'], $txnId, $changeQty, $oldStock, $newStock]);

            $results[] = ['id' => (int)$txnId, 'sku' => "$specName-$colorName", 'stock_after' => $newStock];
        }

        $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
           ->execute([$user['admin_id'], $user['username'], 'create', 'transaction', '批量录入 '.count($results).' 条出入库记录']);

        $db->commit();
        Response::json(['ok' => true, 'count' => count($results), 'results' => $results]);
    } catch (Exception $e) {
        $db->rollBack();
        Response::error('录入失败: ' . $e->getMessage(), 500);
    }
}

// GET /api/reports/daily - 每日报表
if ($method === 'GET' && str_ends_with($path, '/api/reports/daily')) {
    $date = $_GET['trans_date'] ?? date('Y-m-d');
    $rows = $db->prepare('SELECT t.*, ps.name as spec_name, c.name as color_name, sp.name as sp_name
        FROM transactions t
        JOIN product_skus s ON t.sku_id=s.id
        JOIN product_specs ps ON s.spec_id=ps.id
        JOIN colors c ON s.color_id=c.id
        LEFT JOIN salespersons sp ON t.salesperson_id=sp.id
        WHERE t.trans_date = ? ORDER BY t.trans_type, t.id');
    $rows->execute([$date]);
    $all = $rows->fetchAll();

    $outList = []; $inList = []; $outTotal = 0; $inTotalQty = 0;
    foreach ($all as $t) {
        $item = ['id'=>(int)$t['id'],'spec'=>$t['spec_name'],'color'=>$t['color_name'],
                 'quantity'=>(int)$t['quantity'],'unit_price'=>(float)$t['unit_price'],
                 'amount'=>(float)$t['amount'],'salesperson'=>$t['sp_name']??'',
                 'entry_person'=>$t['entry_person']??'','remark'=>$t['remark']??''];
        if ($t['trans_type'] === '出库') { $outList[] = $item; $outTotal += $t['amount']; }
        else { $inList[] = $item; $inTotalQty += $t['quantity']; }
    }
    Response::json(['date'=>$date,'outbound'=>$outList,'outbound_total'=>(float)$outTotal,'outbound_count'=>count($outList),
                    'inbound'=>$inList,'inbound_total_qty'=>$inTotalQty,'inbound_count'=>count($inList)]);
}

Response::error('Not Found', 404);
