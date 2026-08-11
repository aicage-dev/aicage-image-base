#!/usr/bin/env bash
set -euo pipefail

apt-get install -y --no-install-recommends \
  "${AICAGE_PACKAGE_LOCALES_INSTALL:-locales}" \
  "${AICAGE_PACKAGE_LOCALES_ALL_INSTALL:-locales-all}"
