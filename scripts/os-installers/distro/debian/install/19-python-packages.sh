#!/usr/bin/env bash
set -euo pipefail

apt-get install -y --no-install-recommends \
  "${AICAGE_PACKAGE_PIPX_INSTALL:-pipx}" \
  "${AICAGE_PACKAGE_PROCPS_INSTALL:-procps}" \
  "${AICAGE_PACKAGE_PYTHON3_INSTALL:-python3}" \
  "${AICAGE_PACKAGE_PYTHON3_PIP_INSTALL:-python3-pip}" \
  "${AICAGE_PACKAGE_PYTHON3_VENV_INSTALL:-python3-venv}" \
  "${AICAGE_PACKAGE_PYTHON3_DEV_INSTALL:-python3-dev}"
