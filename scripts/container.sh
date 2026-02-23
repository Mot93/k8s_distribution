#!/bin/bash

source ./config.env
source $SCRIPTS_DIR/logs.sh

if [ ! -d "$LOG_DIR" ]; then
  echo "LOG_DIR $LOG_DIR doesn't exist."
  exit 1
fi

# Get the current timestamp in YYYY-MM-DDD format
timestamp=$(date +"%Y-%m-%d")
log_file="$LOG_DIR/error-$timestamp.log"

# Check if at least one argument is provided
env=""
if [ $# -ge 1 ]; then
  env=$1
else
  log "ERROR" "The environment wasn't passed" $log_file
  exit 1
fi

# Environment
environment="$ENV_DIR/$env"
if [ ! -d "$environment" ]; then
  log "ERROR" "Directory $environment doesn't exists." $log_file
  exit 1
fi

# Defining log file
log_file="$LOG_DIR/$env-$timestamp.log"

log "INFO" "Working on $environment" $log_file

# Check if the configuration files exists
config_file="$environment/containers.yaml"
if [ ! -f $config_file ]; then
  log "ERROR" "The configuration file $config_file does not exists." $log_file
  exit 1
fi

log "INFO" "Config file found: $config_file" $log_file

# Get all the destination where to push containers
destinations_field=".destinations"
destinations=$(yq $destinations_field[] $config_file)
if [ -z "$destinations" ]; then
  log "ERROR" "List not found at path '$destinations_field' in $config_file." $log_file
  exit 1
fi
# Check there is at least one destination
destinations_count=$(yq "$destinations_field | length" $config_file)
if [ $destinations_count -eq 0 ]; then
  log "ERROR" "There has to be at least 1 destination" $log_file
  exit 1
fi

log "INFO" "Found $destinations_count destinations." $log_file

# TODO: required fields check
# required_char=("name" "tag" "registry")

# Read the list of containers to ship
containers_field=".containers"
containers=$(yq eval $containers_field $config_file)
if [ -z "$destinations" ]; then
  log "ERROR" "List not found at path '$containers_field' in $config_file." $log_file
  exit 1
fi
# Check there is at least one container
containers_count=$(yq e "$containers_field | length" "$config_file")
if [ $containers_count -eq 0 ]; then
  log "ERROR" "There has to be at least 1 container to ship" $log_file
  exit 1
fi

log "INFO" "Found $containers_count containers." $log_file

for ((i=0; i<containers_count; i++)); do
  # Getting all the attributes
  name=$( yq $containers_field[$i].name $config_file )
  tag=$( yq $containers_field[$i].tag $config_file )
  registry=$( yq $containers_field[$i].registry $config_file )
  # TODO: Check if the atributes exists
  # Container
  origin_container="$registry/$name:$tag"
  # Pull
  pull="docker pull $origin_container"
  eval $pull
  exit_code=$?
  if [ ! $exit_code -eq 0 ]; then
    log "ERROR" "Couldn't pull $origin_container" $log_file
    continue
  fi
  log "INFO" "Pulled container $origin_container" $log_file
  # Loop over all destinations
  for dest in $destinations; do
    # Destination container
    dest_container="$dest/$name:$tag"
    # Tag
    tagging="docker tag $origin_container $dest_container"
    echo $tagging
    eval $tagging
    exit_code=$?
    if [ ! $exit_code -eq 0 ]; then
      log "ERROR" "Couldn't tag $origin_container into $dest_container" $log_file
      continue
    fi
    log "INFO" "Tagged container $origin_container into $dest_container" $log_file
    # Push
    push="docker push $dest_container"
    eval $push
    exit_code=$?
    if [ ! $exit_code -eq 0 ]; then
      log "ERROR" "Couldn't push $dest_container" $log_file
      continue
    fi
    log "INFO" "Pushed container $dest_container" $log_file
    # Delete destination
    delete="docker image rm $dest_container"
    eval $push
    exit_code=$?
    if [ ! $exit_code -eq 0 ]; then
      log "ERROR" "Couldn't delete $dest_container" $log_file
      continue
    fi
    log "INFO" "Delete container $dest_container" $log_file
  done
  # Delete origin
  delete="docker image rm $origin_container"
  eval $push
  exit_code=$?
  if [ ! $exit_code -eq 0 ]; then
    log "ERROR" "Couldn't delete $origin_container" $log_file
    continue
  fi
  log "INFO" "Delete container $origin_container" $log_file
done

log "INFO" "The end." $log_file
