#!/usr/bin/env bash
set -euo pipefail

apt-get install -y --no-install-recommends \
  "${AICAGE_PACKAGE_ANT_INSTALL:-ant}" \
  "${AICAGE_PACKAGE_MAVEN_INSTALL:-maven}" \
  "${AICAGE_PACKAGE_PROTOBUF_COMPILER_INSTALL:-protobuf-compiler}"
