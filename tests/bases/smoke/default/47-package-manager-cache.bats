#!/usr/bin/env bats

@test "package manager cache is empty" {
  run docker run --rm \
    --env AICAGE_WORKSPACE=/workspace \
    --env AICAGE_HOST_IS_LINUX=true \
    --env AICAGE_UID=1234 \
    --env AICAGE_GID=2345 \
    --env AICAGE_HOST_USER=demo \
    --env AICAGE_HOME=/home/demo \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -c '
      set -euo pipefail

      count_files() {
        local dir="$1"
        shift

        if [[ ! -d "${dir}" ]]; then
          echo 0
          return 0
        fi

        find "${dir}" -mindepth 1 "$@" | wc -l
      }

      if command -v apk >/dev/null 2>&1; then
        [[ "$(count_files /var/cache/apk -type f)" -eq 0 ]]
      elif command -v pacman >/dev/null 2>&1; then
        [[ "$(count_files /var/cache/pacman/pkg -type f)" -eq 0 ]]
        [[ "$(count_files /var/lib/pacman/sync -type f)" -eq 0 ]]
      elif command -v apt-get >/dev/null 2>&1; then
        [[ "$(count_files /var/cache/apt/archives -type f ! -name lock)" -eq 0 ]]
        [[ "$(count_files /var/lib/apt/lists -type f ! -name lock)" -eq 0 ]]
      elif command -v dnf >/dev/null 2>&1; then
        [[ "$(count_files /var/cache/dnf -type f)" -eq 0 ]]
      else
        echo "unsupported package manager" >&2
        exit 1
      fi
    '
  [ "$status" -eq 0 ]
}
