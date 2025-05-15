ARG TARGETOS
ARG TARGETARCH

FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

LABEL maintainer="Karim Zouine <mails.karimzouine@gmail.com>"
LABEL version="1.0.0"
LABEL description="Sidecar that auto-refreshes AWS ECR tokens and keeps Docker pulls authenticated."

LABEL org.opencontainers.image.title="aws-ecr-token-refresher"
LABEL org.opencontainers.image.description="idecar that auto-refreshes AWS ECR tokens and keeps Docker pulls authenticated."
LABEL org.opencontainers.image.url="https://github.com/karimz1/aws-ecr-token-refresher"
LABEL org.opencontainers.image.source="https://github.com/karimz1/aws-ecr-token-refresher"
LABEL org.opencontainers.image.documentation="https://github.com/karimz1/aws-ecr-token-refresher/blob/main/README.md"
LABEL org.opencontainers.image.licenses="Apache-2.0 license"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      docker.io \
      git \
      awscli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /scripts
RUN git clone https://github.com/karimz1/AWS-Authentication-Scripts.git ./
RUN rm -rf /scripts/.git
COPY entrypoint.ps1 .

ENTRYPOINT ["pwsh", "-NoLogo", "-NoProfile", "-File", "/scripts/entrypoint.ps1"]
