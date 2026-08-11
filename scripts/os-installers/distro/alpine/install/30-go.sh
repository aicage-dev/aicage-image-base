#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache "${AICAGE_PACKAGE_GO_INSTALL:-go}"
