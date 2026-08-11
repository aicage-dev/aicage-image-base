#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "${AICAGE_PACKAGE_PERL_INSTALL:-perl}"
