<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__.'/_db.php';

$db = db();

$limit = isset($_GET['per_page']) ? intval($_GET['per_page']) : 5;

$sql = "SELECT source_code, status_fa, production_site_name_fa, production_line_name_fa, group_category, file_number, issue_datetime_raw, expire_datetime_raw, technical_committee_datetime_raw, technical_committee_number
        FROM tac_source_raw
        ORDER BY updated_at DESC
        LIMIT ?";
$stmt = $db->prepare($sql);
$stmt->bind_param('i', $limit);
$stmt->execute();
$res = $stmt->get_result();

$rows = [];
while($row = $res->fetch_assoc()) $rows[] = $row;

echo json_encode(['rows' => $rows], JSON_UNESCAPED_UNICODE);
?>