#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for command in jq yq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "${command} is required" >&2
    exit 1
  fi
done

env_name() {
  local package="$1"

  printf 'AICAGE_PACKAGE_%s_INSTALL' "${package}" |
    tr '[:lower:]' '[:upper:]' |
    sed 's/[^A-Z0-9_]/_/g'
}

package_specs() {
  local versions_json="$1"
  local separator="$2"

  jq -r \
    --arg separator "${separator}" \
    'map(.name + $separator + (.version | tostring)) | join(" ")' \
    <<<"${versions_json}"
}

install_spec() {
  local resolver="$1"
  local versions_json="$2"

  case "${resolver}" in
    */apk/versions.sh | */apt/versions.sh)
      package_specs "${versions_json}" "="
      ;;
    */dnf/versions.sh)
      package_specs "${versions_json}" "-"
      ;;
    *)
      jq -r 'map(.version | tostring) | join(" ")' <<<"${versions_json}"
      ;;
  esac
}

mapfile -t yml_files < <(find "${ROOT_DIR}/package-versions" -type f -name '*.yml' | sort)

for yml_file in "${yml_files[@]}"; do
  env_output="${yml_file%.yml}.env"

  {
    while IFS=$'\t' read -r resolver package versions_json; do
      package_env_name="$(env_name "${package}")"
      package_install_spec="$(install_spec "${resolver}" "${versions_json}")"
      printf "%s='%s'\n" "${package_env_name}" "${package_install_spec}"
    done < <(
      yq -o=json '.' "${yml_file}" |
        jq -r '
          .resolvers |
          to_entries[] as $resolver |
          $resolver.value |
          to_entries[] |
          [$resolver.key, .key, (.value | tojson)] |
          @tsv
        '
    )
  } | LC_ALL=C sort >"${env_output}"

  printf '%s\n' "${env_output}"
done
