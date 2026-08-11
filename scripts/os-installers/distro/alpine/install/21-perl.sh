#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache \
  "${AICAGE_PACKAGE_PERL_INSTALL:-perl}"
