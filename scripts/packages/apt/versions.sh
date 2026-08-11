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

for command in docker jq yq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "${command} is required" >&2
    exit 1
  fi
done

from_image="$(yq -er '.from_image' "${base_yml}")"
if [[ -z "${from_image}" ]]; then
  echo "Unable to read from_image from: ${base_yml}" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
container_versions_script="${script_dir}/container-versions.sh"

versions="$(
  docker run --rm \
    --mount="type=bind,source=${container_versions_script},target=/tmp/apt-versions.sh,readonly" \
    "${from_image}" \
    /tmp/apt-versions.sh "$@"
)"

jq -Rn '
  [
    inputs |
    split("\t") |
    {
      name: .[0],
      versions: [
        (if .[1] == "" then .[0] else .[1] end) + "=" + .[2]
      ]
    }
  ] |
  {items: .}
' <<<"${versions}"
