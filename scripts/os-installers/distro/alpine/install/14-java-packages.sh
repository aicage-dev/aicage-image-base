#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache \
  "${AICAGE_PACKAGE_APACHE_ANT_INSTALL:-apache-ant}" \
  "${AICAGE_PACKAGE_MAVEN_INSTALL:-maven}" \
  "${AICAGE_PACKAGE_PROTOBUF_INSTALL:-protobuf}"
