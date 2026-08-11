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

for command in jq npm; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "${command} is required" >&2
    exit 1
  fi
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

items_json="${tmp_dir}/items.jsonl"

for package in "$@"; do
  version="$(npm view "${package}" version --json | jq -er 'if type == "array" then .[0] else . end')"

  if [[ -z "${version}" || "${version}" == "null" ]]; then
    echo "Unable to resolve npm version for package: ${package}" >&2
    exit 1
  fi

  jq -cn \
    --arg name "${package}" \
    --arg version "${version}" \
    '{name: $name, versions: [$name + "=" + $version]}' >>"${items_json}"
done

jq -s '{items: .}' "${items_json}"
