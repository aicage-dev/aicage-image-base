#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/apt/versions.sh"
  debian_base_yml="${repo_root}/bases/debian/base.yml"
  ubuntu_base_yml="${repo_root}/bases/ubuntu/base.yml"
}

@test "apt resolver returns Debian package versions as JSON" {
  command -v docker >/dev/null 2>&1 || skip "docker is not available"
  docker info >/dev/null 2>&1 || skip "docker daemon is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"
  command -v yq >/dev/null 2>&1 || skip "yq is not available"

  run "${resolver}" "${debian_base_yml}" bash

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].version | length > 0' <<<"${output}")" = "true" ]
}

@test "apt resolver returns Ubuntu package versions as JSON" {
  command -v docker >/dev/null 2>&1 || skip "docker is not available"
  docker info >/dev/null 2>&1 || skip "docker daemon is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"
  command -v yq >/dev/null 2>&1 || skip "yq is not available"

  run "${resolver}" "${ubuntu_base_yml}" bash

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].version | length > 0' <<<"${output}")" = "true" ]
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
  command -v docker >/dev/null 2>&1 || skip "docker is not available"
  docker info >/dev/null 2>&1 || skip "docker daemon is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"
  command -v yq >/dev/null 2>&1 || skip "yq is not available"

  run "${resolver}" "${debian_base_yml}" dnsutils

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "dnsutils" ]
  [ "$(jq -r '.items[0].provider' <<<"${output}")" = "bind9-dnsutils" ]
  [ "$(jq -r '.items[0].version | length > 0' <<<"${output}")" = "true" ]
}
