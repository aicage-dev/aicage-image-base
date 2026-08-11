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

mapfile -t yml_files < <(
  find "${ROOT_DIR}/bases" -path '*/packages/*.yml' -not -name packages.yml -type f | sort
)

for yml_file in "${yml_files[@]}"; do
  env_output="${yml_file%.yml}.env"

  {
    while IFS=$'\t' read -r package versions_json; do
      package_env_name="$(env_name "${package}")"
      package_install_spec="$(jq -r 'join(" ")' <<<"${versions_json}")"
      printf "%s='%s'\n" "${package_env_name}" "${package_install_spec}"
    done < <(
      yq -o=json '.' "${yml_file}" |
        jq -r '
          .packages |
          to_entries[] |
          [.key, (.value | tojson)] |
          @tsv
        '
    )
  } | LC_ALL=C sort >"${env_output}"

  printf '%s\n' "${env_output}"
done
