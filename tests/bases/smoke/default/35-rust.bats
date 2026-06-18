#!/usr/bin/env bats

@test "rust toolchain present" {
  run docker run --rm \
    --env AICAGE_WORKSPACE=/workspace \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -c '
      set -euo pipefail
      command -v rustc
      command -v cargo
      command -v rustfmt
      command -v clippy-driver >/dev/null || command -v cargo-clippy >/dev/null

      musl_target="$(uname -m)-unknown-linux-musl"
      cargo new --quiet /tmp/rust-musl-smoke
      cd /tmp/rust-musl-smoke
      cargo build --target "${musl_target}"
    '
  [ "$status" -eq 0 ]
}
