#!/usr/bin/env bash
set -euo pipefail

dnf_spec() {
  local package="$1"

  printf '%s\n' "${package/=/-}"
}
export -f dnf_spec

dnf_specs() {
  local package

  for package in "$@"; do
    dnf_spec "${package}"
  done
}
export -f dnf_specs
