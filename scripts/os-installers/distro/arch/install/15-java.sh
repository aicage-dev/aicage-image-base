#!/usr/bin/env bash
set -euo pipefail

pacman -S --noconfirm --needed \
  ant \
  maven \
  protobuf

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
generic_dir="${script_dir}/../../../generic"

"${generic_dir}/install_jdk.sh"
