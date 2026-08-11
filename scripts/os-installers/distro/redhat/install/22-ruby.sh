#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "${AICAGE_PACKAGE_RUBY_INSTALL:-ruby}" \
  "${AICAGE_PACKAGE_RUBY_DEVEL_INSTALL:-ruby-devel}" \
  "${AICAGE_PACKAGE_RUBYGEM_BUNDLER_INSTALL:-rubygem-bundler}"
