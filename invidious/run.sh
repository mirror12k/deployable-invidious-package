#!/bin/bash
set -e

echo "[i] cloning invidious git"
tmp_dir=$(mktemp -d)
git clone https://github.com/iv-org/invidious.git "$tmp_dir/invidious"

DOMAIN="example.org"
RANDOM_HMAC_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 64)
RANDOM_COMPANION_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
echo "[i] preparing docker-compose ($VISITOR_DATA / $PO_TOKEN)..."
cat docker-compose.yml.template \
	| sed "s#{my_hmac_key}#$RANDOM_HMAC_KEY#g" \
	| sed "s#{my_companion_key}#$RANDOM_COMPANION_KEY#g" \
	| sed "s#{domain}#$DOMAIN#g" \
	> "$tmp_dir/invidious/docker-compose.yml"

cat "$tmp_dir/invidious/docker-compose.yml"

cd "$tmp_dir/invidious"

echo "[i] pulling images"
docker-compose pull
echo "[i] uping invidious docker..."
docker-compose up
