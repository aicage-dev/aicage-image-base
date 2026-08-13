#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

die() {
  echo "[build-base] $*" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
Usage: scripts/build.sh [--base <alias>] [options]

Options:
  --base <value>       Base alias (required; must match a bases/<name> folder)
  --version <value>    Override AICAGE_VERSION for this build
  -h, --help           Show this help and exit

Examples:
  scripts/build.sh --base ubuntu
USAGE
  exit 1
}

# shellcheck source=./scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

BASE_ALIAS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      [[ $# -ge 2 ]] || die "--base requires a value"
      BASE_ALIAS="$2"
      shift 2
      ;;
    --version)
      [[ $# -ge 2 ]] || die "--version requires a value"
      AICAGE_VERSION="$2"
      shift 2
      ;;
    -h | --help)
      usage
      ;;
    --)
      shift
      break
      ;;
    *)
      die "Unknown option '$1'"
      ;;
  esac
done

[[ -n "${BASE_ALIAS}" ]] || die "--base is required"

load_config_file

FROM_IMAGE="$(get_base_from_image "${BASE_ALIAS}")"
FROM_IMAGE_SOURCE="$(get_base_field "${BASE_ALIAS}" from_image)"
OS_INSTALLER="$(get_base_build_field "${BASE_ALIAS}" os_installer)"
PRE_INSTALL="$(get_base_build_field "${BASE_ALIAS}" pre_install)"
POST_INSTALL="$(get_base_build_field "${BASE_ALIAS}" post_install)"
OS_INSTALLER_PATH="${ROOT_DIR}/scripts/os-installers/${OS_INSTALLER}"
PRE_INSTALL_PATH="${ROOT_DIR}/scripts/os-installers/${PRE_INSTALL}"
POST_INSTALL_PATH="${ROOT_DIR}/scripts/os-installers/${POST_INSTALL}"
IMAGE_SOURCE_URL="$(get_image_base_source_url)"
[[ -f "${OS_INSTALLER_PATH}" ]] || die "OS installer not found for '${BASE_ALIAS}': ${OS_INSTALLER}"
[[ -f "${PRE_INSTALL_PATH}" ]] || die "Pre-install script not found for '${BASE_ALIAS}': ${PRE_INSTALL}"
[[ -f "${POST_INSTALL_PATH}" ]] || die "Post-install script not found for '${BASE_ALIAS}': ${POST_INSTALL}"

case "$(uname -m)" in
  x86_64) HOST_ARCH="amd64" ;;
  aarch64 | arm64) HOST_ARCH="arm64" ;;
  *) die "Unsupported host architecture: $(uname -m)" ;;
esac

PACKAGE_ENV_FILE="${ROOT_DIR}/bases/${BASE_ALIAS}/packages/${HOST_ARCH}.env"
[[ -f "${PACKAGE_ENV_FILE}" ]] || die "Package env file not found: ${PACKAGE_ENV_FILE}"
PACKAGE_ENV_BUILD_PATH="bases/${BASE_ALIAS}/packages/${HOST_ARCH}.env"
PACKAGE_ENV_BASE64="$(base64 <"${PACKAGE_ENV_FILE}" | tr -d '\n')"

VERSION_TAG="$(get_image_base_ref):${BASE_ALIAS}-${AICAGE_VERSION}"
LATEST_TAG="$(get_image_base_ref):${BASE_ALIAS}"

(
  echo "UpstreamBase=${FROM_IMAGE_SOURCE}"
  echo "ResolvedBase=${FROM_IMAGE}"
  echo "PreInstall=${PRE_INSTALL}"
  echo "Installer=${OS_INSTALLER}"
  echo "PostInstall=${POST_INSTALL}"
  echo "PackageEnv=${PACKAGE_ENV_FILE}"
  echo "Tags=${VERSION_TAG},${LATEST_TAG}"
) >&2

docker build \
  --build-arg "FROM_IMAGE=${FROM_IMAGE}" \
  --build-arg "IMAGE_SOURCE_URL=${IMAGE_SOURCE_URL}" \
  --build-arg "PRE_INSTALL=${PRE_INSTALL}" \
  --build-arg "OS_INSTALLER=${OS_INSTALLER}" \
  --build-arg "POST_INSTALL=${POST_INSTALL}" \
  --build-arg "PACKAGE_ENV_FILE=${PACKAGE_ENV_BUILD_PATH}" \
  --tag "${VERSION_TAG}" \
  --tag "${LATEST_TAG}" \
  --label "org.opencontainers.image.description=Base image for aicage (${BASE_ALIAS})" \
  --label "com.aicage.package-env.base64=${PACKAGE_ENV_BASE64}" \
  .
