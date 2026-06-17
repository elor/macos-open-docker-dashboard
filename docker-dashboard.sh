#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Docker Dashboard
# @raycast.mode silent
# @raycast.packageName Docker
# @raycast.icon docker-icon.png

set -euo pipefail

if ! docker desktop status 2>/dev/null | grep -q "^Status[[:space:]]\+running$"; then
  docker desktop start >/dev/null 2>&1 || open -a Docker
  until docker desktop status 2>/dev/null | grep -q "^Status[[:space:]]\+running$"; do
    sleep 0.5
  done
fi

open "docker-desktop://dashboard/open"
