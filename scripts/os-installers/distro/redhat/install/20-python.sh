#!/usr/bin/env bash
set -euo pipefail

: "${PIPX_HOME:?PIPX_HOME is required}"
: "${PIPX_BIN_DIR:?PIPX_BIN_DIR is required}"

PIP_ARGS=()
if python3 -m pip help install 2>/dev/null | grep -q -- --break-system-packages; then
  PIP_ARGS+=(--break-system-packages)
fi

pip_packages=(pip setuptools wheel)
if [[ -n "${AICAGE_PACKAGE_PIP_INSTALL:-}" ]]; then
  pip_packages[0]="${AICAGE_PACKAGE_PIP_INSTALL/=/==}"
fi
if [[ -n "${AICAGE_PACKAGE_SETUPTOOLS_INSTALL:-}" ]]; then
  pip_packages[1]="${AICAGE_PACKAGE_SETUPTOOLS_INSTALL/=/==}"
fi
if [[ -n "${AICAGE_PACKAGE_WHEEL_INSTALL:-}" ]]; then
  pip_packages[2]="${AICAGE_PACKAGE_WHEEL_INSTALL/=/==}"
fi

python3 -m pip install "${PIP_ARGS[@]}" --upgrade "${pip_packages[@]}"

# Alpine does not ship a pipx package; install via pip when missing.
if ! command -v pipx >/dev/null 2>&1; then
  pipx_package="pipx"
  if [[ -n "${AICAGE_PACKAGE_PIPX_INSTALL:-}" ]]; then
    pipx_package="${AICAGE_PACKAGE_PIPX_INSTALL/=/==}"
  fi
  python3 -m pip install "${PIP_ARGS[@]}" --no-cache-dir --upgrade "${pipx_package}"
fi

mkdir -p "${PIPX_HOME}" "${PIPX_BIN_DIR}"
PIPX_HOME=${PIPX_HOME} PIPX_BIN_DIR=${PIPX_BIN_DIR} pipx ensurepath

uv_package="uv"
if [[ -n "${AICAGE_PACKAGE_UV_INSTALL:-}" ]]; then
  uv_package="${AICAGE_PACKAGE_UV_INSTALL/=/==}"
fi

PIP_NO_CACHE_DIR=1 \
  PIPX_HOME=${PIPX_HOME} \
  PIPX_BIN_DIR=${PIPX_BIN_DIR} \
  pipx install "${uv_package}" --pip-args="--no-cache-dir"
