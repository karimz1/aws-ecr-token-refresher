# AWS ECR Token Refresher

A simple Docker container that keeps your AWS ECR credentials up to date. Once running, it fetches fresh ECR tokens automatically and injects them into your host’s Docker config—no repeated `docker login` needed.

## Why use it?

ECR authorization tokens expire every 12 hours, which can interrupt long-running workflows:

- **[Watchtower](https://github.com/containrrr/watchtower)** auto-updates of private images
- **CI/CD pipelines** pulling from ECR
- **Cron jobs** or background services on your servers

AWS offers the [amazon-ecr-credential-helper](https://github.com/awslabs/amazon-ecr-credential-helper) to streamline logins, but it only hooks into `docker pull`—leaving manifest fetches (used by Watchtower and similar tools) unprotected and prone to “no basic auth credentials” errors.

**ECR Token Refresher** solves this by periodically fetching fresh ECR tokens and writing them directly into your host’s `~/.docker/config.json`. This guarantees valid credentials for both manifest requests and image pulls across all your Docker-based services.

## How to use

Create a simple `docker-compose.yml` in your project folder to start **ECR Token Refresher** as a sidecar service:

```yaml
services:
  ecr-token-refresher:
    build: 
      context: .
    environment:
      AWS_ACCESS_KEY_ID:     ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      AWS_REGION:            ${AWS_REGION}
      INTERVAL_SECONDS:      ${INTERVAL_SECONDS}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${HOME}/temp/ecr-token-refresher:/root/.docker
      - ${HOME}/temp/ecr-token-refresher/Logs:/scripts/Logs
```

Start it in the background:

```bash
docker-compose up -d
```

### Using with other services

Since **ECR Token Refresher** writes tokens directly into your host’s Docker config, **any** Docker-based workflow will automatically pick up fresh ECR credentials. Examples:

- **Watchtower** for auto-updating containers
- **CI/CD pipelines** in Docker runners
- **Cron jobs** or long-running servers pulling private images

No extra login steps are needed—just ensure your other services share the same host Docker config.

---

_ECR Token Refresher—keeping your private ECR pulls alive alongside Watchtower and more._
