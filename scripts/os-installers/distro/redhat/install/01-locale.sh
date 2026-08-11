#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_GLIBC_ALL_LANGPACKS_INSTALL:-glibc-all-langpacks}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_GLIBC_LOCALE_SOURCE_INSTALL:-glibc-locale-source}")"
