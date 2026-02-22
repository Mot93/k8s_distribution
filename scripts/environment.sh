#!/bin/bash

source ./config.env
source $SCRIPTS_DIR/logs.sh

# Check if at least one argument is provided
env=""
if [ $# -ge 1 ]; then
    env=$1
else
    log "ERROR" "The environment wasn't passed"
    exit 1
fi

# Environment
environment="$ENV_DIR/$env"
if [ ! -d "$environment" ]; then
  log "ERROR" "Directory $environment doesn't exists."
  exit 1
fi

log "INFO" "Directory $environment exists."
