#!/bin/sh
# Railway boot wrapper for gethomepage/homepage.
# Seeds the starter config into the volume on first boot, then hands off to
# the untouched upstream entrypoint (PUID/PGID handling, IPv6 bind probing).

set -e

if [ ! -e /app/config/settings.yaml ]; then
  mkdir -p /app/config
  cp -r /app/config.seed/. /app/config/
  echo "[railway-seed] Starter config copied to /app/config"
else
  echo "[railway-seed] Existing config found in /app/config — seeding skipped"
fi

exec docker-entrypoint.sh "$@"
