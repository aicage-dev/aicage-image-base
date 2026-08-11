#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "${AICAGE_PACKAGE_GOLANG_INSTALL:-golang}"
