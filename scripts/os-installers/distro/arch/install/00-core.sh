#!/usr/bin/env bash
set -euo pipefail

pacman -S --noconfirm --needed \
  bash \
  bash-completion \
  bats \
  bind \
  ca-certificates \
  curl \
  file \
  git \
  gnupg \
  imagemagick \
  iproute2 \
  jq \
  less \
  nano \
  openbsd-netcat \
  openssh \
  p7zip \
  patch \
  procps-ng \
  ripgrep \
  rsync \
  shadow \
  tar \
  time \
  tree \
  tzdata \
  unzip \
  xz \
  yq \
  zip

# Arch does not package tini in the main repos; install the upstream static binary.
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64) TINI_ARCH="amd64" ;;
  aarch64) TINI_ARCH="arm64" ;;
  *)
    echo "Unsupported architecture for tini: ${ARCH}" >&2
    exit 1
    ;;
esac

curl_wrapper() {
  curl -fsSL \
    --retry 8 \
    --retry-all-errors \
    --retry-delay 2 \
    --max-time 600 \
    "$@"
}

if ! command -v tini >/dev/null 2>&1; then
  TINI_VERSION="$(curl_wrapper https://api.github.com/repos/krallin/tini/releases/latest | jq -r '.tag_name')"
  curl_wrapper "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${TINI_ARCH}" \
    -o /usr/local/bin/tini
  chmod +x /usr/local/bin/tini
fi
