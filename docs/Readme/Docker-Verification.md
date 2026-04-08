# Docker Verification

### 1️⃣ Check Docker Service

```
# Check if Docker service is running
sudo systemctl status docker

# Start Docker if not running
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker
```

### 2️⃣ Verify Docker Version and Info

```
docker --version
docker info
```

Look for Server Version, Storage Driver, and Running Containers.

### 3️⃣ List All Containers

```
# Running containers
docker ps

# All containers including stopped
docker ps -a
```

Check if your Apache container is running.

### 4️⃣ Check Apache Container Logs

```
# Replace <container_name> with your container, e.g., verify-apache-test
docker logs <container_name>
```

Look for errors, e.g., port conflicts, missing files, permission errors.

### 5️⃣ Inspect Container Ports

```
docker inspect <container_name> | grep -i "Port"
```

Or more readable:

```
docker port <container_name>
```

Check that container port 80 is mapped to host port 8080 (or the port you intended).

### 6️⃣ Test Apache Inside Container

```
# Enter container shell
docker exec -it <container_name> bash

# Test Apache inside container
curl -I http://localhost
# Should return HTTP/1.1 200 OK
```

### 7️⃣ Test Apache from Host

```
# From EC2 host, test mapped port
curl -I http://localhost:8080
```

If this fails:

- Check firewall/security group.

- Check port mapping in container.

### 8️⃣ Check Host Ports

```
# See if port 8080 is listening
sudo netstat -tulpn | grep 8080

# Or using ss
sudo ss -tulpn | grep 8080
```

### 9️⃣ Check Firewall / Security Groups

#### On EC2 (Linux Firewall):

```
sudo firewall-cmd --list-all       # If using firewalld
sudo iptables -L -n -v             # Check iptables rules
```

AWS Security Group:
- Port 8080 (or 80) must be allowed inbound from your IP.

### 🔟 Remove & Recreate Container

```
docker rm -f <container_name>
docker run -d --name <container_name> -p 8080:80 httpd:latest
```

Check logs immediately:

```
docker logs <container_name>
```

### 1️⃣1️⃣ Check Apache inside container config

Sometimes the container fails because Apache tries to bind to 0.0.0.0:80 but the port is already used:

```
docker exec -it <container_name> bash
cat /usr/local/apache2/conf/httpd.conf | grep Listen
```

Default: Listen 80. Make sure it matches your mapped port.

### 1️⃣2️⃣ Network Troubleshooting

```
# Test if Docker bridge is OK
docker network ls
docker network inspect bridge

# Ping container from host
docker exec -it <container_name> ping 127.0.0.1
```

### ✅ Quick Debug Flow

- sudo systemctl status docker → Docker running?

- docker ps -a → Apache container exists and running?

- docker logs <container> → Any Apache errors?

- docker port <container> → Correct host:container port mapping?

- curl http://localhost:8080 → Works on host?

- sudo netstat -tulpn | grep 8080 → Port listening?

- Security group allows inbound 8080?

- If issues remain → docker rm -f and restart container.

### ✅ compact bash script

#### Here’s a ready-to-use script:

```
#!/bin/bash
# ==========================================================
# 🚨 Docker + Apache Verification Script — Charlie Cafe
# ==========================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "${GREEN}✅ $1${NC}"; ((PASS++)); }
fail() { echo -e "${RED}❌ $1${NC}"; ((FAIL++)); }
warn() { echo -e "${YELLOW}⚠️ $1${NC}"; }

# 1️⃣ Docker service
systemctl is-active --quiet docker && pass "Docker service running" || fail "Docker service not running"

# 2️⃣ Docker version & info
docker --version &>/dev/null && pass "Docker version OK" || fail "Docker not installed"
docker info &>/dev/null && pass "Docker info OK" || fail "Docker info failed"

# 3️⃣ List containers
docker ps &>/dev/null && pass "Docker running containers OK" || fail "No running containers"

# 4️⃣ Container logs (Apache)
APACHE_CONTAINER=$(docker ps -qf "ancestor=httpd")
if [ -n "$APACHE_CONTAINER" ]; then
    docker logs "$APACHE_CONTAINER" | head -n 5
    pass "Apache container logs OK"
else
    fail "No Apache container running"
fi

# 5️⃣ Inspect container ports
if [ -n "$APACHE_CONTAINER" ]; then
    docker port "$APACHE_CONTAINER" &>/dev/null && pass "Apache container ports OK" || fail "Port mapping issue"
fi

# 6️⃣ Test Apache inside container
if [ -n "$APACHE_CONTAINER" ]; then
    docker exec "$APACHE_CONTAINER" curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200" && pass "Apache responds inside container" || fail "Apache not responding inside container"
fi

# 7️⃣ Test Apache from host
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200" && pass "Apache responds on host:8080" || fail "Apache not reachable on host"

# 8️⃣ Check host port listening
sudo ss -tulpn | grep -q ":8080" && pass "Host port 8080 listening" || fail "Host port 8080 not listening"

# 9️⃣ Check firewall (simple)
sudo iptables -L -n | grep -q "8080" && warn "Port 8080 in iptables" || pass "No iptables block on 8080"

# 🔟 Remove & recreate container (just check possibility)
docker rm -f "$APACHE_CONTAINER" &>/dev/null && warn "Apache container removed for recreation test" || warn "No Apache container to remove"

# 1️⃣1️⃣ Check Apache Listen config inside container
if [ -n "$APACHE_CONTAINER" ]; then
    LISTEN_PORT=$(docker exec "$APACHE_CONTAINER" grep -i "Listen" /usr/local/apache2/conf/httpd.conf | awk '{print $2}')
    [ "$LISTEN_PORT" == "80" ] && pass "Apache Listen config OK" || fail "Apache Listen port not 80"
fi

# 1️⃣2️⃣ Docker network check
docker network ls &>/dev/null && pass "Docker networks OK" || fail "Docker network issue"

# ---------------- REPORT ----------------
TOTAL=$((PASS + FAIL))
SUCCESS=$((PASS * 100 / TOTAL))
echo ""
echo -e "${YELLOW}================ FINAL REPORT ================${NC}"
echo -e "Total Checks : $TOTAL"
echo -e "${GREEN}Passed       : $PASS${NC}"
echo -e "${RED}Failed       : $FAIL${NC}"
echo -e "${YELLOW}Success Rate : $SUCCESS%${NC}"
echo -e "${YELLOW}=============================================${NC}"
```

#### ✅ How to use:

- SSH into your EC2.

- Paste the script directly into your terminal and press Enter.

- It will run all 12 checks, show logs for the Apache container, and produce a clear report at the end.

---


