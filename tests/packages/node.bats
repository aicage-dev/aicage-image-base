#!/usr/bin/env bats

load test_helper

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/node/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "Node resolver returns package versions as JSON" {
  require_command curl
  require_command jq

  run "${resolver}" "${base_yml}" node

  [ "$status" -eq 0 ]
  validate_package_resolver_output "${repo_root}" "${output}"
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "node" ]
  [ "$(jq -r '.items[0].versions[0] | test("^node=[0-9]+\\.[0-9]+\\.[0-9]+$")' <<<"${output}")" = "true" ]
}

@test "Node resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "Node resolver rejects unexpected package arguments" {
  run "${resolver}" "${base_yml}" node unexpected

  [ "$status" -eq 2 ]

  run "${resolver}" "${base_yml}" unexpected

  [ "$status" -eq 1 ]
}

@test "Node resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" node

  [ "$status" -eq 1 ]
}
