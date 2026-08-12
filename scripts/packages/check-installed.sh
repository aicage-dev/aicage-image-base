#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <package-versions.env>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

env_file="$1"
[[ -f "${env_file}" ]] || {
  echo "Package version env file not found: ${env_file}" >&2
  exit 1
}

set -a
# shellcheck disable=SC1090
. "${env_file}"
set +a

read_install_specs() {
  env |
    awk -F= '/^AICAGE_PACKAGE_.*_INSTALL=/ {print substr($0, index($0, "=") + 1)}' |
    tr ' ' '\n' |
    awk 'NF'
}

check_deb_specs() {
  local spec package expected actual

  while IFS= read -r spec; do
    [[ "${spec}" == *=* ]] || continue
    package="${spec%%=*}"
    expected="${spec#*=}"
    actual="$(dpkg-query -W -f='${Version}' "${package}")"
    if [[ "${actual}" != "${expected}" ]]; then
      echo "Package ${package} has version ${actual}, expected ${expected}" >&2
      return 1
    fi
  done < <(read_install_specs)
}

check_apk_specs() {
  local spec package expected actual

  while IFS= read -r spec; do
    [[ "${spec}" == *=* ]] || continue
    package="${spec%%=*}"
    expected="${spec#*=}"
    actual="$(apk info -v "${package}")"
    if [[ "${actual}" != "${package}-${expected}" ]]; then
      echo "Package ${package} has version ${actual}, expected ${package}-${expected}" >&2
      return 1
    fi
  done < <(read_install_specs)
}

check_rpm_specs() {
  local spec candidate expected epoch version actual found

  while IFS= read -r spec; do
    [[ "${spec}" == *-* ]] || continue
    found=false
    candidate="${spec}"
    while [[ "${candidate}" == *-* ]]; do
      candidate="${candidate%-*}"
      expected="${spec#"${candidate}-"}"
      if rpm -q "${candidate}" >/dev/null 2>&1; then
        epoch="$(rpm -q --qf '%{EPOCH}' "${candidate}")"
        version="$(rpm -q --qf '%{VERSION}-%{RELEASE}' "${candidate}")"
        actual="${version}"
        if [[ -n "${epoch}" && "${epoch}" != "(none)" ]]; then
          actual="${epoch}:${version}"
        fi
        if [[ "${actual}" != "${expected}" ]]; then
          echo "Package ${candidate} has version ${actual}, expected ${expected}" >&2
          return 1
        fi
        found=true
        break
      fi
    done
    if [[ "${found}" != true ]]; then
      echo "Package spec not installed: ${spec}" >&2
      return 1
    fi
  done < <(read_install_specs)
}

check_tool_versions() {
  if [[ -n "${AICAGE_PACKAGE_GOSU_INSTALL:-}" && "${AICAGE_PACKAGE_GOSU_INSTALL}" != *=* && "${AICAGE_PACKAGE_GOSU_INSTALL}" != *-* ]]; then
    gosu --version | grep -Fq "${AICAGE_PACKAGE_GOSU_INSTALL}"
  fi

  if [[ -n "${AICAGE_PACKAGE_TINI_INSTALL:-}" && "${AICAGE_PACKAGE_TINI_INSTALL}" == v* ]]; then
    tini --version | grep -Fq "${AICAGE_PACKAGE_TINI_INSTALL}"
  fi

  if [[ -n "${AICAGE_PACKAGE_COREPACK_INSTALL:-}" ]]; then
    [[ "$(corepack --version)" == "${AICAGE_PACKAGE_COREPACK_INSTALL}" ]]
  fi

  if [[ -n "${AICAGE_PACKAGE_GRADLE_INSTALL:-}" ]]; then
    gradle --version | grep -Fxq "Gradle ${AICAGE_PACKAGE_GRADLE_INSTALL}"
  fi

  if [[ -n "${AICAGE_PACKAGE_NODE_INSTALL:-}" ]]; then
    [[ "$(node --version)" == "v${AICAGE_PACKAGE_NODE_INSTALL}" ]]
  fi

  if [[ -n "${AICAGE_PACKAGE_RUST_INSTALL:-}" ]]; then
    rustc --version | grep -Fq "rustc ${AICAGE_PACKAGE_RUST_INSTALL} "
  fi

  if [[ -n "${AICAGE_PACKAGE_RUSTUP_INSTALL:-}" ]]; then
    rustup --version | grep -Fq "rustup ${AICAGE_PACKAGE_RUSTUP_INSTALL} "
  fi

  if [[ -n "${AICAGE_PACKAGE_UV_INSTALL:-}" ]]; then
    uv --version | grep -Fq "uv ${AICAGE_PACKAGE_UV_INSTALL}"
  fi
}

if command -v dpkg-query >/dev/null 2>&1; then
  check_deb_specs
elif command -v apk >/dev/null 2>&1; then
  check_apk_specs
elif command -v rpm >/dev/null 2>&1; then
  check_rpm_specs
fi

check_tool_versions
