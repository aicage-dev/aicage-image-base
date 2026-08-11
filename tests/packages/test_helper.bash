require_command() {
  local command="$1"

  command -v "${command}" >/dev/null 2>&1 || {
    echo "${command} is required" >&2
    return 1
  }
}

require_docker() {
  require_command docker
  docker info >/dev/null 2>&1 || {
    echo "docker daemon is required" >&2
    return 1
  }
}

validate_package_resolver_output() {
  local output_file="${BATS_TEST_TMPDIR}/package-resolver-output.json"
  # shellcheck disable=SC2154 # 'repo_root' is provided by bats
  local schema="${repo_root}/validation/package-resolver-output.json"

  # shellcheck disable=SC2154 # 'output' is provided by bats
  printf '%s\n' "${output}" >"${output_file}"
  check-jsonschema --schemafile "${schema}" "${output_file}"
}
