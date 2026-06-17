# Docker Desktop `docker-desktop://` deep-link routes

Extracted from `/Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/Resources/app.asar` on macOS, Docker Desktop as installed 2026-06-17.

Two distinct layers exist:

- **Electron URL handler** (main process). Parses incoming `docker-desktop:` URLs in the `second-instance` handler, builds a view via `Xb(...)`, and only calls `showView` if a guard returns truthy. Special-cased names (e.g. `gordon`) get bespoke handling. This is the layer that decides whether the window comes forward.
- **Dashboard SPA React-Router table** (renderer). Routes that navigate *inside* an already-open dashboard window.

Empirically, `apps/...` and `logs` wake the window from a hidden state; `containers` does not — the SPA route exists but the main-process guard doesn't accept it as a wake-up trigger.

## Routes

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

## Practical recipes

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
