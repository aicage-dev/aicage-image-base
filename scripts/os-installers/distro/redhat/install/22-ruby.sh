#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_RUBY_INSTALL:-ruby}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_RUBY_DEVEL_INSTALL:-ruby-devel}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_RUBYGEM_BUNDLER_INSTALL:-rubygem-bundler}")"
