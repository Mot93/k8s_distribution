#!/bin/bash

source scripts/error.sh

# Check if environemnt was passed
env=""
if [ $# -ge 1 ]; then
    env=$1
else
    echo "The environment wasn't passed"
    exit 1
fi

# Check if prefix was passed
prefix="/"
if [ $# -ge 2 ]; then
    prefix="/$2"
fi

# Environment
environment="environments/$env"
if [ ! -d "$environment" ]; then
  echo "Directory $environment does exist."
  exit 1
fi

# JSON with all the configurations
json_helm="$environment/helm.json"
if [ ! -f $json_helm ]; then
   echo "$json_helm is missing"
   exit 2
fi

# Error logs
timestamp=$(date '+%Y%m%d%H%M%S')
error_file="$environment/logs/helm_$timestamp"

# Authenticate to each destination repos
destinations=()
jq -c '.destinations[]' $json_helm | while read -r item; do
    auth=$(echo "$item" | jq -r '.auth')
    url=$(echo "$item" | jq -r '.url')
    destinations+=( "$url" )
    if [[ "null" != "$auth" ]] then
        eval $auth
    fi
done
# Authenticate and add repos hosting helm charts
jq -c '.repos[]' $json_helm | while read -r item; do
    name=$(echo "$item" | jq -r '.name')
    url=$(echo "$item" | jq -r '.url')
    auth=$(echo "$item" | jq -r '.auth')
    # Auth if it was specified
    if [[ "null" != "$auth" ]] then
        eval $auth
    fi
    helm repo add $name $url
done
helm repo update

# tmp folder where to store all the charts before upload
tmp_chart="$environment/.tmp"
mkdir -p $tmp_chart

# Download charts
mkdir -p $tmp_chart
jq -c '.charts[]' $json_helm | while read -r item; do
    name=$(echo "$item" | jq -r '.name')
    version=$(echo "$item" | jq -r '.version')
    repo=$(echo "$item" | jq -r '.repo')
    helm pull $repo/$name --version $version --destination $tmp_chart
done

# Copy local charts to tmp
local_chart="$environment/local"
for file in "$local_chart"/*; do
    if [ -f "$file" ]; then
        cp "$file" "$tmp_chart/"
    fi
done

# Upload the charts from the tmp folder
for file in "$tmp_chart"/*; do   
    jq -c '.destinations[]' $json_helm | while read -r item; do
        url=$(echo "$item" | jq -r '.url')
        echo "push $file $url$prefix"
        helm push $file $url$prefix
    done
done

# Removing tmp folder
rm -rf $tmp_chart
