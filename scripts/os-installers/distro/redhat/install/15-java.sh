#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_ANT_INSTALL:-ant}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_MAVEN_INSTALL:-maven}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_PROTOBUF_COMPILER_INSTALL:-protobuf-compiler}")"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
generic_dir="${script_dir}/../../../generic"

"${generic_dir}/install_jdk.sh"
