#!/usr/bin/env bats

load test_helper

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/pacman/versions.sh"
  base_yml="${repo_root}/bases/arch/base.yml"
}

@test "pacman resolver returns an empty package version list" {
  require_command jq

  run "${resolver}" "${base_yml}" bash pacman

  [ "$status" -eq 0 ]
  validate_package_resolver_output "${repo_root}" "${output}"
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 0 ]
}

@test "pacman resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "pacman resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" bash

  [ "$status" -eq 1 ]
}
