#!/bin/sh
set -eu

apk add --no-cache "${AICAGE_PACKAGE_BASH_INSTALL:-bash}"

script_dir="$(CDPATH='' cd -- "$(dirname "$0")" && pwd)"
install_dir="${script_dir}/install"

"${script_dir}/pre-install.sh"

for install_script in "${install_dir}"/*.sh; do
  "${install_script}"
done

"${script_dir}/post-install.sh"
