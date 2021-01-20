FROM debian:buster-slim

ARG GITHUB_RUNNER_VERSION="2.276.0"

ENV GITHUB_PAT ""
ENV GITHUB_OWNER ""
ENV RUNNER_WORKDIR "_work"
ENV RUNNER_LABELS ""
ENV RUNNER_NAME_PREFIX "myorg-"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        apt-transport-https=1.8.2.2 \
        ca-certificates=20200601~deb10u1 \
        gnupg=2.2.12-1+deb10u1 \
        gnupg-agent=2.2.12-1+deb10u1 \
        software-properties-common=0.96.20.2-2 \
        curl=7.64.0-4+deb10u1 \
        git=1:2.20.1-2+deb10u3 \
        jq=1.5+dfsg-2+b1 \
    && rm -rf /var/lib/apt/lists/*

# Install Docker client
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" \
    && apt-get update \
    && apt-get install docker-ce-cli=5:20.10.2~3-0~debian-buster --no-install-recommends -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m github

WORKDIR /home/github

# Install github runner packages
RUN curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz \
    && ./bin/installdependencies.sh \
    && chown -R github:github /home/github

USER github

# Entrypoint
COPY --chown=github:github entrypoint.sh ./entrypoint.sh
ENTRYPOINT ["/home/github/entrypoint.sh"]
