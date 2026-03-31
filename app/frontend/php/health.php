<?php
// ==========================================================
// CHARLIE CAFE — HEALTH CHECK ENDPOINT
// ----------------------------------------------------------
// ✔ Used by ALB, ECS, CodeDeploy
// ✔ Confirms app + database are working
// ✔ Returns HTTP 200 if healthy
// ✔ Returns HTTP 500 if unhealthy
// ==========================================================

// Set JSON header
header('Content-Type: application/json');

// -----------------------------
// 1️⃣ BASIC APP CHECK
// -----------------------------
$app_status = "OK";

// -----------------------------
// 2️⃣ DATABASE CHECK (IMPORTANT)
// -----------------------------
$db_status = "OK";

$host = getenv('DB_HOST') ?: 'localhost';
$user = getenv('DB_USER') ?: 'admin';
$pass = getenv('DB_PASS') ?: '';
$db   = getenv('DB_NAME') ?: 'charlie_cafe';

$conn = @new mysqli($host, $user, $pass, $db);

// Check DB connection
if ($conn->connect_error) {
    $db_status = "FAIL";
}

// -----------------------------
// 3️⃣ FINAL STATUS
// -----------------------------
if ($app_status === "OK" && $db_status === "OK") {

    http_response_code(200);

    echo json_encode([
        "status" => "OK",
        "app" => $app_status,
        "database" => $db_status,
        "timestamp" => date("Y-m-d H:i:s")
    ]);

} else {

    http_response_code(500);

    echo json_encode([
        "status" => "FAIL",
        "app" => $app_status,
        "database" => $db_status,
        "timestamp" => date("Y-m-d H:i:s")
    ]);
}
?>