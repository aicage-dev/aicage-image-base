#!/usr/bin/env bats

@test "installed package versions match resolved package versions" {
  repo_root="${BATS_TEST_DIRNAME}/../../../.."
  case "$(uname -m)" in
    x86_64) host_arch="amd64" ;;
    aarch64 | arm64) host_arch="arm64" ;;
    *)
      echo "Unsupported host architecture: $(uname -m)" >&2
      return 1
      ;;
  esac

  package_version_env_file="${repo_root}/bases/${BASE_ALIAS}/packages/${host_arch}.env"
  checker="${repo_root}/scripts/packages/check-installed.sh"

  [ -f "${package_version_env_file}" ]
  [ -f "${checker}" ]

  run docker run --rm \
    --env AICAGE_WORKSPACE=/workspace \
    --mount "type=bind,source=${package_version_env_file},target=/tmp/aicage-package-versions.env,readonly" \
    --mount "type=bind,source=${checker},target=/tmp/aicage-check-installed.sh,readonly" \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -c '
      set -euo pipefail
      /tmp/aicage-check-installed.sh /tmp/aicage-package-versions.env
    '
  [ "$status" -eq 0 ]
}
