#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for command in jq yq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "${command} is required" >&2
    exit 1
  fi
done

mapfile -t yml_files < <(find "${ROOT_DIR}/package-versions" -type f -name '*.yml' | sort)

for yml_file in "${yml_files[@]}"; do
  env_output="${yml_file%.yml}.env"

  : >"${env_output}"
  while IFS=$'\t' read -r package install_spec; do
    env_name="$(
      printf 'AICAGE_PACKAGE_%s_INSTALL' "${package}" |
        tr '[:lower:]' '[:upper:]' |
        sed 's/[^A-Z0-9_]/_/g'
    )"
    printf "%s='%s'\n" "${env_name}" "${install_spec}" >>"${env_output}"
  done < <(
    yq -o=json '.' "${yml_file}" |
      jq -r '
        .resolvers |
        to_entries[] as $resolver |
        $resolver.value |
        to_entries[] |
        if ($resolver.key | test("/apk/versions[.]sh$")) then
          if (.value | type) == "object" and (.value | has("members")) then
            .key as $package |
            [
              $package,
              (
                .value.members |
                map(.name + "=" + .version) |
                join(" ")
              )
            ]
          else
            [.key, (.key + "=" + .value)]
          end
        elif ($resolver.key | test("/apt/versions[.]sh$")) then
          if (.value | type) == "object" then
            [.key, (.value.provider + "=" + .value.version)]
          else
            [.key, (.key + "=" + .value)]
          end
        elif ($resolver.key | test("/dnf/versions[.]sh$")) then
          if (.value | type) == "object" and (.value | has("members")) then
            .key as $package |
            [
              $package,
              (
                .value.members |
                map(.name + "-" + .version) |
                join(" ")
              )
            ]
          elif (.value | type) == "object" then
            [.key, (.value.provider + "-" + .value.version)]
          else
            [.key, (.key + "-" + .value)]
          end
        elif (.value | type) == "object" and (.value | has("members")) then
          .key as $package |
          [
            $package,
            (
              .value.members |
              map(.version) |
              join(" ")
            )
          ]
        else
          [.key, (if (.value | type) == "object" then .value.version else .value end)]
        end |
        @tsv
      '
  )

  printf '%s\n' "${env_output}"
done
