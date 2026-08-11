#!/usr/bin/env bats

load test_helper

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/apt/versions.sh"
  debian_base_yml="${repo_root}/bases/debian/base.yml"
  ubuntu_base_yml="${repo_root}/bases/ubuntu/base.yml"
}

@test "apt resolver returns Debian package versions as JSON" {
  require_docker
  require_command jq
  require_command yq

  run "${resolver}" "${debian_base_yml}" bash

  [ "$status" -eq 0 ]
  validate_package_resolver_output
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].versions[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].versions[0].version | length > 0' <<<"${output}")" = "true" ]
}

@test "apt resolver returns Ubuntu package versions as JSON" {
  require_docker
  require_command jq
  require_command yq

  run "${resolver}" "${ubuntu_base_yml}" bash

  [ "$status" -eq 0 ]
  validate_package_resolver_output
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].versions[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].versions[0].version | length > 0' <<<"${output}")" = "true" ]
}

@test "apt resolver rejects missing package arguments" {
  run "${resolver}" "${debian_base_yml}"

  [ "$status" -eq 2 ]
}

@test "apt resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" bash

  [ "$status" -eq 1 ]
}

@test "apt resolver preserves virtual package provider" {
  require_docker
  require_command jq
  require_command yq

  run "${resolver}" "${debian_base_yml}" dnsutils

  [ "$status" -eq 0 ]
  validate_package_resolver_output
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "dnsutils" ]
  [ "$(jq -r '.items[0].versions[0].name' <<<"${output}")" = "bind9-dnsutils" ]
  [ "$(jq -r '.items[0].versions[0].version | length > 0' <<<"${output}")" = "true" ]
}
