#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/gradle/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "Gradle resolver returns package versions as JSON" {
  command -v curl >/dev/null 2>&1 || skip "curl is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"

  run "${resolver}" "${base_yml}" gradle

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "gradle" ]
  [ "$(jq -r '.items[0].version | length > 0' <<<"${output}")" = "true" ]
}

@test "Gradle resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "Gradle resolver rejects unexpected package arguments" {
  run "${resolver}" "${base_yml}" gradle unexpected

  [ "$status" -eq 2 ]

  run "${resolver}" "${base_yml}" unexpected

  [ "$status" -eq 1 ]
}

@test "Gradle resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" gradle

  [ "$status" -eq 1 ]
}
