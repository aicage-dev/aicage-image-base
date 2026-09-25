#!/usr/bin/env bats

@test "core utilities present" {
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
      command -v bash
      test -r /usr/share/bash-completion/bash_completion
      command -v bats
      command -v dig
      command -v ip
      test -f /etc/ssl/cert.pem || test -f /etc/ssl/certs/ca-certificates.crt || \
        test -f /etc/pki/tls/certs/ca-bundle.crt
      command -v curl
      if command -v dnf >/dev/null; then
        dnf config-manager --help >/dev/null
      fi
      command -v file
      command -v git
      command -v gpg
      command -v magick
      command -v jq
      command -v less
      command -v nano
      command -v nc
      command -v ssh
      command -v 7z >/dev/null || command -v 7za >/dev/null
      command -v patch
      command -v ps
      command -v rg
      command -v rsync
      command -v shellcheck
      command -v useradd
      command -v tar
      /usr/bin/time --version
      command -v tini
      command -v tree
      test -f /usr/share/zoneinfo/UTC
      command -v unzip
      command -v vim
      command -v xz
      command -v yq
      command -v zip
    '
  [ "$status" -eq 0 ]
}
