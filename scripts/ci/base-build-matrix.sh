#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${ROOT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
BASE_ALIAS="${BASE_ALIAS:-}"

die() {
  echo "[base-build-matrix] $*" >&2
  exit 1
}

[[ -n "${BASE_ALIAS}" ]] || die "BASE_ALIAS is required"

# shellcheck source=./scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

matrix_file="$(mktemp)"
echo '{"include":[]}' > "${matrix_file}"

while IFS= read -r arch; do
  [[ -n "${arch}" ]] || continue
  case "${arch}" in
    amd64)
      platform="linux/amd64"
      runner="${RUNNER_AMD64}"
      ;;
    arm64)
      platform="linux/arm64"
      runner="${RUNNER_ARM64}"
      ;;
    *)
      die "Unsupported architecture '${arch}' for ${BASE_ALIAS}"
      ;;
  esac

  jq -c \
    --arg arch "${arch}" \
    --arg platform "${platform}" \
    --arg runner "${runner}" \
    '
      .include += [
        {
          "arch": $arch,
          "platform": $platform,
          "runner": $runner
        }
      ]
    ' \
    "${matrix_file}" > "${matrix_file}.tmp"
  mv "${matrix_file}.tmp" "${matrix_file}"
done < <(get_base_architectures "${BASE_ALIAS}")

jq '.' "${matrix_file}" >&2
cat "${matrix_file}"
