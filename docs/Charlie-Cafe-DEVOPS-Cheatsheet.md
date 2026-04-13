# ☕ Charlie Cafe — DevOps Command Cheat Sheet

## 📦 1. GIT / GITHUB COMMANDS

### 🔹 Clone Repository

```
git clone https://github.com/<username>/<repo>.git
```

👉 Purpose: Download project from GitHub

### 🔹 Check Status

```
git status
```

👉 Purpose: See modified/untracked files

### 🔹 Add Files

```
git add .
```

👉 Purpose: Stage all changes

### 🔹 Commit Changes

```
git commit -m "your message"
```

👉 Purpose: Save changes locally

### 🔹 Push to GitHub

```
git push origin main
```

👉 Purpose: Upload code to GitHub

### 🔹 Pull Latest Code

```
git pull origin main
```

👉 Purpose: Get latest updates from GitHub

### 🔹 Reset Local Code (DANGER)

```
git reset --hard origin/main
```

👉 Purpose: Force sync with GitHub (deletes local changes)

### 🔹 View Logs

```
git log --oneline
```

👉 Purpose: Show commit history

---
## 🐳 2. DOCKER COMMANDS

### 🔹 Build Docker Image

```
docker build -t charlie-cafe -f docker/apache-php/Dockerfile .
```

👉 Purpose: Create Docker image from Dockerfile

### 🔹 Build Without Cache

```
docker build --no-cache -t charlie-cafe -f docker/apache-php/Dockerfile .
```

👉 Purpose: Force rebuild everything

### 🔹 List Images

```
docker images
```

👉 Purpose: Show available images

### 🔹 Run Container

```
docker run -d -p 80:80 --name cafe-app charlie-cafe
```

👉 Purpose: Start app container

### 🔹 List Running Containers

```
docker ps
```

👉 Purpose: Show active containers

### 🔹 Enter Container

```
docker exec -it cafe-app bash
```

👉 Purpose: Access container shell

### 🔹 View Logs

```
docker logs cafe-app
```

👉 Purpose: Debug container issues

### 🔹 Stop Container

```

```





