#!/usr/bin/env bats

load test_helper

setup() {
  repo_root="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  resolver="${repo_root}/scripts/packages/dnf/versions.sh"
  base_yml="${repo_root}/bases/fedora/base.yml"
}

@test "dnf resolver returns Fedora package versions as JSON" {
  require_docker
  require_command jq
  require_command yq

  run "${resolver}" "${base_yml}" bash

  [ "$status" -eq 0 ]
  validate_package_resolver_output
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 1 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].versions[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[0].versions[0].version | length > 0' <<<"${output}")" = "true" ]
}

@test "dnf resolver returns group members as JSON" {
  require_command jq
  require_command yq

  mkdir -p "${BATS_TEST_TMPDIR}/bin"
  mock_docker="${BATS_TEST_TMPDIR}/bin/docker"
  {
    printf '#!/usr/bin/env bash\n'
    printf 'set -euo pipefail\n'
    printf 'printf "package\\tbash\\t\\t5.2.26-1.fc43\\n"\n'
    printf 'printf "package\\tp7zip\\t7zip\\t24.09-6.fc43\\n"\n'
    printf 'printf "member\\tdevelopment-tools\\tgcc\\t15.2.1-1.fc43\\n"\n'
    printf 'printf "member\\tdevelopment-tools\\tmake\\t1:4.4.1-10.fc43\\n"\n'
  } >"${mock_docker}"
  chmod +x "${mock_docker}"

  PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" run "${resolver}" "${base_yml}" bash p7zip development-tools

  [ "$status" -eq 0 ]
  validate_package_resolver_output
  [ "$(jq -r '.items | length' <<<"${output}")" -eq 3 ]
  [ "$(jq -r '.items[0].name' <<<"${output}")" = "bash" ]
  [ "$(jq -r '.items[1].name' <<<"${output}")" = "p7zip" ]
  [ "$(jq -r '.items[1].versions[0].name' <<<"${output}")" = "7zip" ]
  [ "$(jq -r '.items[2].name' <<<"${output}")" = "development-tools" ]
  [ "$(jq -r '.items[2].versions | length' <<<"${output}")" -eq 2 ]
  [ "$(jq -r '.items[2].versions[0].name' <<<"${output}")" = "gcc" ]
  [ "$(jq -r '.items[2].versions[1].name' <<<"${output}")" = "make" ]
}

@test "dnf resolver rejects missing package arguments" {
  run "${resolver}" "${base_yml}"

  [ "$status" -eq 2 ]
}

@test "dnf resolver rejects missing base definition" {
  run "${resolver}" "${repo_root}/bases/missing/base.yml" bash

  [ "$status" -eq 1 ]
}
