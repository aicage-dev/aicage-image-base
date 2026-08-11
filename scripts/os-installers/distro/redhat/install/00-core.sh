#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  "$(dnf_spec "${AICAGE_PACKAGE_BASH_INSTALL:-bash}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_BASH_COMPLETION_INSTALL:-bash-completion}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_BATS_INSTALL:-bats}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_BIND_UTILS_INSTALL:-bind-utils}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_CA_CERTIFICATES_INSTALL:-ca-certificates}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_CURL_INSTALL:-curl}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_DNF_PLUGINS_CORE_INSTALL:-dnf-plugins-core}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_FILE_INSTALL:-file}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_GIT_INSTALL:-git}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_GNUPG2_INSTALL:-gnupg2}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_IMAGEMAGICK_INSTALL:-ImageMagick}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_IPROUTE_INSTALL:-iproute}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_JQ_INSTALL:-jq}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_LESS_INSTALL:-less}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_NANO_INSTALL:-nano}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_NMAP_NCAT_INSTALL:-nmap-ncat}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_OPENSSH_CLIENTS_INSTALL:-openssh-clients}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_P7ZIP_INSTALL:-p7zip}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_PATCH_INSTALL:-patch}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_PROCPS_NG_INSTALL:-procps-ng}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_RIPGREP_INSTALL:-ripgrep}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_RSYNC_INSTALL:-rsync}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_SHADOW_UTILS_INSTALL:-shadow-utils}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_TAR_INSTALL:-tar}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_TIME_INSTALL:-time}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_TINI_INSTALL:-tini}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_TREE_INSTALL:-tree}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_TZDATA_INSTALL:-tzdata}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_UNZIP_INSTALL:-unzip}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_XZ_INSTALL:-xz}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_YQ_INSTALL:-yq}")" \
  "$(dnf_spec "${AICAGE_PACKAGE_ZIP_INSTALL:-zip}")"
