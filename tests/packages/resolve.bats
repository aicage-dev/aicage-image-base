#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/resolve.sh"
}

@test "package resolver rejects missing base argument" {
  run "${resolver}"

  [ "$status" -eq 2 ]
}

@test "package resolver rejects unknown base" {
  run "${resolver}" missing

  [ "$status" -eq 1 ]
}
