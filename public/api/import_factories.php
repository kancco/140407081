<?php
error_log('manager_mobile input: ' . var_export($manager_mobile, true));
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/import_factories_php_error.log');

require_once __DIR__.'/_db.php';
require_once __DIR__.'/_normalize.php';
json_fatal_guard(__DIR__.'/factories_import_fatal.log');

$raw = file_get_contents('php://input');
if ($raw === false) {
    http_response_code(400);
    echo json_encode(['error' => 'no input']);
    exit;
}
$data = json_decode($raw, true);
if (!$data || !isset($data['rows']) || !is_array($data['rows'])) {
    http_response_code(400);
    echo json_encode(['error' => 'bad json']);
    exit;
}
$rows = $data['rows'];
$batch = isset($data['batch_id']) ? (string)$data['batch_id'] : (string)time();
if (!count($rows)) {
    echo json_encode(['inserted' => 0, 'skipped' => 0, 'errors' => 0, 'batch' => $batch]);
    exit;
}

$m = db();

// گرفتن لیست وایت‌لیست (شناسه ملی و نام کارخانه)
$whitelist_national_ids = [];
$whitelist_names = [];
$res = $m->query("SELECT company_national_id, company_name_fa FROM factories_whitelist");
while($row_wh = $res->fetch_assoc()) {
    if($row_wh['company_national_id']) $whitelist_national_ids[] = $row_wh['company_national_id'];
    if($row_wh['company_name_fa']) $whitelist_names[] = $row_wh['company_name_fa'];
}
unset($res);

// توجه: اگر جدول را با CREATE TABLE می‌سازی، ستون‌های جدید را هم باید اضافه کنی!
$m->query("CREATE TABLE IF NOT EXISTS factories_raw (
 id BIGINT UNSIGNED AUTO_INCREMENT,
 factory_name_fa VARCHAR(300), national_id VARCHAR(20), economic_code VARCHAR(30),
 province_name VARCHAR(120), city_name VARCHAR(120), address_fa VARCHAR(600),
 postal_code VARCHAR(20), phone_raw VARCHAR(120), email VARCHAR(200),
 manager_name_fa VARCHAR(200), manager_national_id VARCHAR(20), manager_mobile VARCHAR(20),
 production_site_type VARCHAR(255), manufacturing_industry_type VARCHAR(255),
 raw_import_batch VARCHAR(32), extra_data LONGTEXT,
 created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY(id),
 UNIQUE KEY uq_fact_nat (national_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

$inserted = 0;
$updated = 0;
$skipped = 0;
$errors = 0;
$skipReasons = ['missing_id'=>0, 'not_in_whitelist'=>0, 'other'=>0];

foreach($rows as $row) {
    $factory_name_fa = $row['factory_name_fa'] ?? null;
    $national_id     = normalize_id($row['national_id'] ?? null);
    $economic_code   = $row['economic_code'] ?? null;
    $province_name   = $row['province_name'] ?? null;
    $city_name       = $row['city_name'] ?? null;
    $address_fa      = $row['address_fa'] ?? null;
    $postal_code     = $row['postal_code'] ?? null;
    $phone_raw       = $row['phone_raw'] ?? null;
    $email           = $row['email'] ?? null;
    $manager_name_fa = $row['manager_name_fa'] ?? null;
    $manager_national_id = normalize_id($row['manager_national_id'] ?? null);
    $manager_mobile  = $row['manager_mobile'] ?? null;
    $production_site_type = $row['production_site_type'] ?? null;
    $manufacturing_industry_type = $row['manufacturing_industry_type'] ?? null;
    $extra_data      = isset($row['extra_data']) ? (is_scalar($row['extra_data'])?$row['extra_data']:json_encode($row['extra_data'],JSON_UNESCAPED_UNICODE)) : null;

    // شرط وایت لیست
    if (
        !in_array($national_id, $whitelist_national_ids, true) &&
        !in_array($factory_name_fa, $whitelist_names, true)
    ) {
        $skipped++;
        $skipReasons['not_in_whitelist'] = ($skipReasons['not_in_whitelist'] ?? 0) + 1;
        continue;
    }

    if ($national_id === '') {
        $skipped++;
        $skipReasons['missing_id']++;
        continue;
    }

    $sql="INSERT INTO factories_raw(
        factory_name_fa, national_id, economic_code, province_name, city_name, address_fa, postal_code, phone_raw, email,
        manager_name_fa, manager_national_id, manager_mobile,
        production_site_type, manufacturing_industry_type, raw_import_batch, extra_data
    )
    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    ON DUPLICATE KEY UPDATE
        factory_name_fa=VALUES(factory_name_fa), economic_code=VALUES(economic_code), province_name=VALUES(province_name),
        city_name=VALUES(city_name), address_fa=VALUES(address_fa), postal_code=VALUES(postal_code), phone_raw=VALUES(phone_raw),
        email=VALUES(email), manager_name_fa=VALUES(manager_name_fa), manager_national_id=VALUES(manager_national_id),
        manager_mobile=VALUES(manager_mobile), production_site_type=VALUES(production_site_type),
        manufacturing_industry_type=VALUES(manufacturing_industry_type),
        raw_import_batch=VALUES(raw_import_batch), extra_data=VALUES(extra_data)";
    $stmt = $m->prepare($sql);
    $stmt->bind_param('ssssssssssssssss',
        $factory_name_fa,$national_id,$economic_code,$province_name,$city_name,$address_fa,$postal_code,$phone_raw,
        $email,$manager_name_fa,$manager_national_id,$manager_mobile,
        $production_site_type,$manufacturing_industry_type,$batch,$extra_data
    );
    if (!$stmt->execute()) {
        $errors++;
        $skipReasons['other']++;
        continue;
    }
    if ($stmt->affected_rows === 1) $inserted++;
    else $updated++;
}

echo json_encode([
  'inserted' => $inserted,
  'updated'  => $updated,
  'skipped'  => $skipped,
  'errors'   => $errors,
  'batch'    => $batch,
  'skip_reasons' => $skipReasons
], JSON_UNESCAPED_UNICODE);