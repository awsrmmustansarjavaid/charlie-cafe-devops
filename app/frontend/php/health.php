<?php
// ==========================================================
// ☕ CHARLIE CAFE — FINAL DEVOPS HEALTH CHECK DASHBOARD
// ==========================================================
// ✔ Safe production version (NO fatal crashes)
// ✔ AWS RDS + Redis + API + CPU + Memory monitoring
// ✔ AWS Secrets Manager support (fallback safe)
// ✔ ALB health check compatible (200/500)
// ==========================================================

header('Content-Type: text/html; charset=UTF-8');

// Prevent mysqli fatal crash
mysqli_report(MYSQLI_REPORT_OFF);

// -----------------------------
// 1️⃣ DEFAULT STATUS FLAGS
// -----------------------------
$app_status = "OK";
$db_status = "OK";
$redis_status = "OK";
$api_status = "OK";
$cpu_status = "OK";
$memory_status = "OK";
$restart_triggered = false;

// -----------------------------
// 2️⃣ AWS SECRETS / ENV CONFIG LOADER
// -----------------------------
// Priority: ENV → AWS Secrets Manager → fallback

function getSecrets() {
    $secretArn = "arn:aws:secretsmanager:us-east-1:537236558357:secret:CafeDevDBSM-XovYsA";

    // Try AWS CLI (works in EC2/ECS with IAM role)
    $cmd = "aws secretsmanager get-secret-value --secret-id CafeDevDBSM --query SecretString --output text 2>/dev/null";
    $output = shell_exec($cmd);

    if ($output) {
        $data = json_decode($output, true);
        if ($data) return $data;
    }

    // fallback empty
    return null;
}

$secrets = getSecrets();

// Final DB config resolution
$db_host = $secrets['host'] ?? getenv('DB_HOST') ?? 'localhost';
$db_user = $secrets['username'] ?? getenv('DB_USER') ?? 'root';
$db_pass = $secrets['password'] ?? getenv('DB_PASS') ?? '';
$db_name = $secrets['dbname'] ?? getenv('DB_NAME') ?? 'cafe_db';

// Redis config
$redis_host = getenv('REDIS_HOST') ?: 'localhost';
$redis_port = getenv('REDIS_PORT') ?: 6379;

// External API dependency
$api_dependency = getenv('API_DEP_URL') ?: 'https://jsonplaceholder.typicode.com/todos/1';

// Multi-region health endpoints
$regions = [
    'us-east-1' => 'https://us-east-1.example.com/health.php',
    'eu-central-1' => 'https://eu-central-1.example.com/health.php'
];

// -----------------------------
// 3️⃣ DATABASE CHECK (SAFE)
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
$redis = @fsockopen($redis_host, $redis_port, $errno, $errstr, 1);
if (!$redis) {
    $redis_status = "FAIL";
} else {
    fclose($redis);
}

// -----------------------------
// 5️⃣ API DEPENDENCY CHECK
// -----------------------------
$ch = curl_init($api_dependency);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 2);
curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($http_code < 200 || $http_code >= 300) {
    $api_status = "FAIL";
}

// -----------------------------
// 6️⃣ CPU + MEMORY CHECK
// -----------------------------
$load = sys_getloadavg()[0];

// Memory check (Linux only)
$totalMem = @file_get_contents("/proc/meminfo");

if ($totalMem !== false) {
    preg_match('/MemTotal:\s+(\d+) kB/', $totalMem, $m1);
    preg_match('/MemAvailable:\s+(\d+) kB/', $totalMem, $m2);

    if (isset($m1[1]) && isset($m2[1])) {
        $total = $m1[1];
        $avail = $m2[1];
        $used_percent = (($total - $avail) / $total) * 100;

        if ($used_percent > 90) {
            $memory_status = "FAIL";
        }
    }
}

if ($load > 2.0) {
    $cpu_status = "FAIL";
}

// -----------------------------
// 7️⃣ HEALTH DECISION ENGINE
// -----------------------------
$isHealthy =
    ($app_status === "OK") &&
    ($db_status === "OK") &&
    ($redis_status === "OK") &&
    ($api_status === "OK") &&
    ($cpu_status === "OK") &&
    ($memory_status === "OK");

// Self-healing trigger (ECS/Docker hook)
if (!$isHealthy) {
    @file_put_contents('/tmp/charlie_restart_trigger', date("Y-m-d H:i:s"));
    $restart_triggered = true;
}

// -----------------------------
// 8️⃣ MULTI-REGION CHECK
// -----------------------------
$region_statuses = [];

foreach ($regions as $region => $url) {
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $resp = @file_get_contents($url, false, $ctx);

    $region_statuses[$region] = ($resp !== false) ? "OK" : "FAIL";
}

// -----------------------------
// 9️⃣ ALB RESPONSE CODE
// -----------------------------
http_response_code($isHealthy ? 200 : 500);

// -----------------------------
// 🔟 JSON OUTPUT (FOR MONITORING)
// -----------------------------
$json_output = json_encode([
    "status" => $isHealthy ? "OK" : "FAIL",
    "database" => $db_status,
    "redis" => $redis_status,
    "api_dependency" => $api_status,
    "cpu" => $cpu_status,
    "memory" => $memory_status,
    "auto_restart_triggered" => $restart_triggered,
    "regions" => $region_statuses,
    "timestamp" => date("Y-m-d H:i:s")
], JSON_PRETTY_PRINT);

?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>☕ Charlie Cafe Health Dashboard</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
body { background: linear-gradient(135deg,#3e2723,#6d4c41); color:#fff; }
.card { border-radius:15px; box-shadow:0 10px 25px rgba(0,0,0,0.4); }
.status-ok { color:#4caf50; }
.status-fail { color:#ff5252; }
pre { background:#111; padding:10px; border-radius:10px; overflow:auto; }
</style>
</head>

<body>

<div class="container py-5">
<div class="card p-4 text-dark">

    <div class="text-center">
        <h2>☕ Charlie Cafe DevOps Health</h2>
        <p class="text-muted">AWS ECS + RDS + Redis + Multi-Region</p>
    </div>

    <div class="alert alert-<?php echo $isHealthy ? 'success' : 'danger'; ?>">
        <strong><?php echo $isHealthy ? 'SYSTEM HEALTHY' : 'SYSTEM DEGRADED'; ?></strong>
    </div>

    <ul class="list-group mb-3">
        <li class="list-group-item">Database: <b class="<?php echo $db_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $db_status; ?></b></li>
        <li class="list-group-item">Redis: <b class="<?php echo $redis_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $redis_status; ?></b></li>
        <li class="list-group-item">API: <b class="<?php echo $api_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $api_status; ?></b></li>
        <li class="list-group-item">CPU: <b class="<?php echo $cpu_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $cpu_status; ?></b></li>
        <li class="list-group-item">Memory: <b class="<?php echo $memory_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $memory_status; ?></b></li>
    </ul>

    <h5>🌍 Multi-Region</h5>
    <ul class="list-group mb-3">
        <?php foreach ($region_statuses as $r => $s): ?>
            <li class="list-group-item d-flex justify-content-between">
                <span><?php echo $r; ?></span>
                <b class="<?php echo $s=='OK'?'status-ok':'status-fail'; ?>"><?php echo $s; ?></b>
            </li>
        <?php endforeach; ?>
    </ul>

    <h5>📦 JSON Output</h5>
    <pre><?php echo $json_output; ?></pre>

    <div class="text-center mt-3">
        ☕ Charlie Cafe | DevOps Monitoring System
    </div>

</div>
</div>

<!-- ===================== LOAD CENTRAL MODULES ===================== -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script>
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>