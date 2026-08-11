#!/bin/sh
set -eu

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <package> [<package> ...]" >&2
  exit 2
fi

apk update >/dev/null

resolve_package_version() {
  package="$1"

  apk policy "$package" |
    awk '
      /^[[:space:]]+[0-9][^:]*:$/ {
        version = $1
        sub(/:$/, "", version)
        print version
        exit
      }
    '
}

for package in "$@"; do
  version="$(resolve_package_version "$package")"

  if [ -z "$version" ]; then
    members="$(
      apk add --simulate "$package" 2>/dev/null |
        awk '
          /^[(][0-9]+\/[0-9]+[)] Installing / {
            name = $3
            version = $4
            sub(/^[()]/, "", version)
            sub(/[()]$/, "", version)
            print "member\t" package "\t" name "\t" version
          }
        ' package="$package"
    )"

    if [ -n "$members" ]; then
      printf '%s\n' "$members"
      continue
    fi
  fi

  if [ -z "$version" ]; then
    echo "Unable to resolve apk version for package: $package" >&2
    exit 1
  fi

  printf 'package\t%s\t%s\n' "$package" "$version"
done
