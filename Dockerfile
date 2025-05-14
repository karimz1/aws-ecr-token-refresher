# Enable BuildKit’s TARGETOS/TARGETARCH for multi-arch builds
ARG TARGETOS
ARG TARGETARCH

FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# install Docker CLI, Git, curl, wget, unzip & tar
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      docker.io \
      git \
      curl \
      wget \
      unzip \
      tar \
      awscli \
    && rm -rf /var/lib/apt/lists/*

# clone your ECR-refresh scripts
WORKDIR /scripts
RUN git clone https://github.com/karimz1/AWS-Authentication-Scripts.git ./

# copy over your entrypoint loop
COPY entrypoint.ps1 .

# run the interval-loop in PowerShell
ENTRYPOINT ["pwsh", "-NoLogo", "-NoProfile", "-File", "/scripts/entrypoint.ps1"]
