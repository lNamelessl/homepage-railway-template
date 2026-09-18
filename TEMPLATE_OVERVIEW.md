# Homepage (gethomepage.dev) on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/homepage-template)

The gethomepage.dev dashboard — your services, widgets, and links in one click. Deployed with **authentication built in** (Homepage v2), a working starter config, and a persistent config volume. No auth proxy, no database, no deploy-form questions: click deploy, open the URL, log in with the auto-generated password.

## What's inside

| | |
|---|---|
| App | [Homepage](https://gethomepage.dev) `v2.4.0` (pinned), port 3000 on your Railway domain |
| Auth | Login gate in front of every page — anonymous visitors are redirected to sign-in. `HOMEPAGE_AUTH_ENABLED=true` is baked into the image. |
| Config volume | Railway volume at `/app/config` — all settings are plain YAML files that **hot-reload in seconds** |
| Starter dashboard | Greeting + clock + search widgets, 3 example service cards with live status pings, a bookmark strip |

## Deploy-form variables: none

Everything is generated per deploy by Railway expressions — the one-click flow asks you nothing:

| Variable | Value |
|---|---|
| `HOMEPAGE_AUTH_PASSWORD` | `${{secret(24,"alnum")}}` — **your login password**, read it in the Variables tab |
| `HOMEPAGE_AUTH_SECRET` | `${{secret(32)}}` — session cookie signing key |
| `HOMEPAGE_EXTERNAL_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` |
| `HOMEPAGE_ALLOWED_HOSTS` | `${{RAILWAY_PUBLIC_DOMAIN}},healthcheck.railway.app` |

## After deploying

1. Open your service's public domain → you land on the sign-in page.
2. Log in with `HOMEPAGE_AUTH_PASSWORD` (service → **Variables** tab, or `railway variables`).
3. Make it yours by editing the YAML files on the volume (`/app/config/services.yaml`, `settings.yaml`, `bookmarks.yaml`, `widgets.yaml`) — changes appear within seconds, no restart. `railway ssh` gets you a shell; the shipped files are documented worked examples.
4. Add real API-backed widgets (Sonarr, Proxmox, Uptime Kuma, OpenWeatherMap, …) and keep their keys out of the YAML: put them in Railway variables prefixed `HOMEPAGE_VAR_` (e.g. `HOMEPAGE_VAR_WEATHER_KEY`) and reference `{{HOMEPAGE_VAR_WEATHER_KEY}}` in the config. Never commit keys to config files again.

**Railway note:** there is no Docker socket on Railway, so Docker/container widgets don't apply — use the ~100 HTTP/API-based service widgets, or plain `siteMonitor` status pings like the starter config does.

**Cost:** roughly $3–5/month — one small service plus the config volume.

# Deploy and Host

## About Hosting

This template provisions one Railway service from the pinned upstream image (`ghcr.io/gethomepage/homepage:v2.4.0`) with a volume mounted at `/app/config`. Homepage is configured entirely by YAML files on that volume — there is no database and no state outside it. On first boot a wrapper copies the starter config (settings, services, bookmarks, widgets) into the empty volume exactly once; your later edits are never overwritten by redeploys. Railway probes `/api/healthcheck`, Homepage's own health endpoint, which bypasses the auth gate so the healthcheck never fails on authentication. Restart or redeploy the service and your dashboard config persists on the volume.

## Why Deploy

Manual Homepage setups historically required an auth proxy (oauth/forward-auth) in front of the dashboard, because upstream had no login page before v2.0. This template ships Homepage v2 with its built-in credential gate enabled (`HOMEPAGE_AUTH_ENABLED=true` baked into the image), a per-deploy generated password and cookie secret, and `HOMEPAGE_ALLOWED_HOSTS` pinned to your Railway domain for host-header protection. You also get a seeded, working dashboard instead of empty config files, and volume-backed persistence that survives restarts — none of which you'd have from a bare container run.

## Common Use Cases

- A single authenticated start page for your homelab, SaaS, or internal tools — every service one click away with live status dots.
- A status/overview wall for Railway-hosted projects: point service cards at your other Railway apps and monitor them with `siteMonitor`.
- A team portal with bookmarks and widgets (clock, greeting, search, weather via `HOMEPAGE_VAR_*` keys).
- A starting point to learn gethomepage's config model safely — every file on the volume is a documented example you can edit live.

## Dependencies for

Homepage itself is a self-contained Node.js app — no external services are provisioned.

### Deployment Dependencies

- None at deploy time. The template needs no user-supplied credentials: auth is generated per deploy, and the starter widgets (datetime, greeting, search, status pings) are API-key-free.
- Optional, post-deploy: API keys only if you add key-based widgets (e.g. `HOMEPAGE_VAR_OPENWEATHERMAP_KEY` as a Railway variable, referenced as `{{HOMEPAGE_VAR_OPENWEATHERMAP_KEY}}` in config).
- If you attach a custom domain, append it to `HOMEPAGE_ALLOWED_HOSTS` (comma-separated, no spaces) and update `HOMEPAGE_EXTERNAL_URL` to keep login working.
