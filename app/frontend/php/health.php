<?php
header('Content-Type: application/json');
mysqli_report(MYSQLI_REPORT_OFF);

$db_status = "OK";

// -----------------------------
// SAFE SECRET FETCH
// -----------------------------
function getSecrets() {
    $cmd = "aws secretsmanager get-secret-value \
    --secret-id CafeDevDBSM \
    --query SecretString \
    --output text 2>/dev/null";

    $output = shell_exec($cmd);

    if (!$output) return null;

    $data = json_decode($output, true);
    return $data ?: null;
}

$secrets = getSecrets();

// -----------------------------
// FALLBACK SAFE CONFIG
// -----------------------------
$db_host = $secrets['host'] ?? getenv('DB_HOST') ?? 'cafedb.c03ieya4wc40.us-east-1.rds.amazonaws.com';
$db_user = $secrets['username'] ?? getenv('DB_USER') ?? 'cafe_user';
$db_pass = $secrets['password'] ?? getenv('DB_PASS') ?? 'StrongPassword123';
$db_name = $secrets['dbname'] ?? getenv('DB_NAME') ?? 'cafe_db';

// -----------------------------
// DB TEST (SAFE)
// -----------------------------
try {
    $conn = @new mysqli($db_host, $db_user, $db_pass, $db_name);

    if ($conn->connect_error) {
        $db_status = "FAIL";
    }

} catch (Throwable $e) {
    $db_status = "FAIL";
}

// -----------------------------
// RESPONSE
// -----------------------------
echo json_encode([
    "status" => $db_status,
    "db_name" => $db_name,
    "host" => $db_host
]);
?>