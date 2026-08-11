#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${AICAGE_PACKAGE_DEVELOPMENT_TOOLS_INSTALL:-}" ]]; then
  # shellcheck disable=SC2086
  dnf -y install ${AICAGE_PACKAGE_DEVELOPMENT_TOOLS_INSTALL}
else
  dnf -y group install development-tools
fi
dnf -y install \
  "${AICAGE_PACKAGE_CLANG_INSTALL:-clang}" \
  "${AICAGE_PACKAGE_CMAKE_INSTALL:-cmake}" \
  "${AICAGE_PACKAGE_GDB_INSTALL:-gdb}" \
  "${AICAGE_PACKAGE_LLD_INSTALL:-lld}" \
  "${AICAGE_PACKAGE_LLDB_INSTALL:-lldb}" \
  "${AICAGE_PACKAGE_LTRACE_INSTALL:-ltrace}" \
  "${AICAGE_PACKAGE_NINJA_BUILD_INSTALL:-ninja-build}" \
  "${AICAGE_PACKAGE_OPENSSL_DEVEL_INSTALL:-openssl-devel}" \
  "${AICAGE_PACKAGE_PKGCONF_PKG_CONFIG_INSTALL:-pkgconf-pkg-config}" \
  "${AICAGE_PACKAGE_STRACE_INSTALL:-strace}" \
  "${AICAGE_PACKAGE_VALGRIND_INSTALL:-valgrind}" \
  "${AICAGE_PACKAGE_ZLIB_DEVEL_INSTALL:-zlib-devel}"
