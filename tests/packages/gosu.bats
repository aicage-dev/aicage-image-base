#!/usr/bin/env bats

load test_helper

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/gosu/versions.sh"
  base_yml="${repo_root}/bases/fedora/base.yml"
}

@test "gosu resolver returns package versions as JSON" {
  require_command curl
  require_command jq

  run "${resolver}" "${base_yml}" gosu

  [ "$status" -eq 0 ]
  validate_package_resolver_output "${repo_root}" "${output}"
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "gosu" ]
  [ "$(jq -r '.items[0].versions[0] | test("^gosu=v?[0-9]+\\.[0-9]+")' <<<"${output}")" = "true" ]
}

@test "gosu resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "gosu resolver rejects unexpected package arguments" {
  run "${resolver}" "${base_yml}" gosu unexpected

  [ "$status" -eq 2 ]

  run "${resolver}" "${base_yml}" unexpected

  [ "$status" -eq 1 ]
}

@test "gosu resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" gosu

  [ "$status" -eq 1 ]
}
