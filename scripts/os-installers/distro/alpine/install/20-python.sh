#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache \
  "${AICAGE_PACKAGE_PY3_PIP_INSTALL:-py3-pip}" \
  "${AICAGE_PACKAGE_PYTHON3_INSTALL:-python3}" \
  "${AICAGE_PACKAGE_PY3_VIRTUALENV_INSTALL:-py3-virtualenv}" \
  "${AICAGE_PACKAGE_PYTHON3_DEV_INSTALL:-python3-dev}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
generic_dir="${script_dir}/../../../generic"

"${generic_dir}/install_python.sh"
