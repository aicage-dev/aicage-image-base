#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/os-installers/distro/redhat/helpers.sh
. "${script_dir}/helpers.sh"

install_dir="${script_dir}/install"

"${script_dir}/pre-install.sh"

for install_script in "${install_dir}"/*.sh; do
  "${install_script}"
done

"${script_dir}/post-install.sh"
