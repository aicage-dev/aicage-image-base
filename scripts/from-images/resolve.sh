#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

die() {
  echo "[from-images-resolve] $*" >&2
  exit 1
}

usage() {
  echo "Usage: $0 <base>" >&2
}

image_repository() {
  local image="${1%@*}"
  local last="${image##*/}"
  local prefix

  if [[ "${last}" != *:* ]]; then
    printf '%s\n' "${image}"
    return
  fi

  last="${last%%:*}"
  if [[ "${image}" == */* ]]; then
    prefix="${image%/*}"
    printf '%s/%s\n' "${prefix}" "${last}"
  else
    printf '%s\n' "${last}"
  fi
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

base="$1"
base_yml="${ROOT_DIR}/bases/${base}/base.yml"

[[ -f "${base_yml}" ]] || die "Base definition not found: ${base_yml}"

for command in docker jq yq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    die "${command} is required"
  fi
done

from_image="$(yq -er '.from_image' "${base_yml}")"
[[ -n "${from_image}" ]] || die "from_image missing in ${base_yml}"

inspect_json="$(docker buildx imagetools inspect "${from_image}" --format '{{json .}}')" ||
  die "Failed to inspect ${from_image}"
digest="$(jq -er '.manifest.digest' <<<"${inspect_json}")" ||
  die "Failed to read digest for ${from_image}"
[[ "${digest}" =~ ^sha256:[0-9a-f]{64}$ ]] ||
  die "Unexpected digest for ${from_image}: ${digest}"

repository="$(image_repository "${from_image}")"
resolved_from_image="${repository}@${digest}"

output_dir="${ROOT_DIR}/bases/${base}"
env_output="${output_dir}/from-image.env"

{
  printf 'AICAGE_FROM_IMAGE=%s\n' "${resolved_from_image}"
} >"${env_output}"

printf '%s\n' "${env_output}"
