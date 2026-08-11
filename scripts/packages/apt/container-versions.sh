#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <package> [<package> ...]" >&2
  exit 2
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update >/dev/null

apt-get install -y --no-install-recommends ca-certificates curl gnupg >/dev/null
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/debian/gpg" |
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" \
  >/etc/apt/sources.list.d/docker.list
apt-get update >/dev/null

for package in "$@"; do
  provider=""
  query_package="${package}"

  version="$(
    apt-cache policy "${query_package}" |
      awk '
        $1 == "Candidate:" {
          print $2
          exit
        }
      '
  )"

  if [[ -z "${version}" || "${version}" == "(none)" ]]; then
    provider="$(
      apt-get -s install --no-install-recommends "${package}" 2>/dev/null |
        awk '
          $1 == "Inst" {
            provider = $2
          }
          END {
            if (provider != "") {
              print provider
            }
          }
        '
    )"

    if [[ -n "${provider}" && "${provider}" != "${package}" ]]; then
      query_package="${provider}"
      version="$(
        apt-cache policy "${query_package}" |
          awk '
            $1 == "Candidate:" {
              print $2
              exit
            }
          '
      )"
    fi
  fi

  if [[ -z "${version}" || "${version}" == "(none)" ]]; then
    echo "Unable to resolve apt candidate version for package: ${package}" >&2
    exit 1
  fi

  printf "%s\t%s\t%s\n" "${package}" "${provider}" "${version}"
done
