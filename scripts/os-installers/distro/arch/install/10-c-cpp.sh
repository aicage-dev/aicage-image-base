#!/usr/bin/env bash
set -euo pipefail

pacman -S --noconfirm --needed \
  base-devel \
  clang \
  cmake \
  gdb \
  lld \
  lldb \
  ltrace \
  ninja \
  pkgconf \
  strace \
  valgrind \
  zlib
