<?php
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Auth.php';
require_once __DIR__ . '/../includes/Response.php';
$db = Database::getInstance(); $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && str_ends_with($path, '/api/import/stock')) {
    $user = Auth::require();
    if (!isset($_FILES['file'])) Response::error('请上传文件');

    $file = $_FILES['file'];
    if (!str_ends_with($file['name'], '.xlsx')) Response::error('只支持 .xlsx 文件');

    require_once __DIR__ . '/../vendor/autoload.php'; // PhpSpreadsheet

    try {
        $spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($file['tmp_name']);
        $sheets = $spreadsheet->getSheetNames();
        $ws = $spreadsheet->getSheetByName(end($sheets));
        $rows = $ws->toArray();

        $specPositions = [];
        $prev = null;
        foreach ($rows[0] as $ci => $val) {
            $v = trim((string)$val);
            if ($v && !in_array($v, ['日期','入','出',''])) {
                if ($v !== $prev) { $specPositions[] = ['col'=>$ci, 'name'=>$v]; $prev = $v; }
            } else { $prev = null; }
        }

        $imported = 0;
        foreach ($specPositions as $idx => $sp) {
            $nextCol = isset($specPositions[$idx+1]) ? $specPositions[$idx+1]['col'] : count($rows[0]);

            $colorCols = [];
            for ($c = $sp['col']; $c < $nextCol; $c++) {
                $h = trim((string)($rows[1][$c] ?? ''));
                if ($h && !in_array($h, ['日期','入','出',''])) $colorCols[] = ['col'=>$c, 'name'=>$h];
            }

            // 找最后合计行
            $lastRow = 2;
            for ($r = 2; $r < count($rows); $r++) {
                if (trim((string)($rows[$r][$sp['col']] ?? '')) === '合计') $lastRow = $r;
            }

            foreach ($colorCols as $cc) {
                $stock = (int)($rows[$lastRow][$cc['col']] ?? 0);

                $spec = $db->prepare('SELECT id FROM product_specs WHERE name=?'); $spec->execute([$sp['name']]);
                $s = $spec->fetch();
                if (!$s) { $db->prepare('INSERT INTO product_specs (name) VALUES (?)')->execute([$sp['name']]); $s = ['id'=>$db->lastInsertId()]; }

                $color = $db->prepare('SELECT id FROM colors WHERE name=?'); $color->execute([$cc['name']]);
                $c = $color->fetch();
                if (!$c) { $db->prepare('INSERT INTO colors (name) VALUES (?)')->execute([$cc['name']]); $c = ['id'=>$db->lastInsertId()]; }

                $sku = $db->prepare('SELECT id FROM product_skus WHERE spec_id=? AND color_id=?');
                $sku->execute([$s['id'], $c['id']]); $sk = $sku->fetch();
                if ($sk) {
                    $db->prepare('UPDATE product_skus SET current_stock=? WHERE id=?')->execute([$stock, $sk['id']]);
                } else {
                    $db->prepare('INSERT INTO product_skus (spec_id, color_id, current_stock) VALUES (?,?,?)')->execute([$s['id'], $c['id'], $stock]);
                }
                $imported++;
            }
        }

        $db->prepare('INSERT INTO operation_logs (admin_id, admin_name, action, target, detail) VALUES (?,?,?,?,?)')
           ->execute([$user['admin_id'], $user['username'], 'import', 'stock', "导入库存: {$file['name']}, 更新 $imported SKU"]);
        Response::json(['ok'=>true, 'imported_skus'=>$imported]);
    } catch (Exception $e) {
        Response::error('导入失败: ' . $e->getMessage(), 500);
    }
}
Response::error('Not Found', 404);
