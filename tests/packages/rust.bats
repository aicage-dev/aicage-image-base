#!/usr/bin/env bats

load test_helper

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/rust/versions.sh"
  base_yml="${repo_root}/bases/debian/base.yml"
}

@test "Rust resolver returns package versions as JSON" {
  require_command curl
  require_command jq

  run "${resolver}" "${base_yml}" rust rustup

  [ "$status" -eq 0 ]
  validate_package_resolver_output
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 2 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "rust" ]
  [ "$(jq -r '.items[0].versions[0].name' <<<"${output}")" = "rust" ]
  [ "$(jq -r '.items[0].versions[0].version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")' <<<"${output}")" = "true" ]
  [ "$(jq -r '.items[1].name' <<<"${output}")" = "rustup" ]
  [ "$(jq -r '.items[1].versions[0].name' <<<"${output}")" = "rustup" ]
  [ "$(jq -r '.items[1].versions[0].version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")' <<<"${output}")" = "true" ]
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
