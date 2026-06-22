#!/usr/bin/env bats

@test "ruby toolchain present" {
  run docker run --rm \
    --env AICAGE_WORKSPACE=/workspace \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -c '
      set -euo pipefail
      command -v ruby
      command -v gem
      command -v bundle
      ruby -e '\''puts "ok"'\'' | grep -qx ok
    '
  [ "$status" -eq 0 ]
}
