#!/usr/bin/env bash
set -euo pipefail

apt-get install -y --no-install-recommends \
  "${AICAGE_PACKAGE_GOLANG_INSTALL:-golang}"
