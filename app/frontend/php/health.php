<?php
// ==========================================================
// ☕ CHARLIE CAFE — FULL DEVOPS MONITORING DASHBOARD
// ----------------------------------------------------------
// ✔ Single-file solution for Docker + GitHub + AWS ECS
// ✔ Checks: App, DB, Redis, API, CPU/Memory, Auto-Restart
// ✔ Multi-region & responsive HTML dashboard
// ✔ Returns HTTP 200 / 500 for ALB health checks
// ==========================================================

header('Content-Type: text/html');

// -----------------------------
// 1️⃣ CONFIG & ENVIRONMENT
// -----------------------------
$app_status = "OK";
$db_status = "OK";
$redis_status = "OK";
$api_status = "OK";
$cpu_status = "OK";
$memory_status = "OK";
$restart_triggered = false;

$host = getenv('DB_HOST') ?: 'localhost';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: '';
$db   = getenv('DB_NAME') ?: 'charlie_cafe';

$redis_host = getenv('REDIS_HOST') ?: 'localhost';
$redis_port = getenv('REDIS_PORT') ?: 6379;

$api_dependency = getenv('API_DEP_URL') ?: 'https://jsonplaceholder.typicode.com/todos/1'; // example API

$regions = [
    'us-east-1' => 'https://us-east-1.example.com/health.php',
    'eu-central-1' => 'https://eu-central-1.example.com/health.php'
];

// -----------------------------
// 2️⃣ DATABASE CHECK
// -----------------------------
$conn = @new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) $db_status = "FAIL";

// -----------------------------
// 3️⃣ REDIS / CACHE CHECK
// -----------------------------
$redis = @fsockopen($redis_host, $redis_port, $errno, $errstr, 1);
if (!$redis) $redis_status = "FAIL"; else fclose($redis);

// -----------------------------
// 4️⃣ API DEPENDENCY CHECK
// -----------------------------
$ch = curl_init($api_dependency);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 2);
curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);
if ($http_code < 200 || $http_code >= 300) $api_status = "FAIL";

// -----------------------------
// 5️⃣ CPU & MEMORY CHECK
// -----------------------------
$load = sys_getloadavg()[0]; // 1-min avg
$totalMem = @file_get_contents("/proc/meminfo");
if ($totalMem !== false) {
    preg_match('/MemTotal:\s+(\d+) kB/', $totalMem, $matches);
    $total_kb = $matches[1];
    preg_match('/MemAvailable:\s+(\d+) kB/', $totalMem, $matches);
    $avail_kb = $matches[1];
    $used_percent = (($total_kb - $avail_kb)/$total_kb)*100;
    if ($used_percent > 90) $memory_status = "FAIL";
}
if ($load > 2.0) $cpu_status = "FAIL";

// -----------------------------
// 6️⃣ AUTO-RESTART TRIGGER
// -----------------------------
if (!$isHealthy = ($app_status==="OK" && $db_status==="OK" && $redis_status==="OK" && $api_status==="OK" && $cpu_status==="OK" && $memory_status==="OK")) {
    // Simple self-healing simulation: touch a file to trigger restart script in ECS / Docker
    @file_put_contents('/tmp/charlie_restart_trigger', date("Y-m-d H:i:s"));
    $restart_triggered = true;
}

// -----------------------------
// 7️⃣ MULTI-REGION CHECK (ONLY HTTP STATUS)
// -----------------------------
$region_statuses = [];
foreach($regions as $region => $url){
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $resp = @file_get_contents($url, false, $ctx);
    $region_statuses[$region] = ($resp !== false) ? "OK" : "FAIL";
}

// -----------------------------
// 8️⃣ HTTP RESPONSE FOR ALB
// -----------------------------
http_response_code($isHealthy ? 200 : 500);

// -----------------------------
// 9️⃣ JSON OUTPUT (ALB / API / Monitoring)
// -----------------------------
$json_output = json_encode([
    "status" => $isHealthy ? "OK" : "FAIL",
    "app" => $app_status,
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
<title>☕ Charlie Cafe DevOps Dashboard</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
<style>
body {background: linear-gradient(135deg,#3e2723,#6d4c41);color:#fff;font-family:'Segoe UI',sans-serif;}
.card {border-radius:15px;box-shadow:0 10px 25px rgba(0,0,0,0.4);}
.header-icon {font-size:50px;}
.status-ok {color:#4caf50;}
.status-fail {color:#ff5252;}
.footer {margin-top:20px;font-size:14px;opacity:0.8;}
pre {background:#222;padding:10px;border-radius:8px;overflow:auto;}
</style>
</head>
<body>
<div class="container d-flex justify-content-center align-items-center vh-100">
<div class="card text-dark p-4 col-md-8">
    <div class="text-center mb-3">
        <i class="bi bi-cup-hot-fill header-icon text-warning"></i>
        <h2>Charlie Cafe</h2>
        <p class="text-muted">Full DevOps Monitoring Dashboard</p>
    </div>

    <div class="alert alert-<?php echo $isHealthy ? 'success' : 'danger'; ?> text-center">
        <strong><?php echo $isHealthy ? 'SYSTEM HEALTHY' : 'SYSTEM ISSUES DETECTED'; ?></strong>
    </div>

    <ul class="list-group mb-3">
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-app"></i> App</span>
            <strong class="<?php echo $app_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $app_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-database"></i> Database</span>
            <strong class="<?php echo $db_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $db_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-server"></i> Redis</span>
            <strong class="<?php echo $redis_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $redis_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-cloud-arrow-down"></i> API Dependency</span>
            <strong class="<?php echo $api_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $api_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-cpu"></i> CPU Load</span>
            <strong class="<?php echo $cpu_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $cpu_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-memory"></i> Memory Usage</span>
            <strong class="<?php echo $memory_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $memory_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-arrow-clockwise"></i> Auto-Restart Triggered</span>
            <strong class="<?php echo $restart_triggered?'status-fail':'status-ok'; ?>"><?php echo $restart_triggered?'YES':'NO'; ?></strong>
        </li>
    </ul>

    <div class="mb-3">
        <label><strong>Multi-Region Status:</strong></label>
        <ul class="list-group">
            <?php foreach($region_statuses as $region => $status): ?>
                <li class="list-group-item d-flex justify-content-between">
                    <span><?php echo strtoupper($region); ?></span>
                    <strong class="<?php echo $status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $status; ?></strong>
                </li>
            <?php endforeach; ?>
        </ul>
    </div>

    <div class="mb-3">
        <label><strong>Raw JSON Output:</strong></label>
        <pre><?php echo $json_output; ?></pre>
    </div>

    <div class="text-center footer">
        ☕ Charlie Cafe DevOps Dashboard | Docker + AWS ECS + Redis + Multi-Region
    </div>
</div>
</div>
</body>
</html>