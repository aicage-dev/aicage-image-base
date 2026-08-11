#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/tini/versions.sh"
  base_yml="${repo_root}/bases/arch/base.yml"
}

@test "tini resolver returns package versions as JSON" {
  command -v curl >/dev/null 2>&1 || skip "curl is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"

  run "${resolver}" "${base_yml}" tini

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "tini" ]
  [ "$(jq -r '.items[0].version | test("^v?[0-9]+\\.[0-9]+")' <<<"${output}")" = "true" ]
}

@test "tini resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "tini resolver rejects unexpected package arguments" {
  run "${resolver}" "${base_yml}" tini unexpected

  [ "$status" -eq 2 ]

  run "${resolver}" "${base_yml}" unexpected

  [ "$status" -eq 1 ]
}

@test "tini resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" tini

  [ "$status" -eq 1 ]
}
