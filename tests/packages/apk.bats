#!/usr/bin/env bats

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/apk/versions.sh"
  base_yml="${repo_root}/bases/alpine/base.yml"
}

@test "apk resolver returns Alpine package versions as JSON" {
  command -v docker >/dev/null 2>&1 || skip "docker is not available"
  docker info >/dev/null 2>&1 || skip "docker daemon is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"
  command -v yq >/dev/null 2>&1 || skip "yq is not available"

  run "${resolver}" "${base_yml}" bash

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].version | length > 0' <<<"${output}")" = "true" ]
}

@test "apk resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "apk resolver returns virtual install members as JSON" {
  command -v docker >/dev/null 2>&1 || skip "docker is not available"
  docker info >/dev/null 2>&1 || skip "docker daemon is not available"
  command -v jq >/dev/null 2>&1 || skip "jq is not available"
  command -v yq >/dev/null 2>&1 || skip "yq is not available"

  run "${resolver}" "${base_yml}" openssh-client

  [ "$status" -eq 0 ]
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "openssh-client" ]
  [ "$(jq -r '.items[0].members | length > 0' <<<"${output}")" = "true" ]
  [ "$(jq -r '[.items[0].members[].name] | index("openssh-client-default") != null' <<<"${output}")" = "true" ]
}

@test "apk resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" bash

  [ "$status" -eq 1 ]
}
