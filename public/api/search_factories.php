<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__.'/_db.php';
$m = db();

$nid  = trim($_GET['national_id'] ?? '');
$name = trim($_GET['name'] ?? '');
$q    = trim($_GET['q'] ?? '');

$page = max(1, (int)($_GET['page'] ?? 1));
$per  = min(100, max(1, (int)($_GET['per_page'] ?? 20))); // ← پرانتز اضافه شد
$off  = ($page - 1) * $per;

$where = [];
$params = [];
$types = '';

if ($nid !== '') {
    $where[] = "f.national_id=?";
    $params[] = $nid;
    $types .= 's';
}
if ($name !== '') {
    $where[] = "f.factory_name_fa LIKE ?";
    $params[] = "%$name%";
    $types .= 's';
}
if ($q !== '') {
    $where[] = "(f.factory_name_fa LIKE ? OR f.city_name LIKE ? OR f.province_name LIKE ?)";
    for ($i = 0; $i < 3; $i++) {
        $params[] = "%$q%";
        $types .= 's';
    }
}

$wSQL = $where ? ('WHERE ' . implode(' AND ', $where)) : '';
$totalSQL = "SELECT COUNT(*) FROM factories_raw f $wSQL";
$st = $m->prepare($totalSQL);
if ($params) {
    $b = [$types];
    foreach ($params as $i => $v) {
        $b[] = &$params[$i];
    }
    call_user_func_array([$st, 'bind_param'], $b);
}
$st->execute();
$total = $st->get_result()->fetch_row()[0] ?? 0;

// --- JOIN با جدول factories_whitelist بر اساس شناسه ملی ---
$sql = "SELECT
    f.factory_name_fa,
    f.national_id,
    f.economic_code,
    f.province_name,
    f.city_name,
    f.manager_name_fa,
    f.postal_code,
    f.phone_raw,
    f.email,
    f.address_fa,
    f.website,
    f.manager_national_id,
    f.manager_mobile,
    f.company_name_en,
    f.company_type_fa,
    f.country_name_fa,
    f.gln_code,
    f.raw_import_batch,
    f.extra_data,
    f.created_at,
    f.updated_at,
    f.production_site_type,
    f.manufacturing_industry_type
FROM factories_raw f
LEFT JOIN factories_whitelist w ON f.national_id = w.company_national_id
$wSQL
ORDER BY f.id DESC
LIMIT ? OFFSET ?";

$params2 = $params;
$types2 = $types . 'ii';
$params2[] = $per;
$params2[] = $off;

$st2 = $m->prepare($sql);
if (!$st2) {
    echo json_encode(['error' => 'Prepare failed', 'details' => $m->error, 'sql' => $sql]);
    exit;
}
$b2 = [$types2];
foreach ($params2 as $i => $v) {
    $b2[] = &$params2[$i];
}
if (!call_user_func_array([$st2, 'bind_param'], $b2)) {
    echo json_encode(['error' => 'Bind param failed', 'details' => $st2->error]);
    exit;
}
if (!$st2->execute()) {
    echo json_encode(['error' => 'Execute failed', 'details' => $st2->error]);
    exit;
}
$res = $st2->get_result();
if (!$res) {
    echo json_encode(['error' => 'Get result failed', 'details' => $st2->error]);
    exit;
}
$out = [];
while ($r = $res->fetch_assoc()) {
    $out[] = $r;
}

echo json_encode([
    'page' => $page,
    'per_page' => $per,
    'total' => $total,
    'rows' => $out
], JSON_UNESCAPED_UNICODE);
?>