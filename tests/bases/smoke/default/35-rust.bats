#!/usr/bin/env bats

@test "rust toolchain present" {
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

@test "rust shell environment configured" {
  run docker run --rm \
    --env AICAGE_WORKSPACE=/workspace \
    --env AICAGE_HOST_IS_LINUX=true \
    --env AICAGE_UID=1234 \
    --env AICAGE_GID=2345 \
    --env AICAGE_HOST_USER=demo \
    --env AICAGE_HOME=/home/demo \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -lc '
      set -euo pipefail
      test "${RUSTUP_HOME}" = "/usr/local/rustup"
      test "$(command -v cargo)" = "/usr/local/bin/cargo"
      test "$(command -v rustc)" = "/usr/local/bin/rustc"
      test "$(command -v rustfmt)" = "/usr/local/bin/rustfmt"
      rustup show active-toolchain >/dev/null
      cargo -V >/dev/null
      rustc -V >/dev/null
      rustfmt -V >/dev/null
      cargo clippy -V >/dev/null

      cargo new --quiet /tmp/rust-login-smoke
      cat >/tmp/rust-login-smoke/src/main.rs <<'EOF'
fn main() {
    println!("ok-rust");
}
EOF
      rustfmt /tmp/rust-login-smoke/src/main.rs
      cd /tmp/rust-login-smoke
      cargo run --quiet | grep -qx ok-rust
    '
  [ "$status" -eq 0 ]
}
