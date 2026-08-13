#!/usr/bin/env bats

@test "package env label decodes to resolved package env file" {
  repo_root="${BATS_TEST_DIRNAME}/../../../.."
  case "$(uname -m)" in
    x86_64) host_arch="amd64" ;;
    aarch64 | arm64) host_arch="arm64" ;;
    *)
      echo "Unsupported host architecture: $(uname -m)" >&2
      return 1
      ;;
  esac

  package_env_file="${repo_root}/bases/${BASE_ALIAS}/packages/${host_arch}.env"
  decoded_env_file="${BATS_TEST_TMPDIR}/package-env-from-label.env"

  [ -f "${package_env_file}" ]

  run docker image inspect \
    --format '{{ index .Config.Labels "com.aicage.package-env.base64" }}' \
    "${AICAGE_IMAGE_BASE_IMAGE}"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [ "$output" != "<no value>" ]

  PACKAGE_ENV_BASE64="$output" \
    DECODED_ENV_FILE="${decoded_env_file}" \
    python - <<'PY'
import base64
import os
from pathlib import Path

encoded = os.environ["PACKAGE_ENV_BASE64"]
decoded_file = Path(os.environ["DECODED_ENV_FILE"])
decoded_file.write_bytes(base64.b64decode(encoded, validate=True))
PY

  run cmp -s "${package_env_file}" "${decoded_env_file}"
  [ "$status" -eq 0 ]
}
