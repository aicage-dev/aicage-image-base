#!/usr/bin/env bash
set -euo pipefail

export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH="${CARGO_HOME}/bin:${PATH}"

rustup_os="unknown-linux-gnu"
# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" == "alpine" ]]; then
  rustup_os="unknown-linux-musl"
fi

case "$(uname -m)" in
  x86_64) RUSTUP_ARCH="x86_64" ;;
  aarch64 | arm64) RUSTUP_ARCH="aarch64" ;;
  *)
    echo "Unsupported host architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

RUSTUP_TARGET="${RUSTUP_ARCH}-${rustup_os}"

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
  rustup_args=(-y --profile minimal --no-modify-path)
  if [[ -n "${AICAGE_PACKAGE_RUST_INSTALL:-}" ]]; then
    rustup_args+=(--default-toolchain "${AICAGE_PACKAGE_RUST_INSTALL}")
  fi

  if [[ -n "${AICAGE_PACKAGE_RUSTUP_INSTALL:-}" ]]; then
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "${tmp_dir}"' EXIT
    rustup_init="${tmp_dir}/rustup-init"
    rustup_url="https://static.rust-lang.org/rustup/archive/${AICAGE_PACKAGE_RUSTUP_INSTALL}/${RUSTUP_TARGET}/rustup-init"
    curl_wrapper "${rustup_url}" -o "${rustup_init}"
    chmod +x "${rustup_init}"
    "${rustup_init}" "${rustup_args[@]}"
  else
    curl_wrapper https://sh.rustup.rs | sh -s -- "${rustup_args[@]}"
  fi
fi

rustup component add rustfmt clippy

musl_target="$(uname -m)-unknown-linux-musl"
rustup target add "${musl_target}"

toolchain_bin_dir="$(rustc --print sysroot)/bin"
for bin in "${toolchain_bin_dir}/"*; do
  ln -sf "${bin}" "/usr/local/bin/$(basename "${bin}")"
done

ln -sf "${CARGO_HOME}/bin/rustup" /usr/local/bin/rustup

if command -v musl-gcc >/dev/null 2>&1; then
  rustup_linker_config='[target.'"${musl_target}"']
linker = "musl-gcc"
'

  for cargo_home in /root/.cargo /etc/skel/.cargo; do
    cargo_config="${cargo_home}/config.toml"
    install -d "${cargo_home}"
    touch "${cargo_config}"
    if ! grep -Fq "[target.${musl_target}]" "${cargo_config}"; then
      printf '\n%s' "${rustup_linker_config}" >>"${cargo_config}"
    fi
  done
fi

install -d /usr/share/licenses/rustup
curl_wrapper https://raw.githubusercontent.com/rust-lang/rustup/master/LICENSE-APACHE \
  -o /usr/share/licenses/rustup/LICENSE-APACHE
curl_wrapper https://raw.githubusercontent.com/rust-lang/rustup/master/LICENSE-MIT \
  -o /usr/share/licenses/rustup/LICENSE-MIT

cat >/etc/profile.d/rust.sh <<'RUST'
export RUSTUP_HOME=/usr/local/rustup
export PATH="/usr/local/cargo/bin:$HOME/.cargo/bin:$PATH"
RUST
