<?php
// ==========================================================
// ☕ CHARLIE CAFE — FINAL HEALTH DASHBOARD (PRODUCTION SAFE)
// ==========================================================
// ✔ Fixes Unknown DB crash
// ✔ Uses AWS Secrets Manager OR fallback ENV
// ✔ Safe DB connection (NO fatal errors)
// ✔ ALB compatible (200/500)
// ==========================================================

header('Content-Type: text/html; charset=UTF-8');
mysqli_report(MYSQLI_REPORT_OFF);

// -----------------------------
// 1️⃣ DEFAULT STATUS
// -----------------------------
$app_status = "OK";
$db_status = "OK";
$redis_status = "OK";
$api_status = "OK";
$cpu_status = "OK";
$memory_status = "OK";
$restart_triggered = false;

// -----------------------------
// 2️⃣ LOAD AWS SECRETS (SAFE)
// -----------------------------
function getSecrets() {
    $cmd = "aws secretsmanager get-secret-value \
    --secret-id CafeDevDBSM \
    --query SecretString \
    --output text 2>/dev/null";

    $output = shell_exec($cmd);

    if ($output) {
        $data = json_decode($output, true);
        if ($data) return $data;
    }

    return null;
}

$secrets = getSecrets();

// ==========================================================
// 🔥 FIXED DB NAME (IMPORTANT CHANGE)
// ==========================================================
// MUST match your RDS script: cafe_db

$db_host = $secrets['host'] ?? getenv('DB_HOST') ?? 'localhost';
$db_user = $secrets['username'] ?? getenv('DB_USER') ?? 'root';
$db_pass = $secrets['password'] ?? getenv('DB_PASS') ?? '';
$db_name = $secrets['dbname'] ?? 'cafe_db';   // ✅ FIXED HERE

// -----------------------------
// 3️⃣ SAFE DATABASE CHECK (NO CRASH)
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
// 4️⃣ REDIS CHECK
// -----------------------------
$redis_host = getenv('REDIS_HOST') ?: 'localhost';
$redis_port = getenv('REDIS_PORT') ?: 6379;

$redis = @fsockopen($redis_host, $redis_port, $errno, $errstr, 1);

if (!$redis) {
    $redis_status = "FAIL";
} else {
    fclose($redis);
}

// -----------------------------
// 5️⃣ API CHECK
// -----------------------------
$api = getenv('API_DEP_URL') ?: 'https://jsonplaceholder.typicode.com/todos/1';

$ch = curl_init($api);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 2);
curl_exec($ch);

$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($http_code < 200 || $http_code >= 300) {
    $api_status = "FAIL";
}

// -----------------------------
// 6️⃣ CPU + MEMORY
// -----------------------------
$load = sys_getloadavg()[0];

$totalMem = @file_get_contents("/proc/meminfo");

if ($totalMem) {
    preg_match('/MemTotal:\s+(\d+)/', $totalMem, $t);
    preg_match('/MemAvailable:\s+(\d+)/', $totalMem, $a);

    if (isset($t[1], $a[1])) {
        $used = (($t[1] - $a[1]) / $t[1]) * 100;
        if ($used > 90) $memory_status = "FAIL";
    }
}

if ($load > 2.0) $cpu_status = "FAIL";

// -----------------------------
// 7️⃣ FINAL HEALTH STATE
// -----------------------------
$isHealthy =
    $db_status === "OK" &&
    $redis_status === "OK" &&
    $api_status === "OK" &&
    $cpu_status === "OK" &&
    $memory_status === "OK";

if (!$isHealthy) {
    @file_put_contents('/tmp/charlie_restart_trigger', date("Y-m-d H:i:s"));
    $restart_triggered = true;
}

// -----------------------------
// 8️⃣ ALB RESPONSE
// -----------------------------
http_response_code($isHealthy ? 200 : 500);

// -----------------------------
// 9️⃣ OUTPUT JSON
// -----------------------------
$json_output = json_encode([
    "status" => $isHealthy ? "OK" : "FAIL",
    "db" => $db_status,
    "redis" => $redis_status,
    "api" => $api_status,
    "cpu" => $cpu_status,
    "memory" => $memory_status,
    "restart" => $restart_triggered,
    "time" => date("Y-m-d H:i:s")
], JSON_PRETTY_PRINT);

?>

<!DOCTYPE html>
<html>
<head>
<title>Charlie Cafe Health</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body { background:#2b1d17; color:white; }
.card { margin-top:50px; padding:20px; border-radius:15px; }
.ok { color:lightgreen; }
.fail { color:red; }
pre { background:#111; padding:10px; }
</style>

</head>
<body>

<div class="container">
<div class="card bg-dark text-white">

<h2>☕ Charlie Cafe Health Dashboard</h2>

<div class="alert alert-<?php echo $isHealthy?'success':'danger'; ?>">
    SYSTEM <?php echo $isHealthy?'HEALTHY':'FAILED'; ?>
</div>

<ul class="list-group">

<li class="list-group-item">DB:
<b class="<?php echo $db_status=='OK'?'ok':'fail'; ?>">
<?php echo $db_status; ?>
</b></li>

<li class="list-group-item">Redis:
<b class="<?php echo $redis_status=='OK'?'ok':'fail'; ?>">
<?php echo $redis_status; ?>
</b></li>

<li class="list-group-item">API:
<b class="<?php echo $api_status=='OK'?'ok':'fail'; ?>">
<?php echo $api_status; ?>
</b></li>

<li class="list-group-item">CPU:
<b class="<?php echo $cpu_status=='OK'?'ok':'fail'; ?>">
<?php echo $cpu_status; ?>
</b></li>

<li class="list-group-item">Memory:
<b class="<?php echo $memory_status=='OK'?'ok':'fail'; ?>">
<?php echo $memory_status; ?>
</b></li>

</ul>

<hr>

<h5>JSON Output</h5>
<pre><?php echo $json_output; ?></pre>

</div>
</div>

</body>
</html>