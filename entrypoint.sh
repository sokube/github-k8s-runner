#!/bin/sh
registration_url="https://github.com/${GITHUB_OWNER}"
token_url="https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/registration-token"

echo "# Requesting runner registration token for ${GITHUB_OWNER} at '${token_url}'"
payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PAT}" ${token_url})
RUNNER_TOKEN=$(echo $payload | jq .token --raw-output)

./config.sh \
    --name ${RUNNER_NAME_PREFIX}$(hostname) \
    --token ${RUNNER_TOKEN} \
    --url ${registration_url} \
    --work ${RUNNER_WORKDIR} \
    --labels ${RUNNER_LABELS} \
    --unattended \
    --replace

remove() {
    payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PAT}" ${token_url%/registration-token}/remove-token)
    REMOVE_TOKEN=$(echo $payload | jq .token --raw-output)

    ./config.sh remove --unattended --token "${REMOVE_TOKEN}"
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./run.sh "$*" &

wait $!
