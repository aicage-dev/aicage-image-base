#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "${AICAGE_PACKAGE_AUTOCONF_INSTALL:-autoconf}" \
  "${AICAGE_PACKAGE_AUTOMAKE_INSTALL:-automake}" \
  "${AICAGE_PACKAGE_BISON_INSTALL:-bison}" \
  "${AICAGE_PACKAGE_FLEX_INSTALL:-flex}" \
  "${AICAGE_PACKAGE_GAWK_INSTALL:-gawk}" \
  "${AICAGE_PACKAGE_GETTEXT_INSTALL:-gettext}" \
  "${AICAGE_PACKAGE_GETTEXT_DEVEL_INSTALL:-gettext-devel}" \
  "${AICAGE_PACKAGE_LIBTOOL_INSTALL:-libtool}" \
  "${AICAGE_PACKAGE_MUSL_DEVEL_INSTALL:-musl-devel}" \
  "${AICAGE_PACKAGE_MUSL_GCC_INSTALL:-musl-gcc}" \
  "${AICAGE_PACKAGE_MUSL_LIBC_STATIC_INSTALL:-musl-libc-static}"
