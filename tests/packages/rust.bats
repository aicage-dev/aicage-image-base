#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/rust/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "Rust resolver returns package versions as JSON" {
  command -v curl >/dev/null 2>&1 || skip "curl is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"

  run "${resolver}" "${base_yml}" rust rustup

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 2 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "rust" ]
  [ "$(jq -r '.items[0].version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")' <<<"${output}")" = "true" ]
  [ "$(jq -r '.items[1].name' <<<"${output}")" = "rustup" ]
  [ "$(jq -r '.items[1].version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")' <<<"${output}")" = "true" ]
}

@test "Rust resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "Rust resolver rejects unexpected package arguments" {
  run "${resolver}" "${base_yml}" rust unexpected

  [ "$status" -eq 1 ]

  run "${resolver}" "${base_yml}" unexpected

  [ "$status" -eq 1 ]
}

@test "Rust resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" rust

  [ "$status" -eq 1 ]
}
