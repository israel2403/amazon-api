# CI/CD for amazon-api (GitHub Actions + Docker Hub + Local CD on WSL)

This repo was scanned and the following modules/services were detected:

- **Modules**: gateway, eureka-server, users, addresses-service
- **Spring Boot services**: gateway, eureka-server, users, addresses-service
- **Compose file**: `docker-compose.yml` (found)

## What you get

- **CI** (`.github/workflows/ci.yml`): builds each module with Maven, builds Docker images using each module's `Dockerfile`, and pushes to Docker Hub with tags:
  - `${{ secrets.DOCKERHUB_USERNAME }}/<service>:${{ github.sha }}`
  - `${{ secrets.DOCKERHUB_USERNAME }}/<service>:latest`

- **CD** (`.github/workflows/cd.yml`): runs on a **self-hosted runner** in your local **Ubuntu 24.04.1 WSL**. It pulls images from Docker Hub and runs/updates the stack via:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.ci.yml pull
  docker compose -f docker-compose.yml -f docker-compose.ci.yml up -d --remove-orphans
  ```

- **`docker-compose.ci.yml`**: compose override that switches services to use pulled images (from Docker Hub) instead of building locally.

- **`.env.example`**: set `DOCKERHUB_USERNAME` for local compose overrides.

- **`scripts/register-runner.sh`**: helper to register a GitHub Actions **self-hosted runner** in WSL with labels `self-hosted,linux,wsl` (the CD workflow targets these labels).

## How to set it up (one time)

1. **Create GitHub repo** and push your code (this project).

2. In the repo **Settings → Secrets and variables → Actions → New repository secret**, add:
   - `DOCKERHUB_USERNAME` → your Docker Hub username (e.g., `israelhf24`)
   - `DOCKERHUB_TOKEN` → a Docker Hub **Access Token** with `write` permissions

3. (Optional) If you want CD workflow to log in (private repos), keep `DOCKERHUB_TOKEN`. For public images, login is optional.

4. **Register a self-hosted runner** on your WSL box:
   ```bash
   cp scripts/register-runner.sh ~/register-runner.sh
   chmod +x ~/register-runner.sh
   export GH_REPO_URL="https://github.com/<owner>/<repo>"
   export RUNNER_LABELS="self-hosted,linux,wsl"
   export RUNNER_NAME="$(hostname)-wsl"
   # Option A: Use UI to get RUNNER_TOKEN then:
   # export RUNNER_TOKEN="<token from UI>"
   # ~/register-runner.sh
   # Option B: Use API (requires GH_PAT with admin or actions:write):
   # export GH_PAT="<PAT>"
   # ~/register-runner.sh
   ```

   Alternatively, use GitHub UI: Repo → Settings → Actions → Runners → *New self-hosted runner* → follow Linux steps, then add the labels `self-hosted,linux,wsl`.

5. **Prepare local compose**:
   ```bash
   cp .env.example .env
   # edit to set DOCKERHUB_USERNAME=<your-user>
   ```

## Run the pipelines

- **CI**: pushes to any branch will build modules and push images.
- **CD**:
  - Trigger manually from the **Actions** tab via **workflow_dispatch** (recommended the first time), or
  - On push to `main`/`master`, it will run if your runner is online.

The CD job will:
- `docker compose pull` (using `docker-compose.ci.yml` override)
- `docker compose up -d --remove-orphans`

> The base `docker-compose.yml` in this project defines ports and environment variables. The override `docker-compose.ci.yml` only swaps the images to `${DOCKERHUB_USERNAME}/<service>:latest` and disables local builds.

## Notes

- The CI job uses Maven's `-pl <module> -am` to build each module's JAR before image build.
- Images are built from `/<module>/Dockerfile` as detected in your repo:
  - `eureka-server/Dockerfile`
  - `gateway/Dockerfile`
  - `users/Dockerfile`
- If you prefer to pin tags instead of `latest` in CD, edit `docker-compose.ci.yml` to use a specific digest or tag (e.g., the latest successful SHA).

---

Happy shipping! 🚀
