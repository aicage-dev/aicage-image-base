#!/usr/bin/env bats

load test_helper

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/pip/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "pip resolver returns package versions as JSON" {
  require_command jq
  require_command curl

  run "${resolver}" "${base_yml}" pip setuptools wheel

  [ "$status" -eq 0 ]
  validate_package_resolver_output
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 3 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "pip" ]
  [ "$(jq -r '.items[1].name' <<<"${output}")" = "setuptools" ]
  [ "$(jq -r '.items[2].name' <<<"${output}")" = "wheel" ]
  [ "$(jq -r 'all(.items[]; .versions[0].name == .name)' <<<"${output}")" = "true" ]
  [ "$(jq -r 'all(.items[]; .versions[0].version | length > 0)' <<<"${output}")" = "true" ]
}

@test "pip resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "pip resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" pip

  [ "$status" -eq 1 ]
}
