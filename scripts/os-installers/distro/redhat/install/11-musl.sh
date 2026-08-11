#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_AUTOCONF_INSTALL:-autoconf}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_AUTOMAKE_INSTALL:-automake}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_BISON_INSTALL:-bison}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_FLEX_INSTALL:-flex}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_GAWK_INSTALL:-gawk}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_GETTEXT_INSTALL:-gettext}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_GETTEXT_DEVEL_INSTALL:-gettext-devel}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_LIBTOOL_INSTALL:-libtool}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_MUSL_DEVEL_INSTALL:-musl-devel}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_MUSL_GCC_INSTALL:-musl-gcc}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_MUSL_LIBC_STATIC_INSTALL:-musl-libc-static}")"
