#!/bin/bash

user=$1
container_name="$2"
package_name="$2"
materialious_url="${3:-http://localhost:3001}"
domain="${4:-example.org}"

git pull

# run docker cli within a limited environment so that the container can initialize itself safely
docker run --privileged --name "$container_name-container" --rm \
    -e "MATERIALIOUS_URL=$materialious_url" \
    -e "DOMAIN=$domain" \
    -v "$(pwd)/$package_name:/app:ro" \
    -v "/$container_name:/$container_name" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -w "/app" -i docker:cli "sh" "/app/run.sh"
