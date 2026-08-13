#!/bin/sh
set -eu

script_dir="$(CDPATH='' cd -- "$(dirname "$0")" && pwd)"
install_dir="${script_dir}/install"
for install_script in "${install_dir}"/*.sh; do
  "${install_script}"
done
