#!/usr/bin/env bash
set -euo pipefail

pacman -Syu --noconfirm

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_dir="${script_dir}/install"

for install_script in "${install_dir}"/*.sh; do
  "${install_script}"
done

pacman -Scc --noconfirm
