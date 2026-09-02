#!/usr/bin/env bash
set -euo pipefail

# add retry and other params to reduce failure in pipelines
curl_wrapper() {
  curl -fsSL \
    --retry 8 \
    --retry-all-errors \
    --retry-delay 2 \
    --max-time 600 \
    "$@"
}

install_node_from_tarball() {
  local node_dist_arch
  local nodejs_version

  case "$(uname -m)" in
    x86_64) node_dist_arch="x64" ;;
    aarch64 | arm64) node_dist_arch="arm64" ;;
    *)
      echo "Unsupported host architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac

  nodejs_version="${NODEJS_VERSION:-}"
  if [[ -z "${nodejs_version}" ]]; then
    nodejs_version="$(
      curl_wrapper https://nodejs.org/dist/index.json |
        jq -r 'map(select(.lts != false)) | .[0].version'
    )"
    nodejs_version="${nodejs_version#v}"
  fi

  if [[ -z "${nodejs_version}" ]]; then
    echo "Unable to resolve latest Node.js LTS version" >&2
    exit 1
  fi

  if ! command -v node >/dev/null 2>&1; then
    curl_wrapper "https://nodejs.org/dist/v${nodejs_version}/node-v${nodejs_version}-linux-${node_dist_arch}.tar.xz" |
      tar -xJ -C /usr/local --strip-components=1
  fi

  ln -sf /usr/local/bin/node /usr/bin/node
  ln -sf /usr/local/bin/npm /usr/bin/npm
  ln -sf /usr/local/bin/npx /usr/bin/npx
}

if command -v apk >/dev/null 2>&1; then
  # Prefer distro packages on Alpine to avoid missing musl tarballs.
  apk add --no-cache \
    nodejs-current \
    npm
else
  install_node_from_tarball
fi

npm config set prefix /usr/local

npm install -g corepack
corepack enable

# xdg-utils: provides xdg-open; needed by some npm-installed CLI agents (auth/docs URL open)
if ! command -v xdg-open >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update && apt-get install -y --no-install-recommends xdg-utils
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y xdg-utils
  elif command -v yum >/dev/null 2>&1; then
    yum install -y xdg-utils
  elif command -v zypper >/dev/null 2>&1; then
    zypper -n in xdg-utils
  elif command -v pacman >/dev/null 2>&1; then
    pacman -Sy --noconfirm xdg-utils
  elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache xdg-utils
  fi
fi
