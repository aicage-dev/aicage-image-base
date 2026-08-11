#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${AICAGE_PACKAGE_DEVELOPMENT_TOOLS_INSTALL:-}" ]]; then
  # shellcheck disable=SC2046,SC2086
  dnf -y install $(dnf_specs ${AICAGE_PACKAGE_DEVELOPMENT_TOOLS_INSTALL})
else
  dnf -y group install development-tools
fi
dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_CLANG_INSTALL:-clang}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_CMAKE_INSTALL:-cmake}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_GDB_INSTALL:-gdb}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_LLD_INSTALL:-lld}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_LLDB_INSTALL:-lldb}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_LTRACE_INSTALL:-ltrace}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_NINJA_BUILD_INSTALL:-ninja-build}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_OPENSSL_DEVEL_INSTALL:-openssl-devel}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_PKGCONF_PKG_CONFIG_INSTALL:-pkgconf-pkg-config}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_STRACE_INSTALL:-strace}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_VALGRIND_INSTALL:-valgrind}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_ZLIB_DEVEL_INSTALL:-zlib-devel}")"
