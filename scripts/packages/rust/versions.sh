#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <base.yml> <rust|rustup> [<rust|rustup>...]" >&2
}

if [[ $# -lt 2 ]]; then
  usage
  exit 2
fi

base_yml="$1"
shift

if [[ ! -f "${base_yml}" ]]; then
  echo "Base definition not found: ${base_yml}" >&2
  exit 1
fi

for command in curl jq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "${command} is required" >&2
    exit 1
  fi
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

manifest="${tmp_dir}/channel-rust-stable.toml"
curl -fsSL https://static.rust-lang.org/dist/channel-rust-stable.toml -o "${manifest}"

rust_version="$(
  awk -F '"' '
    $0 == "[pkg.rust]" {
      in_rust = 1
      next
    }
    in_rust && $1 == "version = " {
      print $2
      exit
    }
  ' "${manifest}"
)"
rust_version="${rust_version%% *}"

if [[ -z "${rust_version}" ]]; then
  echo "Unable to resolve stable Rust version" >&2
  exit 1
fi

rustup_release="$(curl -fsSL https://static.rust-lang.org/rustup/release-stable.toml)"
rustup_version="$(
  awk -F "'" '
    $1 == "version = " {
      print $2
      exit
    }
  ' <<<"${rustup_release}"
)"

if [[ -z "${rustup_version}" ]]; then
  echo "Unable to resolve stable rustup version" >&2
  exit 1
fi

items_json="$(jq -cn '{items: []}')"

for package in "$@"; do
  case "${package}" in
    rust)
      version="${rust_version}"
      ;;
    rustup)
      version="${rustup_version}"
      ;;
    *)
      echo "Unsupported Rust package: ${package}" >&2
      exit 1
      ;;
  esac

  items_json="$(
    jq -c \
      --arg name "${package}" \
      --arg version "${version}" \
      '.items += [{name: $name, versions: [{name: $name, version: $version}]}]' \
      <<<"${items_json}"
  )"
done

jq -c '.' <<<"${items_json}" |
  jq '.'
