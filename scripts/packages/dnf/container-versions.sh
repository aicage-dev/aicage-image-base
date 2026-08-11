#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <package> [<package> ...]" >&2
  exit 2
fi

resolve_package() {
  local package="$1"
  local result

  result="$(
    dnf -q repoquery \
      --latest-limit=1 \
      --queryformat '%{name}|%{EVR}' \
      "${package}" 2>/dev/null |
      head -1
  )"

  if [[ -z "${result}" ]]; then
    result="$(
      dnf -q repoquery \
        --whatprovides \
        --latest-limit=1 \
        --queryformat '%{name}|%{EVR}' \
        "${package}" 2>/dev/null |
      head -1
    )"
  fi

  if [[ -z "${result}" ]]; then
    result="$(
      dnf -q install --assumeno "${package}" 2>/dev/null |
        awk '
          $1 == "Installing:" {
            emit = 1
            next
          }
          emit && NF == 0 {
            exit
          }
          emit && NF >= 3 && $1 != "Package" {
            version = $3
            sub(/^0:/, "", version)
            print $1 "|" version
            exit
          }
        '
    )"
  fi

  printf "%s" "${result}"
}

resolve_group_members() {
  local group="$1"

  dnf -q group info "${group}" 2>/dev/null |
    awk '
      /^[[:space:]]*(Mandatory|Default) packages[[:space:]]*:/ {
        emit = 1
        sub(/^[^:]*:[[:space:]]*/, "")
        if ($0 != "") {
          print
        }
        next
      }
      /^[[:space:]]*(Optional|Conditional) packages[[:space:]]*:/ {
        emit = 0
        next
      }
      /^[[:space:]]*[[:alpha:] ][[:alpha:] -]* packages[[:space:]]*:/ {
        emit = 0
        next
      }
      emit && /^[[:space:]]*:[[:space:]]*[^[:space:]]/ {
        sub(/^[[:space:]]*:[[:space:]]*/, "")
        print
        next
      }
      emit && /^[[:space:]]+[^[:space:]]/ {
        gsub(/^[[:space:]]+/, "")
        gsub(/[[:space:]]+$/, "")
        print
      }
    '
}

dnf -q -y install dnf-plugins-core >/dev/null 2>/dev/null

. /etc/os-release
dnf -q config-manager addrepo \
  --from-repofile="https://download.docker.com/linux/${ID}/docker-ce.repo" >/dev/null 2>/dev/null

for package in "$@"; do
  provider=""

  result="$(resolve_package "${package}")"

  if [[ -z "${result}" ]]; then
    mapfile -t members < <(resolve_group_members "${package}")

    if [[ ${#members[@]} -eq 0 ]]; then
      echo "Unable to resolve dnf version for package or group: ${package}" >&2
      exit 1
    fi

    for member in "${members[@]}"; do
      result="$(resolve_package "${member}")"
      if [[ -z "${result}" ]]; then
        echo "Unable to resolve dnf group member version for package: ${member}" >&2
        exit 1
      fi

      IFS="|" read -r resolved_name version <<<"${result}"
      printf "member\t%s\t%s\t%s\n" "${package}" "${resolved_name}" "${version}"
    done

    continue
  fi

  IFS="|" read -r resolved_name version <<<"${result}"
  if [[ "${resolved_name}" != "${package}" ]]; then
    provider="${resolved_name}"
  fi

  printf "package\t%s\t%s\t%s\n" "${package}" "${provider}" "${version}"
done
