#!/bin/bash

set -euo pipefail # Exit immediately if any command fails, if an unset variable is used or if any command in the pipeline fails

source $DIR_SCRIPTS/logs.sh

# Config
log_file=$(log_file_name "$DIR_LOGS/containers")

# Check if at least one argument is provided
if [ $# -ge 1 ]; then
  configs_path=$1
  if [ ! -d "$configs_path" ]; then
    log "ERROR" "Directory $configs_path doesn't exists." $log_file
    exit 2
  else
    configs_path=$(realpath $configs_path)
    configs_name=$(basename "$configs_path")
    log "INFO" "Config folder name $configs_name" $log_file
  fi
else
  log "ERROR" "The configurations folder wasn't passed" $log_file
  exit 1
fi

# Defining log file
log_file=$(log_file_name "$DIR_LOGS/containers_${configs_name}")

log "INFO" "Working on $configs_path" $log_file

# Check if the configuration files exists
config_file="$configs_path/containers.yaml"
if [ ! -f $config_file ]; then
  log "ERROR" "The configurations file $config_file does not exists." $log_file
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
  exit_code=0
  # Getting all the attributes
  name=$( yq $containers_field[$i].name $config_file )
  tag=$( yq $containers_field[$i].tag $config_file )
  registry=$( yq $containers_field[$i].registry $config_file )
  if [[ "$name" == "null" || "$tag" == "null" || "$registry" == "null" ]]; then
    log "ERROR" "One or more variables of the element $i in the list \"containers\" are null or unset. name: $name tag: $tag registry: $registry" $log_file
    exit 1
  fi
  # Container
  origin_container="$registry/$name:$tag"
  # Pull
  pull="docker pull $origin_container"
  eval $pull || exit_code=$?
  if [ $exit_code -ne 0 ]; then
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
    eval $tagging || exit_code=$?
    if [ ! $exit_code -eq 0 ]; then
      log "ERROR" "Couldn't tag $origin_container into $dest_container" $log_file
      continue
    fi
    log "INFO" "Tagged container $origin_container into $dest_container" $log_file
    # Push
    push="docker push $dest_container"
    eval $push || exit_code=$?
    if [ ! $exit_code -eq 0 ]; then
      log "ERROR" "Couldn't push $dest_container" $log_file
      continue
    fi
    log "INFO" "Pushed container $dest_container" $log_file
    # Delete destination
    delete="docker image rm $dest_container"
    eval $push || exit_code=$?
    if [ ! $exit_code -eq 0 ]; then
      log "ERROR" "Couldn't delete $dest_container" $log_file
      continue
    fi
    log "INFO" "Delete container $dest_container" $log_file
  done
  # Delete origin
  delete="docker image rm $origin_container"
  eval $push || exit_code=$?
  if [ ! $exit_code -eq 0 ]; then
    log "ERROR" "Couldn't delete $origin_container" $log_file
    continue
  fi
  log "INFO" "Deleted container $origin_container" $log_file
done

log "SUCCESS" "---> Containers uploaded <---" $log_file
