#!/usr/bin/env bash
set -euo pipefail

apt-get install -y --no-install-recommends \
  "${AICAGE_PACKAGE_BUNDLER_INSTALL:-bundler}" \
  "${AICAGE_PACKAGE_RUBY_DEV_INSTALL:-ruby-dev}" \
  "${AICAGE_PACKAGE_RUBY_FULL_INSTALL:-ruby-full}"
