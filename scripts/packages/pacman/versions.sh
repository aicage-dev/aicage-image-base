#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <base.yml> <package> [<package> ...]" >&2
}

if [[ $# -lt 2 ]]; then
  usage
  exit 2
fi

base_yml="$1"

if [[ ! -f "${base_yml}" ]]; then
  echo "Base definition not found: ${base_yml}" >&2
  exit 1
fi

printf '{\n  "items": []\n}\n'
