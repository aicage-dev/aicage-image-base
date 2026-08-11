#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/npm/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "npm resolver returns package versions as JSON" {
  command -v jq >/dev/null 2>&1 || skip "jq is not available"
  command -v npm >/dev/null 2>&1 || skip "npm is not available"

  run "${resolver}" "${base_yml}" corepack

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "corepack" ]
  [ "$(jq -r '.items[0].version | length > 0' <<<"${output}")" = "true" ]
}

@test "npm resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "npm resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" corepack

  [ "$status" -eq 1 ]
}
