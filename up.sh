#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset


USAGE="./up.sh <atc-hostname> <atc-username> <atc-password>"
CF_ATC_HOSTNAME=${1:?$USAGE}
CONCOURSE_ATC_USERNAME=${2:?$USAGE}
CONCOURSE_ATC_PASSWORD=${3:?$USAGE}

#mkdir app/
#
#pushd app
#  ssh-keygen -t rsa -f tsa_host_key -N ''
#  ssh-keygen -t rsa -f worker_key -N ''
#  ssh-keygen -t rsa -f session_signing_key -N ''
#  
#  cp worker_key.pub authorized_worker_keys
#popd

cp atc.sh worker.sh worker.json app/

cf push concourse-atc \
  -c 'bash atc.sh' \
  --hostname $CF_ATC_HOSTNAME \
  -p app/ \
  -b binary_buildpack \
  --no-start \
;

cf push concourse-worker \
  -c 'sleep 5; bash worker.sh' \
  --no-route \
  --health-check-type process \
  -p app/ \
  -b binary_buildpack \
  --no-start \
;

cf create-service elephantsql turtle concourse-postgres
cf bind-service concourse-atc concourse-postgres

cf allow-access concourse-worker concourse-atc --protocol tcp --port 22222

cf set-env concourse-atc CONCOURSE_ATC_USERNAME $CONCOURSE_ATC_USERNAME
cf set-env concourse-atc CONCOURSE_ATC_PASSWORD $CONCOURSE_ATC_PASSWORD
cf set-env concourse-atc CONCOURSE_ATC_PORT 22222
cf start concourse-atc

CONCOURSE_ATC_HOST=$(cf ssh concourse-atc -c 'hostname --ip-address')
cf set-env concourse-worker CONCOURSE_ATC_HOST $CONCOURSE_ATC_HOST
cf set-env concourse-worker CONCOURSE_ATC_PORT 22222
cf start concourse-worker
