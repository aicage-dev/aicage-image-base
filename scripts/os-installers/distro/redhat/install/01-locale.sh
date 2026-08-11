#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "${AICAGE_PACKAGE_GLIBC_ALL_LANGPACKS_INSTALL:-glibc-all-langpacks}" \
  "${AICAGE_PACKAGE_GLIBC_LOCALE_SOURCE_INSTALL:-glibc-locale-source}"
