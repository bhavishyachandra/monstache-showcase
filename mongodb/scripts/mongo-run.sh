#!/bin/bash

set -m

./mongo-users-setup.sh

mongodb_cmd="mongod"

cmd="$mongodb_cmd"

cmd="$cmd --auth"
cmd="$cmd --storageEngine wiredTiger"
cmd="$cmd --oplogSize 128"

cmd="$cmd --bind_ip 0.0.0.0"

if [[ "$MONGO_REPLICA_SET_NAME" ]]; then
  cmd="$cmd --replSet $MONGO_REPLICA_SET_NAME"
fi

cmd="$cmd --dbpath /data/db"

$cmd &
./mongo-rep-set-setup.sh

./mongo-db-setup.sh

MONGO_CONTAINER_HEALTHCHECK_FILE_PATH=${MONGO_CONTAINER_HEALTHCHECK_FILE_PATH:-/data/health.check}
echo '1' >>"$MONGO_CONTAINER_HEALTHCHECK_FILE_PATH"

fg
