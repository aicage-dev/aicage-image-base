#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

die() {
  echo "[packages-resolve] $*" >&2
  exit 1
}

usage() {
  echo "Usage: $0 <base>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

base="$1"
base_yml="${ROOT_DIR}/bases/${base}/base.yml"
package_list="${ROOT_DIR}/bases/${base}/packages/packages.yml"

[[ -f "${package_list}" ]] || die "Package list not found: ${package_list}"
[[ -f "${base_yml}" ]] || die "Base definition not found: ${base_yml}"

for command in check-jsonschema jq yq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    die "${command} is required"
  fi
done

case "$(uname -m)" in
  x86_64) arch="amd64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *) die "Unsupported host architecture: $(uname -m)" ;;
esac

distro="$(yq -er '.distro' "${package_list}")"
[[ "${distro}" == "${base}" ]] || die "Package list distro '${distro}' does not match base '${base}'"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

package_versions_json="${tmp_dir}/package-versions.json"
printf '{"packages":{}}\n' >"${package_versions_json}"

mapfile -t resolvers < <(yq -r '.resolvers | keys[]' "${package_list}")

for resolver in "${resolvers[@]}"; do
  resolver_path="${ROOT_DIR}/${resolver}"
  [[ -x "${resolver_path}" ]] || die "Resolver is not executable: ${resolver}"

  mapfile -t packages < <(
    yq -r ".resolvers[\"${resolver}\"][][]" "${package_list}" |
      awk '!seen[$0]++'
  )

  [[ ${#packages[@]} -gt 0 ]] || die "No packages listed for resolver: ${resolver}"

  versions_json="${tmp_dir}/$(printf '%s' "${resolver}" | tr '/.' '__').json"
  "${resolver_path}" "${base_yml}" "${packages[@]}" >"${versions_json}"

  check-jsonschema \
    --schemafile "${ROOT_DIR}/validation/package-resolver-output.json" \
    "${versions_json}" >/dev/null || die "Invalid resolver output: ${resolver}"

  jq \
    --slurpfile versions "${versions_json}" \
    '
      .packages += (
        $versions[0].items |
        map({
          key: .name,
          value: .versions
        }) |
        from_entries
      )
    ' \
    "${package_versions_json}" >"${package_versions_json}.tmp"
  mv "${package_versions_json}.tmp" "${package_versions_json}"
done

output_dir="${ROOT_DIR}/bases/${distro}/packages"
mkdir -p "${output_dir}"

yml_output="${output_dir}/${arch}.yml"

jq \
  '
    {
      "packages": .packages
    }
  ' \
  "${package_versions_json}" |
  yq -P >"${yml_output}"

"${ROOT_DIR}/scripts/packages/env.sh" >/dev/null

printf '%s\n' "${yml_output}"
printf '%s\n' "${yml_output%.yml}.env"
