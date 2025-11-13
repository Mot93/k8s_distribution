#!/bin/bash

# Check if at least one argument is provided
env=""
if [ $# -ge 1 ]; then
    env=$1
else
    echo "The environment wasn't passed"
    exit 1
fi

# Environment
environment="environments/$env"
if [ -d "$environment" ]; then
  echo "Directory $environment does exist."
  exit 1
fi

# JSON with all the configurations
json_container="$environment/container.json"
if [ ! -f $json_container ]; then
   echo "$json_containerjson_helm is missing"
   exit 2
fi

# Error logs
timestamp=$(date '+%Y%m%d%H%M%S')
error_file="$environment/logs/helm_$timestamp"

# Authenticate to each destination registry
destinations=()
jq -c '.destinations[]' $json_container | while read -r item; do
    auth=$(echo "$item" | jq -r '.auth')
    url=$(echo "$item" | jq -r '.url')
    destinations+=( "$url" )
    if [[ "null" != "$auth" ]] then
        eval $auth
    fi
done
# Authenticate to registry to download from
jq -c '.repos[]' $json_helm | while read -r item; do
    auth=$(echo "$item" | jq -r '.auth')
    eval $auth
done

# Moving container from a registry to another
jq -c '.containers[]' $json_helm | while read -r item; do
    name=$(echo "$item" | jq -r '.name')
    tag=$(echo "$item" | jq -r '.tag')
    registry=$(echo "$item" | jq -r '.registry')
    $origin="$registry/$name:$tag"
    docker pull $origin
    $destination=""
    for item in $destinations; do
        url=$(echo "$item" | jq -r '.url')
        $destination="$url/$name:$tag"
        docker tag $origin $destination
        docker push $destination
        docker image rm $destination
    done
    docker image rm $origin
done
