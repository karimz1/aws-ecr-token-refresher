

# AWS ECR Token Refresher

> A lightweight sidecar that keeps your host Docker daemon **permanently authenticated** to Amazon Elastic Container Registry (ECR). Works out of the box with any tooling that relies on plain Basic Auth — such as [Watchtower](https://github.com/containrrr/watchtower), CI runners, GitOps agents, or manual `docker pull`s.

[![Deployment for aws-ecr-token-refresher to Docker Hub](https://github.com/karimz1/aws-ecr-token-refresher/actions/workflows/deploy.yml/badge.svg)](https://github.com/karimz1/aws-ecr-token-refresher/actions/workflows/deploy.yml)
[![License](https://img.shields.io/github/license/karimz1/aws-ecr-token-refresher?style=flat-square)](LICENSE)
[![Docker pulls](https://img.shields.io/docker/pulls/karimz1/aws-ecr-token-refresher?style=flat-square)](https://hub.docker.com/r/karimz1/aws-ecr-token-refresher)
[![Image size](https://img.shields.io/docker/image-size/karimz1/aws-ecr-token-refresher/latest?style=flat-square)](https://hub.docker.com/r/karimz1/aws-ecr-token-refresher/tags)

## 🚀 Why do I need this?

ECR issues login tokens that expire every **12 hours**. The official [amazon‑ecr‑credential‑helper](https://github.com/awslabs/amazon-ecr-credential-helper) renews the token transparently for most workflows, but some clients (for example Watchtower) perform extra manifest calls *before* the pull. They end up hitting the registry without fresh credentials and fail with:

```
no basic auth credentials
```

**AWS ECR Token Refresher** refreshes the token proactively on a schedule you control and writes it to `~/.docker/config.json` on the host. Any process that talks to the local Docker socket therefore sees valid credentials — no code changes, no wrapper scripts, no `aws ecr get-login-password` gymnastics.

## 🧰 Features

- Bundles official **AWS CLI v2** — nothing to install on the host
- Supports any AWS account and region
- Configurable refresh interval (default **8 h**, well inside the 12 h expiry window)
- Zero‑downtime rotation — ongoing pulls keep working
- Verbose logs for easy troubleshooting

## ⚡ Quick start

### 1 — Drop into your `docker-compose.yml`

``` yml
services:
  aws-ecr-token-refresher:
    image: docker.io/karimz1/aws-ecr-token-refresher:latest
    restart: always
    environment:
      AWS_ACCOUNT_ID:        ${AWS_ACCOUNT_ID}
      AWS_ACCESS_KEY_ID:     ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      AWS_REGION:            ${AWS_REGION}
      INTERVAL_SECONDS:      ${INTERVAL_SECONDS}
    volumes:
      # write credentials here ⤵
      - ${HOME}/.docker:/root/.docker
      # talk to the host Docker daemon
      - /var/run/docker.sock:/var/run/docker.sock
```

Bring it up:

```
docker compose up -d
```

From now on **any** container on the host can pull from private ECR repositories seamlessly.

### 2 — Example: Watchtower auto‑updates

``` yml
services:
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${HOME}/.docker:/config/.docker  # <-- mount Docker config
    environment:
      - DOCKER_CONFIG=/config/.docker
    command: --label-enable --cleanup --interval 300 --rolling-restart
```

No extra flags — Watchtower now pulls images with the freshly rotated credentials.

## 🔧 Configuration reference

| Variable                | Required | Default | Description                                             |
| ----------------------- | -------- | ------- | ------------------------------------------------------- |
| `AWS_ACCOUNT_ID`        | ✖        | —       | AWS Account ID, if not supplied, retrieved via STS  |
| `AWS_ACCESS_KEY_ID`     | ✔        | —       | IAM user/role key with `ecr:GetAuthorizationToken`      |
| `AWS_SECRET_ACCESS_KEY` | ✔        | —       | Secret for the above key                                |
| `AWS_REGION`            | ✔        | —       | Primary region of your ECR repositories                 |
| `INTERVAL_SECONDS`      | ✖        | `28800` | How often to refresh (seconds). Should be ≤ 43200 (12 h). |

*The container exits if any required variable is missing.*

## 📜 License

Apache‑2.0 © 2025 Karim Zouine

## 🤝 Acknowledgements

- [amazon‑ecr‑credential‑helper](https://github.com/awslabs/amazon-ecr-credential-helper) — design inspiration
- [Watchtower](https://github.com/containrrr/watchtower) — seamless container auto‑updates