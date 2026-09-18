# Homepage (gethomepage.dev) on Railway.
#
# Pinned to the upstream release v2.4.0 (published 2026-09-17).
# v2.0+ ships built-in authentication (HOMEPAGE_AUTH_* envs), which is why
# no auth proxy is needed on Railway.
FROM ghcr.io/gethomepage/homepage:v2.4.0

# A mounted Railway volume starts empty and shadows image content at the
# mount path, so the starter config cannot live in /app/config directly.
# It ships in /app/config.seed and the boot wrapper copies it into the
# volume exactly once (existing files are never overwritten).
COPY seed/ /app/config.seed/
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 755 /usr/local/bin/railway-entrypoint.sh

# Upstream image facts (verified from gethomepage/homepage Dockerfile @ v2.x):
#   ENTRYPOINT ["docker-entrypoint.sh"]  CMD ["node", "server.js"]  EXPOSE 3000
#   runs as root by default; docker-entrypoint.sh handles PUID/PGID drop and
#   IPv6/IPv4 bind probing. We keep its logic by exec-ing into it after seeding.
ENTRYPOINT ["railway-entrypoint.sh"]
CMD ["node", "server.js"]
