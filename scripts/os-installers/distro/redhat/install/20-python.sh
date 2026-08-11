#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_PIPX_INSTALL:-pipx}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_PYTHON3_INSTALL:-python3}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_PYTHON3_PIP_INSTALL:-python3-pip}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_PYTHON3_VIRTUALENV_INSTALL:-python3-virtualenv}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_PYTHON3_DEVEL_INSTALL:-python3-devel}")"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
generic_dir="${script_dir}/../../../generic"

"${generic_dir}/install_python.sh"
