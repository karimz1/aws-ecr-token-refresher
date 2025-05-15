# AWS ECR Token Refresher

> A drop‑in sidecar that keeps your host Docker daemon authenticated
> to **Amazon Elastic Container Registry (ECR)** — even for tools that
> rely on plain Basic Auth such as [Watchtower](https://github.com/containrrr/watchtower), CI runners, or ad‑hoc
> `docker pull`s.

## 🚀 Problem & solution

AWS ECR tokens expire every 12 hours.
The official [amazon‑ecr‑credential‑helper](https://github.com/awslabs/amazon-ecr-credential-helper) renews tokens **only when
`docker` itself makes an image request**, which is fine for most pulls
but fails when a third‑party client performs additional manifest
requests before the pull (e.g. Watchtower).
“no basic auth credentials” errors break your automated updates.

**ECR Token Refresher** runs the AWS CLI in a lightweight container on a
configurable schedule, logs in to ECR, and persists the credentials to
the host’s `~/.docker/config.json`.
Anything that talks to your local Docker socket will therefore see
fresh Basic Auth credentials—no code changes, no custom scripts,
no `aws ecr get-login-password` headaches.

## 🧰 Features

- Bundled official `awscli` (v2) — nothing to install on the host
- Works with *any* ECR‑enabled region or account
- Pluggable refresh interval (default **5 min**)
- Zero‑downtime rotation; existing pulls keep working
- Verbose logging for easy troubleshooting

## ⚡ Quick start

### 1 — Add to `docker-compose.yml`

```yaml
services:
  ecr-token-refresher:
    image: ghcr.io/<your-org>/ecr-token-refresher:latest
    restart: unless-stopped
    environment:
      AWS_ACCESS_KEY_ID:     ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      AWS_REGION:            ${AWS_REGION:-eu-central-1}
      # Optional — defaults to 300 seconds
      INTERVAL_SECONDS:      ${INTERVAL_SECONDS:-300}
    volumes:
      # write credentials here ⤵
      - ${HOME}/.docker:/root/.docker
      # talk to the host Docker daemon
      - /var/run/docker.sock:/var/run/docker.sock
```

Spin it up:

```bash
docker compose up -d ecr-token-refresher
```

That’s it! From now on **every** container on this host can pull
private ECR images automatically.

### 2 — Update containers with Watchtower

```yaml
services:
  watchtower:
    image: containrrr/watchtower
    restart: unless-stopped
    environment:
      WATCHTOWER_CLEANUP: 'true'
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${HOME}/.docker:/config     # same creds file
```

No extra flags required—Watchtower is happy because the manifest
requests now carry valid Basic Auth.

## 🔧 Configuration

| Variable                | Default | Description                                       |
| ----------------------- | ------- | ------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | —       | IAM user or role with `ecr:GetAuthorizationToken` |
| `AWS_SECRET_ACCESS_KEY` | —       | Secret for the above key                          |
| `AWS_REGION`            | —       | Primary region of your ECR repositories           |
| `INTERVAL_SECONDS`      | `300`   | How often to refresh the token (min = 60)         |

*The container will exit if any mandatory variable is missing.*

## 🔒 Security notes

- Mount *only* the Docker socket and the credentials volume that you
  need.
- Use an IAM user/role restricted to
  `ecr:GetAuthorizationToken` **and** the specific registries you need.
- Consider AWS session tokens or [IAM Roles Anywhere](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_anywhere.html) for short‑lived
  credentials in on‑prem environments.

## 📜 License

Apache‑2.0 © 2025 Karim Zouine.

## 🤝 Acknowledgements

- [amazon‑ecr‑credential‑helper](https://github.com/awslabs/amazon-ecr-credential-helper) — inspiration & reference
- [Watchtower](https://github.com/containrrr/watchtower) — seamless container auto‑updates
