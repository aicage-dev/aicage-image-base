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
    --mount="type=bind,source=${container_versions_script},target=/tmp/apk-versions.sh,readonly" \
    "${from_image}" \
    /tmp/apk-versions.sh "$@"
)"

jq -Rn '
  [inputs | split("\t")] as $rows |
  (
    $rows |
    map(
      select(.[0] == "package") |
      {name: .[1], versions: [{name: .[1], version: .[2]}]}
    )
  ) as $packages |
  (
    $rows |
    map(select(.[0] == "member")) |
    group_by(.[1]) |
    map({
      name: .[0][1],
      versions: map({name: .[2], version: .[3]})
    })
  ) as $groups |
  ($packages + $groups) |
  {items: .}
' <<<"${versions}"
