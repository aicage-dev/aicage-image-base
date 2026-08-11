#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/node/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "Node resolver returns package versions as JSON" {
  command -v curl >/dev/null 2>&1 || skip "curl is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"

  run "${resolver}" "${base_yml}" node

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "node" ]
  [ "$(jq -r '.items[0].version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")' <<<"${output}")" = "true" ]
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
