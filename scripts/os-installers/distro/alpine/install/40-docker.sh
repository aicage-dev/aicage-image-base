#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache \
  "${AICAGE_PACKAGE_DOCKER_CLI_INSTALL:-docker-cli}" \
  "${AICAGE_PACKAGE_DOCKER_CLI_COMPOSE_INSTALL:-docker-cli-compose}" \
  "${AICAGE_PACKAGE_DOCKER_CLI_BUILDX_INSTALL:-docker-cli-buildx}"
