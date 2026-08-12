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

is_tool_spec() {
  local spec="$1"
  local name="${spec%%=*}"

  case "${name}" in
    corepack | gosu | gradle | jdk | node | pip | pipx | rust | rustup | setuptools | tini | uv | wheel)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

spec_version() {
  local spec="$1"

  printf '%s\n' "${spec#*=}"
}

tool_version() {
  local spec="$1"
  local version

  version="$(spec_version "${spec}")"
  if [[ "${version}" =~ ^(.+)-r[0-9]+$ ]]; then
    version="${BASH_REMATCH[1]}"
  fi
  printf '%s\n' "${version}"
}

expect_contains() {
  local actual="$1"
  local expected="$2"
  local name="$3"

  if ! grep -Fq "${expected}" <<<"${actual}"; then
    echo "${name} has version ${actual}, expected ${expected}" >&2
    return 1
  fi
}

check_deb_specs() {
  local spec package expected actual

  while IFS= read -r spec; do
    [[ "${spec}" == *=* ]] || continue
    package="${spec%%=*}"
    expected="${spec#*=}"
    if ! actual="$(dpkg-query -W -f='${Version}' "${package}" 2>/dev/null)"; then
      is_tool_spec "${spec}" && continue
      echo "Package ${package} is not installed" >&2
      return 1
    fi
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
    if ! actual="$(apk info --installed -v "${package}" 2>/dev/null)"; then
      is_tool_spec "${spec}" && continue
      echo "Package ${package} is not installed" >&2
      return 1
    fi
    if [[ "${actual}" != "${package}-${expected}" ]]; then
      echo "Package ${package} has version ${actual}, expected ${package}-${expected}" >&2
      return 1
    fi
  done < <(read_install_specs)
}

check_rpm_specs() {
  local spec package expected epoch version actual

  while IFS= read -r spec; do
    [[ "${spec}" == *=* ]] || continue
    package="${spec%%=*}"
    expected="${spec#*=}"
    if ! epoch="$(rpm -q --qf '%{EPOCH}' "${package}" 2>/dev/null)"; then
      is_tool_spec "${spec}" && continue
      echo "Package ${package} is not installed" >&2
      return 1
    fi
    version="$(rpm -q --qf '%{VERSION}-%{RELEASE}' "${package}")"
    actual="${version}"
    if [[ -n "${epoch}" && "${epoch}" != "(none)" && "${epoch}" != "0" ]]; then
      actual="${epoch}:${version}"
    fi
    if [[ "${actual}" != "${expected}" ]]; then
      echo "Package ${package} has version ${actual}, expected ${expected}" >&2
      return 1
    fi
  done < <(read_install_specs)
}

check_tool_versions() {
  local corepack_version gosu_version gradle_version node_version rust_version rustup_version tini_version uv_version

  if [[ -n "${AICAGE_PACKAGE_GOSU_INSTALL:-}" ]]; then
    gosu_version="$(tool_version "${AICAGE_PACKAGE_GOSU_INSTALL}")"
    expect_contains "$(gosu --version)" "${gosu_version}" gosu
  fi

  if [[ -n "${AICAGE_PACKAGE_TINI_INSTALL:-}" ]]; then
    tini_version="$(tool_version "${AICAGE_PACKAGE_TINI_INSTALL}")"
    tini_version="${tini_version#v}"
    expect_contains "$(tini --version)" "${tini_version}" tini
  fi

  if [[ -n "${AICAGE_PACKAGE_COREPACK_INSTALL:-}" ]]; then
    corepack_version="$(tool_version "${AICAGE_PACKAGE_COREPACK_INSTALL}")"
    [[ "$(corepack --version)" == "${corepack_version}" ]]
  fi

  if [[ -n "${AICAGE_PACKAGE_GRADLE_INSTALL:-}" ]]; then
    gradle_version="$(tool_version "${AICAGE_PACKAGE_GRADLE_INSTALL}")"
    gradle --version | grep -Fxq "Gradle ${gradle_version}"
  fi

  if [[ -n "${AICAGE_PACKAGE_NODE_INSTALL:-}" ]]; then
    node_version="$(tool_version "${AICAGE_PACKAGE_NODE_INSTALL}")"
    [[ "$(node --version)" == "v${node_version}" ]]
  fi

  if [[ -n "${AICAGE_PACKAGE_RUST_INSTALL:-}" ]]; then
    rust_version="$(tool_version "${AICAGE_PACKAGE_RUST_INSTALL}")"
    expect_contains "$(rustc --version)" "rustc ${rust_version} " rust
  fi

  if [[ -n "${AICAGE_PACKAGE_RUSTUP_INSTALL:-}" ]]; then
    rustup_version="$(tool_version "${AICAGE_PACKAGE_RUSTUP_INSTALL}")"
    expect_contains "$(rustup --version)" "rustup ${rustup_version} " rustup
  fi

  if [[ -n "${AICAGE_PACKAGE_UV_INSTALL:-}" ]]; then
    uv_version="$(tool_version "${AICAGE_PACKAGE_UV_INSTALL}")"
    expect_contains "$(uv --version)" "uv ${uv_version}" uv
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
