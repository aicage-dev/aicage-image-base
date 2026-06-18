#!/usr/bin/env bash
set -euo pipefail

export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH="${CARGO_HOME}/bin:${PATH}"

# add retry and other params to reduce failure in pipelines
curl_wrapper() {
  curl -fsSL \
    --retry 8 \
    --retry-all-errors \
    --retry-delay 2 \
    --max-time 600 \
    "$@"
}

if ! command -v rustup >/dev/null 2>&1; then
  curl_wrapper https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path
fi

rustup component add rustfmt clippy

musl_target="$(uname -m)-unknown-linux-musl"
rustup target add "${musl_target}"

cargo_config="${CARGO_HOME}/config.toml"
install -d "${CARGO_HOME}"
touch "${cargo_config}"
if command -v musl-gcc >/dev/null 2>&1 && ! grep -Fq "[target.${musl_target}]" "${cargo_config}"; then
  printf '\n[target.%s]\nlinker = "musl-gcc"\n' "${musl_target}" >> "${cargo_config}"
fi

for bin in "${CARGO_HOME}/bin/"*; do
  ln -sf "${bin}" "/usr/local/bin/$(basename "${bin}")"
done

install -d /usr/share/licenses/rustup
curl_wrapper https://raw.githubusercontent.com/rust-lang/rustup/master/LICENSE-APACHE \
  -o /usr/share/licenses/rustup/LICENSE-APACHE
curl_wrapper https://raw.githubusercontent.com/rust-lang/rustup/master/LICENSE-MIT \
  -o /usr/share/licenses/rustup/LICENSE-MIT

cat > /etc/profile.d/rust.sh <<'RUST'
export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH="$CARGO_HOME/bin:$PATH"
RUST
