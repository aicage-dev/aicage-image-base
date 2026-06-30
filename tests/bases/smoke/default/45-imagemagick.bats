#!/usr/bin/env bats

@test "imagemagick present" {
  run docker run --rm \
    --env AICAGE_WORKSPACE=/workspace \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -c '
      set -euo pipefail
      if command -v magick >/dev/null; then
        magick -size 1x1 xc:red txt:- | grep -q " red$"
      else
        convert -size 1x1 xc:red txt:- | grep -q " red$"
      fi
    '
  [ "$status" -eq 0 ]
}
