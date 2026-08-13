#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

# YAML
yamllint .

# Markdown
pymarkdown \
  --config .pymarkdown.json scan \
  --recurse \
  --exclude '**/.venv*/**' \
  .

# Shellcheck
mapfile -t shell_scripts < <(find . -type f -name '*.sh' -not -path './.venv/*' | sort)

if [[ ${#shell_scripts[@]} -gt 0 ]]; then
  echo "Validate shell scripts with bash -n"
  for script in "${shell_scripts[@]}"; do
    bash -n "${script}"
  done

  echo "Run shellcheck"
  shellcheck -x "${shell_scripts[@]}"
fi

duplicated_installers=(
  15-java.sh
  16-gradle.sh
  17-database-clients.sh
  20-python.sh
  25-node.sh
  35-rust.sh
)

for installer in "${duplicated_installers[@]}"; do
  reference="scripts/os-installers/distro/alpine/install/${installer}"
  for candidate in scripts/os-installers/distro/*/install/"${installer}"; do
    if ! cmp -s "${reference}" "${candidate}"; then
      echo "${candidate} differs from ${reference}" >&2
      exit 1
    fi
  done
done

# Schemas
check-jsonschema \
  --schemafile validation/config.schema.json \
  config.yml

check-jsonschema \
  --schemafile validation/base.schema.json \
  bases/*/base.yml

check-jsonschema \
  --schemafile validation/base-build.schema.json \
  bases/*/base-build.yml

check-jsonschema \
  --schemafile validation/packages.json \
  bases/*/packages/packages.yml

mapfile -t resolved_package_files < <(
  find bases -path '*/packages/*.yml' -not -name packages.yml -type f 2>/dev/null | sort
)

if [[ ${#resolved_package_files[@]} -gt 0 ]]; then
  check-jsonschema \
    --schemafile validation/package-versions.json \
    "${resolved_package_files[@]}"
fi
