# macos-open-docker-dashboard

A one-shot macOS script that opens the Docker Desktop dashboard, starting the engine first if it isn't already running.

`docker-desktop://` deep-links don't launch Docker Desktop when the engine is stopped — they're silently dropped. `docker-dashboard.sh` papers over that: it makes sure the engine is up, then deep-links straight to the dashboard.

## Usage

### Raycast

The script is annotated for [Raycast script commands](https://manual.raycast.com/script-commands). Two ways to wire it up:

- **Register this repo as a script directory.** Raycast → Extensions → Script Commands → Add Script Directory → pick this folder. Trigger **Docker Dashboard** from the Raycast root.
- **Copy into an existing script directory.** Drop `docker-dashboard.sh` and `docker-icon.png` into a folder Raycast already watches (e.g. your default script-commands directory). Keep both files side-by-side — the script references the icon by relative name.

### From the shell

```sh
./docker-dashboard.sh
```

Bind it to a hotkey via your launcher of choice, or symlink it into `$PATH`.

## What the script does

1. Checks `docker desktop status` for `Status running`.
2. If the engine isn't running, runs `docker desktop start` (falling back to `open -a Docker` if the CLI subcommand isn't available), then polls every 0.5s until status reports running.
3. Opens `docker-desktop://dashboard/open` to bring the dashboard window forward.

Requires Docker Desktop on macOS. The `docker desktop` CLI subcommand ships with recent Docker Desktop versions; the `open -a Docker` fallback handles older installs.

---

## Technical details: Docker Desktop `docker-desktop://` deep-link routes

Extracted from `/Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/Resources/app.asar` on macOS, Docker Desktop as installed 2026-06-17.

Two distinct layers exist:

- **Electron URL handler** (main process). Parses incoming `docker-desktop:` URLs in the `second-instance` handler, builds a view via `Xb(...)`, and only calls `showView` if a guard returns truthy. Special-cased names (e.g. `gordon`) get bespoke handling. This is the layer that decides whether the window comes forward.
- **Dashboard SPA React-Router table** (renderer). Routes that navigate *inside* an already-open dashboard window.

Empirically, `apps/...` and `logs` wake the window from a hidden state; `containers` does not — the SPA route exists but the main-process guard doesn't accept it as a wake-up trigger.

### Routes

```
dashboard/agents
dashboard/apps/                          ← confirmed: wakes the window
dashboard/build
dashboard/build/buildHistory
dashboard/containers
dashboard/containers/create
dashboard/docker-agent
dashboard/docker-compose/
dashboard/docker-dev-cloud
dashboard/docker-hub
dashboard/docker-hub/image
dashboard/docker-hub/profile
dashboard/docker-hub/search
dashboard/docker-hub/stack
dashboard/experimental
dashboard/extensions/
dashboard/global-search
dashboard/images
dashboard/images/hub
dashboard/images/local
dashboard/images/local/details
dashboard/internal-test-page
dashboard/kubernetes
dashboard/login
dashboard/login-update
dashboard/logs                           ← confirmed: wakes the window
dashboard/marketplace/browse
dashboard/marketplace/build
dashboard/marketplace/manage
dashboard/mcp/catalog
dashboard/mcp/catalog/id/
dashboard/mcp/oauth
dashboard/mcp/profiles
dashboard/mcp/profiles/id/
dashboard/mcp/servers/id/
dashboard/models/hub
dashboard/models/local
dashboard/networks
dashboard/networks/create
dashboard/onboarding-home
dashboard/open                           ← canonical "just open the dashboard"
dashboard/settings
dashboard/settings/ai
dashboard/settings/builders
dashboard/settings/cloud
dashboard/settings/daemon
dashboard/settings/extensions
dashboard/settings/features
dashboard/settings/general
dashboard/settings/install
dashboard/settings/kubernetes
dashboard/settings/notifications
dashboard/settings/resources/advanced/non-wsl
dashboard/settings/resources/advanced/wsl
dashboard/settings/resources/file-sharing
dashboard/settings/resources/network
dashboard/settings/resources/proxies
dashboard/settings/resources/wsl-integration
dashboard/settings/update
dashboard/support
dashboard/troubleshoot
dashboard/volumes
```

### Practical recipes

Just open the dashboard:

```sh
open "docker-desktop://dashboard/open"
# fallback if the build above is a no-op:
open "docker-desktop://dashboard/apps/"
```

Open and navigate to a route that doesn't wake the window (e.g. Containers) — wake first, then route:

```sh
open "docker-desktop://dashboard/apps/"
sleep 0.15
open "docker-desktop://dashboard/containers"
```

Works even if Docker Desktop was fully quit:

```sh
open -a "Docker Desktop"
open "docker-desktop://dashboard/apps/"
sleep 0.2
open "docker-desktop://dashboard/containers"
```
