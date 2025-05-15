ARG TARGETOS
ARG TARGETARCH

FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

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

WORKDIR /scripts
RUN git clone https://github.com/karimz1/AWS-Authentication-Scripts.git ./
COPY entrypoint.ps1 .

ENTRYPOINT ["pwsh", "-NoLogo", "-NoProfile", "-File", "/scripts/entrypoint.ps1"]
