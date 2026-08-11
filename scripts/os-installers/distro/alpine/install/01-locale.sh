#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache \
  "${AICAGE_PACKAGE_MUSL_LOCALES_INSTALL:-musl-locales}" \
  "${AICAGE_PACKAGE_MUSL_LOCALES_LANG_INSTALL:-musl-locales-lang}"
