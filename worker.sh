#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

: ${CONCOURSE_ATC_HOST:?"!"}
: ${CONCOURSE_ATC_PORT:?"!"}

curl -L https://github.com/micahyoung/concourse-cf-houdini/releases/download/0.0.1/houdini-8dda540.xz | xz -d > houdini
chmod +x houdini

./houdini &
ssh -p $CONCOURSE_ATC_PORT $CONCOURSE_ATC_HOST -i worker_key -o 'StrictHostKeyChecking no' -R 0.0.0.0:0:127.0.0.1:7777 forward-worker < worker.json
