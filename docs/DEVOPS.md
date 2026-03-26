# Charlie Cafe - DevOPS 


### 1️⃣ Why You Need .gitignore and .dockerignore

Even though they look similar, they solve two completely different problems.

### 1️⃣ .dockerignore

This file tells Docker which files/folders to ignore when building your image.

#### ✅ Why it’s needed:

Docker copies your project folder into the image. If you don’t ignore unnecessary files, your image becomes huge, slow, and may include sensitive data.
Keeps image clean and small → faster builds, faster deploys.

#### ✅ Your entries explained:

| Entry                | Why ignored                                      |
| -------------------- | ------------------------------------------------ |
| `.git`               | Git history is not needed in container           |
| `.gitignore`         | Not needed inside image                          |
| `node_modules`       | Can rebuild via `npm install` in image if needed |
| `.env`               | Contains sensitive secrets, never put in image   |
| `*.log`              | Runtime logs don’t belong in image               |
| `vendor`             | PHP dependencies; can rebuild if needed          |
| `docker-compose.yml` | Only used on host, not in container              |
| `.github`            | CI/CD workflows not needed in image              |
| `README.md`          | Documentation, not runtime                       |

✅ Result: image only contains what it needs to run.

### 2️⃣ .gitignore

This file tells Git which files/folders to ignore when committing to GitHub.

#### ✅ Why it’s needed:

Prevents committing unnecessary files to repo → keeps repo clean, smaller, and secure.
Avoids committing sensitive files (like .env) and OS junk files (.DS_Store).
Helps teams avoid conflicts with local-only files.

#### ✅ Your entries explained:

| Entry           | Why ignored                        |
| --------------- | ---------------------------------- |
| `node_modules/` | Rebuildable, too large for Git     |
| `vendor/`       | PHP dependencies; can rebuild      |
| `.env`          | Secrets, never push to GitHub      |
| `*.log`         | Runtime logs, not source code      |
| `.DS_Store`     | Mac OS junk file                   |
| `Thumbs.db`     | Windows junk file                  |
| `docker/*.tar`  | Docker images/archives, don’t push |

✅ Result: Git repo stays clean, safe, and professional.

### ⚡ TL;DR — Difference:

| Feature         | Purpose                                                                               |
| --------------- | ------------------------------------------------------------------------------------- |
| `.dockerignore` | Keeps **Docker images small and clean** by ignoring unnecessary files during build    |
| `.gitignore`    | Keeps **Git repo clean and safe**, avoiding committing unnecessary or sensitive files |

### 🖼️ Charlie Cafe DevOps: .gitignore vs .dockerignore

```
charlie-cafe-devops/   <-- Your project root
│
├── .gitignore         <-- Git ignores listed files/folders
├── .dockerignore      <-- Docker ignores listed files/folders
├── .github/
│   └── workflows/
│       └── deploy.yml
├── docker/
│   ├── apache-php/Dockerfile
│   └── mysql/Dockerfile
├── app/
│   ├── frontend/
│   └── backend/
├── infrastructure/
│   └── rds/
│       ├── schema.sql
│       ├── data.sql
│       └── verify.sql
├── docker-compose.yml
├── README.md
└── node_modules/
```

### 🔹 1. How .gitignore works

- Git sees the whole project but ignores files listed in .gitignore

- These files never get pushed to GitHub, keeping your repo clean and secure.

#### Example from Charlie Cafe:

```
.gitignore
├── node_modules/       # big, rebuildable
├── vendor/             # PHP dependencies, rebuildable
├── .env                # secret config
├── *.log               # runtime logs
├── .DS_Store           # macOS junk
├── Thumbs.db           # Windows junk
├── docker/*.tar        # local docker archives
```

✅ Git will track everything else (app code, infrastructure scripts, Dockerfiles, workflow files).

### 🔹 2. How .dockerignore works

- Docker sees the context folder when building an image (normally your repo root)

- Docker ignores files in .dockerignore → they are not copied into the container

#### Example from Charlie Cafe:

```
.dockerignore
.git
.gitignore
node_modules
vendor
.env
*.log
docker-compose.yml
.github
README.md
```

✅ Docker only copies what is needed to run the app (e.g., app/frontend/, app/backend/, maybe infrastructure/rds/ if using SQL files in container).

### 🔹 3. Visual Flow Diagram

```
[ Your Local Repo ]
        │
        │ git push → GitHub
        ▼
[ GitHub Repo ]
        │
        │ Git ignores .gitignore files
        ▼
[ Docker Build Context ]
        │
        │ Docker ignores .dockerignore files
        ▼
[ Docker Image ]
        ├── app/frontend/          ✔ included
        ├── app/backend/           ✔ included
        ├── infrastructure/rds/    ✔ if needed in container
        └── unnecessary files → ❌ not included
```

### 🔹 4. Key Takeaways

- .gitignore → controls what Git tracks

- .dockerignore → controls what Docker includes in images

- Both prevent junk, secrets, and big files from leaking into repo or container

- Using both keeps your Charlie Cafe DevOps project clean, professional, and production-ready

### ✅ 1. Can you ignore folders like AWS IAM Policies/ and docs/?

👉 YES — your syntax is correct

#### In both .dockerignore and .gitignore, you can ignore folders like this:

```
AWS IAM Policies/
docs/
```

#### ✔ This will ignore:

- The folder itself

- All files inside it

- All subfolders

### ⚠️ 2. Important Issue in Your Case (Very Important)

Your folder name has a space:

```
AWS IAM Policies/
```

---

