#!/usr/bin/env bats

load test_helper

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/npm/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "npm resolver returns package versions as JSON" {
  require_command jq
  require_command npm

  run "${resolver}" "${base_yml}" corepack

  [ "$status" -eq 0 ]
  validate_package_resolver_output
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "corepack" ]
  [ "$(jq -r '.items[0].versions[0].name' <<<"${output}")" = "corepack" ]
  [ "$(jq -r '.items[0].versions[0].version | length > 0' <<<"${output}")" = "true" ]
}

@test "npm resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "npm resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" corepack

  [ "$status" -eq 1 ]
}
