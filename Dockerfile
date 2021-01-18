FROM debian:buster-slim

ARG GITHUB_RUNNER_VERSION="2.275.1"

ENV GITHUB_PAT ""
ENV GITHUB_OWNER ""
ENV RUNNER_WORKDIR "_work"
ENV RUNNER_LABELS ""
ENV RUNNER_NAME_PREFIX "myorg-"

RUN apt-get update \
    && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        gnupg-agent \
        software-properties-common \
        curl \
        git \
        jq

# Install Docker client
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" \
    && apt-get update \
    && apt-get install docker-ce-cli \
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
RUN chmod u+x ./entrypoint.sh
ENTRYPOINT ["/home/github/entrypoint.sh"]
