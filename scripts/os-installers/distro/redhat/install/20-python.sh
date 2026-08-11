#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "${AICAGE_PACKAGE_PIPX_INSTALL:-pipx}" \
  "${AICAGE_PACKAGE_PYTHON3_INSTALL:-python3}" \
  "${AICAGE_PACKAGE_PYTHON3_PIP_INSTALL:-python3-pip}" \
  "${AICAGE_PACKAGE_PYTHON3_VIRTUALENV_INSTALL:-python3-virtualenv}" \
  "${AICAGE_PACKAGE_PYTHON3_DEVEL_INSTALL:-python3-devel}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
generic_dir="${script_dir}/../../../generic"

"${generic_dir}/install_python.sh"
