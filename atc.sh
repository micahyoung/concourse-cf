#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

DATABASE_URL=$(jq -r '.elephantsql[0].credentials.uri' <(echo $VCAP_SERVICES))

: ${CONCOURSE_ATC_PORT:?"!"}
: ${CONCOURSE_ATC_USERNAME:?"!"}
: ${CONCOURSE_ATC_PASSWORD:?"!"}
: ${DATABASE_URL:?"!"}

curl -L https://github.com/micahyoung/concourse-cf-houdini/releases/download/0.0.1/concourse-2.7.7.xz | xz -d > concourse
chmod +x concourse

./concourse web \
  --basic-auth-username $CONCOURSE_ATC_USERNAME \
  --basic-auth-password $CONCOURSE_ATC_PASSWORD \
  --session-signing-key session_signing_key \
  --bind-port $PORT \
  --tsa-host-key tsa_host_key \
  --tsa-bind-port $CONCOURSE_ATC_PORT \
  --tsa-authorized-keys authorized_worker_keys \
  --postgres-data-source "$DATABASE_URL" \
  --external-url http://my-ci.example.com

