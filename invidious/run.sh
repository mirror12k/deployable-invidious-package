#!/bin/bash
set -e

INVIDIOUS_ROOT="/invidious"
INVIDIOUS_DATA="${INVIDIOUS_ROOT}/invidious_data"
CADDY_DATA="${INVIDIOUS_ROOT}/caddy_data"

echo "[i] cleaning up old data..."
rm -rf "$INVIDIOUS_DATA"
rm -rf "$CADDY_DATA"

echo "[i] cloning invidious git to ${INVIDIOUS_DATA}..."
git clone https://github.com/iv-org/invidious.git "$INVIDIOUS_DATA"

DOMAIN="${DOMAIN:-example.org}"
MATERIALIOUS_URL="${MATERIALIOUS_URL:-http://localhost:3001}"
RANDOM_HMAC_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 64)
RANDOM_COMPANION_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)

echo "[i] preparing docker-compose..."
cat /app/docker-compose.yml.template \
	| sed "s#{my_hmac_key}#$RANDOM_HMAC_KEY#g" \
	| sed "s#{my_companion_key}#$RANDOM_COMPANION_KEY#g" \
	| sed "s#{domain}#$DOMAIN#g" \
	> "$INVIDIOUS_DATA/docker-compose.yml"

echo "[i] preparing Caddyfile with MATERIALIOUS_URL=$MATERIALIOUS_URL..."
mkdir -p "$CADDY_DATA"
cat /app/Caddyfile.template \
	| sed "s#{materialious_url}#$MATERIALIOUS_URL#g" \
	> "$CADDY_DATA/Caddyfile"

# cat "$INVIDIOUS_DATA/docker-compose.yml"

cd "$INVIDIOUS_DATA"

echo "[i] killing any old images"
docker-compose down
echo "[i] pulling images"
docker-compose pull
echo "[i] uping invidious docker..."
docker-compose up
