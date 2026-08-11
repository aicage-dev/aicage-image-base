#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_GOLANG_INSTALL:-golang}")"
