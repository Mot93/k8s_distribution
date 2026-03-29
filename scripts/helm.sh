#!/bin/bash

set -euo pipefail # Exit immediately if any command fails, if an unset variable is used or if any command in the pipeline fails

source $DIR_SCRIPTS/logs.sh

# Config
log_file=$(log_file_name "$DIR_LOGS/helm")

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
log_file=$(log_file_name "$DIR_LOGS/helm_${configs_name}")

log "INFO" "Working on $configs_path" $log_file
log_info "Working on $configs_path"

# Check if prefix was passed
prefix="/"
if [ $# -ge 2 ]; then
    prefix="/$2"
fi

log "INFO" "Storing charts with prefix $prefix" $log_file

# Check if the configuration files exists
config_file="$configs_path/helm.yaml"
if [ ! -f $config_file ]; then
  log "ERROR" "The configurations file $config_file does not exists." $log_file
  exit 1
fi

log "INFO" "Config file found: $config_file" $log_file

# Get all the destination where to push charts
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

# Read the list of charts to ship
charts_field=".charts"
charts=$(yq eval $charts_field $config_file)
if [ -z "$destinations" ]; then
  log "ERROR" "List not found at path '$charts_field' in $config_file." $log_file
  exit 1
fi
# Check there is at least one chart
charts_count=$(yq e "$charts_field | length" "$config_file")
if [ $charts_count -eq 0 ]; then
  log "ERROR" "There has to be at least 1 chart to ship" $log_file
  exit 1
fi

# tmp folder where to store all the charts before upload
tmp_chart="$configs_path/.tmp"
mkdir -p $tmp_chart

# Download charts
for ((i=0; i<charts_count; i++)); do
    name=$(yq $charts_field[$i].name $config_file)
    version=$(yq $charts_field[$i].version $config_file)
    repo=$(yq $charts_field[$i].repo $config_file)
    if [[ "$name" == "null" || "$version" == "null" || "$repo" == "null" ]]; then
      log_error "One or more variables of the element $i in the list \"charts\" are null or unset. name: $name version: $version repo: $repo"
      exit 1
    fi
    pull="helm pull $name --repo $repo --version $version --destination $tmp_chart"
    log_info "$pull"
    eval $pull
    exit_code=$?
    if [ ! $exit_code -eq 0 ]; then
      log_error "Could not pull the chart"
    fi
    log_info "Chart $name pulled"
done

log "INFO" "Downloaded charts into .tmp folder" $log_file

# Copy local charts to tmp
local_chart="$configs_path/charts"
for file in "$local_chart"/*; do
    if [ -f "$file" ]; then
        cp "$file" "$tmp_chart/"
    fi
done

log "INFO" "Copied local charts into .tmp folder" $log_file

# Upload all the charts from the tmp folder
for file in "$tmp_chart"/*; do   
    yq -c '.destinations[]' $config_file | while read -r item; do
        url=$(echo "$item" | yq -r '.url')
        push="helm push $file $url$prefix"
        log_info "$push"
        eval $push
        exit_code=$?
        if [ ! $exit_code -eq 0 ]; then
          log_error "Could not push the chart "
        fi
        log_info "Uploaded chart $file"
    done
done

# Removing tmp folder
rm -rf $tmp_chart

log_success "---> Charts uploaded <---"
