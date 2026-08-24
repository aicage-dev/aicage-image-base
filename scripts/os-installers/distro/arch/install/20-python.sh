#!/usr/bin/env bash
set -euo pipefail

pacman -S --noconfirm --needed \
  python \
  python-pip \
  python-pipx \
  python-virtualenv

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
generic_dir="${script_dir}/../../../generic"

"${generic_dir}/install_python.sh"
