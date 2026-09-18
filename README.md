# Homepage on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/homepage-template)

The [gethomepage.dev](https://gethomepage.dev) dashboard — your services, widgets, and links in one click. Pinned to upstream `v2.4.0`, deployed with **built-in authentication** (v2.0+), a starter config, and a persistent config volume.

## What you get on deploy

| | |
|---|---|
| Dashboard | Homepage `v2.4.0` on port 3000, served on your Railway domain |
| Auth gate | Login page in front of everything — anonymous visitors get redirected to sign-in |
| Starter config | Working demo dashboard: greeting, clock, search bar, 3 example service cards, bookmark strip |
| Persistence | Railway volume at `/app/config` — your edited configs survive redeploys and restarts |

| Environment variable | Value on deploy |
|---|---|
| `HOMEPAGE_AUTH_ENABLED` | `true` — the auth gate is always on |
| `HOMEPAGE_AUTH_PASSWORD` | **Auto-generated per deploy** (24 alphanumeric chars). This is your login password. |
| `HOMEPAGE_AUTH_SECRET` | **Auto-generated per deploy** (32 chars). Signs/encrypts the session cookie. |
| `HOMEPAGE_EXTERNAL_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` — required by Homepage v2 auth (cookies are marked `Secure`). If you switch to a custom domain, update this to match. |
| `HOMEPAGE_ALLOWED_HOSTS` | `${{RAILWAY_PUBLIC_DOMAIN}}` + Railway's healthcheck probe host. Add any custom domains here (comma-separated, no spaces). |

## First login

1. Open your deployment's public domain — you land on the sign-in page.
2. Password = `HOMEPAGE_AUTH_PASSWORD` (find it in your service's **Variables** tab, or `railway variables`).
3. You're in. The demo dashboard renders immediately.

To change the password: edit `HOMEPAGE_AUTH_PASSWORD` in the Variables tab and redeploy (or, since the config is file-based, you can manage access however upstream v2 does via its auth settings).

## Editing your dashboard — files, hot reload

Homepage is configured by **YAML files on the `/app/config` volume** — no database:

| File | Controls |
|---|---|
| `settings.yaml` | Title, theme, colors, layout of groups |
| `services.yaml` | Your service cards (groups, hrefs, icons, widgets) |
| `bookmarks.yaml` | Link strips |
| `widgets.yaml` | Header info widgets (clock, greeting, search, weather...) |

Two ways to edit:

1. **In place on the volume** — `railway ssh` into the service and edit `/app/config/*.yaml` with vi, or use any file-transfer tool. Changes **hot-reload in seconds, no restart**.
2. **In the repo, then re-copy** — the starter files ship in this repo under [`seed/`](./seed). They are copied into the empty volume **once, on first boot only** — redeploys never overwrite your edits.

Start from the seeded examples: every card and widget in the demo config is a worked example of the upstream syntax.

## Widget secrets the Railway way — `HOMEPAGE_VAR_*`

Never put API keys directly in `services.yaml` / `widgets.yaml` (they'd be readable on the volume and in any repo you copy configs into). Homepage substitutes environment variables into config files:

1. Add the key as a Railway variable with the `HOMEPAGE_VAR_` prefix, e.g. `HOMEPAGE_VAR_WEATHER_KEY` (Railway's `{{secret(32)}}` expression can even generate it).
2. Reference it in YAML as `{{HOMEPAGE_VAR_WEATHER_KEY}}`:

```yaml
# widgets.yaml
- openweathermap:
    latitude: 52.52
    longitude: 13.40
    api: '{{HOMEPAGE_VAR_WEATHER_KEY}}'
```

(`HOMEPAGE_FILE_*` works the same way but substitutes a file's contents.)

## Railway-specific notes

- **No Docker socket on Railway.** Docker/container widgets (the `docker` rows in upstream docs) don't apply. Use the **HTTP/API-based service widgets** — Sonarr, Proxmox, Uptime Kuma, Jellyseerr, and ~100 more — or plain `siteMonitor` pings, which need no credentials at all.
- **One volume per service** (platform limit): `/app/config` is it. Homepage needs nothing else persistent.
- **Custom domain?** After adding it in Railway, append it to `HOMEPAGE_ALLOWED_HOSTS` (comma-separated, no spaces) — otherwise Homepage's host check will bounce those requests.
- **Healthcheck:** Railway probes `/api/healthcheck` — upstream's own health endpoint, which deliberately bypasses the auth gate so the healthcheck never fails on auth.

## Cost

A single Homepage service with its config volume runs around **$3–5/month** on Railway's usage-based pricing (the service is mostly idle; the volume is the floor).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `500` errors on login/API routes with `HOMEPAGE_EXTERNAL_URL ... is missing` in logs | Auth is enabled, so Homepage v2 requires `HOMEPAGE_EXTERNAL_URL` — keep it set to your public `https://` URL. |
| `Blocked host` error / page refuses to load | Your host isn't in `HOMEPAGE_ALLOWED_HOSTS`. Add it (comma-separated, no spaces) and redeploy. |
| Locked out / forgot password | Read `HOMEPAGE_AUTH_PASSWORD` in Variables (it's never written to the config volume), or set a new value and redeploy. |
| Config edits reverted after redeploy | You edited the repo `seed/` files, not the volume. Re-deploys don't overwrite the volume (by design); edit on the volume, or delete the volume to re-seed. |
| A widget shows `NaN`/`-` | Most service widgets need an API key from the target app — set it via `HOMEPAGE_VAR_*`, or switch to `siteMonitor`-only cards. |

## Links

- Upstream: https://github.com/gethomepage/homepage (~25k stars, Apache-2.0)
- Docs: https://gethomepage.dev — [configs](https://gethomepage.dev/configs/) · [widgets](https://gethomepage.dev/widgets/) · [auth](https://gethomepage.dev/installation/#homepage_auth)
