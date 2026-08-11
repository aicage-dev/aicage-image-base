#!/usr/bin/env bash
set -euo pipefail

. /etc/os-release

dnf config-manager addrepo \
  --from-repofile="https://download.docker.com/linux/${ID}/docker-ce.repo"

dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_DOCKER_BUILDX_PLUGIN_INSTALL:-docker-buildx-plugin}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_DOCKER_CE_CLI_INSTALL:-docker-ce-cli}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_DOCKER_COMPOSE_PLUGIN_INSTALL:-docker-compose-plugin}")"
