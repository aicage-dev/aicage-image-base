#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/pip/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "pip resolver returns package versions as JSON" {
  command -v jq >/dev/null 2>&1 || skip "jq is not available"
  command -v curl >/dev/null 2>&1 || skip "curl is not available"

  run "${resolver}" "${base_yml}" pip setuptools wheel

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 3 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "pip" ]
  [ "$(jq -r '.items[1].name' <<<"${output}")" = "setuptools" ]
  [ "$(jq -r '.items[2].name' <<<"${output}")" = "wheel" ]
  [ "$(jq -r 'all(.items[]; .version | length > 0)' <<<"${output}")" = "true" ]
}

@test "pip resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "pip resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" pip

  [ "$status" -eq 1 ]
}
