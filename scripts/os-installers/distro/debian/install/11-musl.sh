#!/usr/bin/env bash
set -euo pipefail

apt-get install -y --no-install-recommends \
  "${AICAGE_PACKAGE_AUTOCONF_INSTALL:-autoconf}" \
  "${AICAGE_PACKAGE_AUTOMAKE_INSTALL:-automake}" \
  "${AICAGE_PACKAGE_AUTOPOINT_INSTALL:-autopoint}" \
  "${AICAGE_PACKAGE_BISON_INSTALL:-bison}" \
  "${AICAGE_PACKAGE_FLEX_INSTALL:-flex}" \
  "${AICAGE_PACKAGE_GAWK_INSTALL:-gawk}" \
  "${AICAGE_PACKAGE_LIBTOOL_INSTALL:-libtool}" \
  "${AICAGE_PACKAGE_LIBTOOL_BIN_INSTALL:-libtool-bin}" \
  "${AICAGE_PACKAGE_LINUX_LIBC_DEV_INSTALL:-linux-libc-dev}" \
  "${AICAGE_PACKAGE_MAKE_INSTALL:-make}" \
  "${AICAGE_PACKAGE_MUSL_TOOLS_INSTALL:-musl-tools}"
