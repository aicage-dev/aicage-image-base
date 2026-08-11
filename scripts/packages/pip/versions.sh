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
shift

if [[ ! -f "${base_yml}" ]]; then
  echo "Base definition not found: ${base_yml}" >&2
  exit 1
fi

for command in curl jq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "${command} is required" >&2
    exit 1
  fi
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

items_json="${tmp_dir}/items.jsonl"

for package in "$@"; do
  version="$(curl -fsSL "https://pypi.org/pypi/${package}/json" | jq -er '.info.version')"

  if [[ -z "${version}" ]]; then
    echo "Unable to resolve pip version for package: ${package}" >&2
    exit 1
  fi

  jq -cn \
    --arg name "${package}" \
    --arg version "${version}" \
    '{name: $name, versions: [$name + "=" + $version]}' >>"${items_json}"
done

jq -s '{items: .}' "${items_json}"
