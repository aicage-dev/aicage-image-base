#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <base.yml> gradle" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 2
fi

base_yml="$1"
shift
package="$1"

if [[ "${package}" != "gradle" ]]; then
  echo "Unsupported Gradle package: ${package}" >&2
  exit 1
fi

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

version="$(curl -fsSL https://services.gradle.org/versions/current | jq -er '.version')"

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "Unable to resolve Gradle version" >&2
  exit 1
fi

jq -cn \
  --arg name "${package}" \
  --arg version "${version}" \
  '{items: [{name: $name, version: $version}]}' |
  jq '.'
