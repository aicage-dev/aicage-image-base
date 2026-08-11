#!/usr/bin/env bash
set -euo pipefail

TRACE_TOOLS=("${AICAGE_PACKAGE_STRACE_INSTALL:-strace}")
if apt-cache show ltrace >/dev/null 2>&1; then
  TRACE_TOOLS+=("${AICAGE_PACKAGE_LTRACE_INSTALL:-ltrace}")
fi

apt-get install -y --no-install-recommends \
  "${AICAGE_PACKAGE_BUILD_ESSENTIAL_INSTALL:-build-essential}" \
  "${AICAGE_PACKAGE_CLANG_INSTALL:-clang}" \
  "${AICAGE_PACKAGE_CMAKE_INSTALL:-cmake}" \
  "${AICAGE_PACKAGE_GDB_INSTALL:-gdb}" \
  "${AICAGE_PACKAGE_LIBSSL_DEV_INSTALL:-libssl-dev}" \
  "${AICAGE_PACKAGE_LLD_INSTALL:-lld}" \
  "${AICAGE_PACKAGE_LLDB_INSTALL:-lldb}" \
  "${TRACE_TOOLS[@]}" \
  "${AICAGE_PACKAGE_NINJA_BUILD_INSTALL:-ninja-build}" \
  "${AICAGE_PACKAGE_PKG_CONFIG_INSTALL:-pkg-config}" \
  "${AICAGE_PACKAGE_VALGRIND_INSTALL:-valgrind}" \
  "${AICAGE_PACKAGE_ZLIB1G_DEV_INSTALL:-zlib1g-dev}"
