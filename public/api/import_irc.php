<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/import_irc_php_error.log');

require_once __DIR__.'/_db.php';
require_once __DIR__.'/_normalize.php';
json_fatal_guard(__DIR__.'/irc_import_fatal.log');

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
    echo json_encode(['inserted' => 0, 'updated' => 0, 'skipped' => 0, 'errors' => 0, 'batch' => $batch, 'skip_reasons' => []]);
    exit;
}

$m = db();

$whitelist_national_ids = [];
$res = $m->query("SELECT company_national_id FROM factories_whitelist WHERE company_national_id IS NOT NULL AND company_national_id != ''");
while($row_wh = $res->fetch_assoc()) {
    $whitelist_national_ids[] = normalize_id($row_wh['company_national_id']);
}
unset($res);

$inserted = 0;
$updated = 0;
$skipped = 0;
$errors = 0;
$skipReasons = ['not_in_whitelist'=>0, 'missing_irc_code'=>0, 'missing_national_id_license'=>0, 'other'=>0];

// لیست دقیق فیلدهای جدول (بدون id, created_at, updated_at)
$fields = [
    'irc_code', 'status_fa', 'product_trade_name_fa', 'product_generic_name_fa',
    'issue_datetime_raw', 'first_issue_datetime_raw', 'expire_datetime_raw', 'mother_license_code',
    'license_holder_name_fa', 'manufacturer_name_fa', 'manufacturer_country_fa',
    'trade_owner_name_fa', 'trade_owner_country_fa', 'national_id_license',
    'beneficiary_company_name_fa', 'beneficiary_company_country_fa', 'domain_fa',
    'category_group_code', 'gtin', 'unit_type_fa', 'file_number', 'sent_datetime_raw',
    'final_fix_datetime_raw', 'committee_datetime_raw', 'committee_letter_number',
    'committee_letter_datetime_raw', 'row_hash', 'raw_import_batch', 'extra_data'
];

$field_list = implode(',', $fields);
$values_list = implode(',', array_fill(0, count($fields), '?'));
$update_list = implode(', ', array_map(function($f){return "$f=VALUES($f)";}, $fields));

foreach($rows as $row) {
    $irc_code = $row['irc_code'] ?? null;
    $national_id_license = normalize_id($row['national_id_license'] ?? null);

    if ($national_id_license === null || $national_id_license === '') {
        $skipped++; $skipReasons['missing_national_id_license']++; continue;
    }
    if (!in_array($national_id_license, $whitelist_national_ids, true)) {
        $skipped++; $skipReasons['not_in_whitelist']++; continue;
    }
    if ($irc_code === null || $irc_code === '') {
        $skipped++; $skipReasons['missing_irc_code']++; continue;
    }

    // row_hash تولید کن
    $fields_for_hash = [];
    foreach($fields as $f){
        if($f !== 'row_hash' && $f !== 'raw_import_batch' && $f !== 'extra_data'){
            $fields_for_hash[] = $row[$f] ?? '';
        }
    }
    $buf = [];
    foreach($fields_for_hash as $f){
      $v = trim(mb_strtolower((string)$f, 'UTF-8'));
      $v = preg_replace('/\s+/u', ' ', $v);
      $buf[] = $v;
    }
    $row_hash = md5(implode('|', $buf), true);

    $extra_data = isset($row['extra_data']) ? (is_scalar($row['extra_data'])?$row['extra_data']:json_encode($row['extra_data'],JSON_UNESCAPED_UNICODE)) : null;

    // آرایه پارامترها را با ترتیب fields بساز
    $params = [];
    foreach($fields as $f){
        if($f === 'row_hash') $params[] = $row_hash;
        elseif($f === 'raw_import_batch') $params[] = $batch;
        elseif($f === 'extra_data') $params[] = $extra_data;
        else $params[] = $row[$f] ?? null;
    }

    $sql = "INSERT INTO irc_raw ($field_list) VALUES ($values_list)
            ON DUPLICATE KEY UPDATE $update_list, updated_at=NOW()";

    $stmt = $m->prepare($sql);
    if(!$stmt){
        $errors++; $skipReasons['other']++;
        error_log('Prepare failed: '.$m->error); continue;
    }
    $types = str_repeat('s', count($fields));
    $stmt->bind_param($types, ...$params);

    if (!$stmt->execute()) {
        $errors++; $skipReasons['other']++;
        error_log('Execute failed: '.$stmt->error); continue;
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
?>