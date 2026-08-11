#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache \
  "${AICAGE_PACKAGE_RUBY_INSTALL:-ruby}" \
  "${AICAGE_PACKAGE_RUBY_BUNDLER_INSTALL:-ruby-bundler}" \
  "${AICAGE_PACKAGE_RUBY_DEV_INSTALL:-ruby-dev}"
