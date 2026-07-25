#!/usr/bin/env bats

@test "entrypoint activates OSC 52 clipboard shims when enabled" {
  run docker run --rm \
    --entrypoint /bin/bash \
    --env AICAGE_WORKSPACE=/workspace \
    --env AICAGE_HOST_IS_LINUX=true \
    --env AICAGE_UID=1234 \
    --env AICAGE_GID=2345 \
    --env AICAGE_HOST_USER=demo \
    --env AICAGE_HOME=/home/demo \
    --env AICAGE_ENABLE_OSC52_CLIPBOARD=1 \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -lc '
      set -euo pipefail
      /usr/local/bin/entrypoint.sh -c "
        set -euo pipefail
        test \"\$(command -v wl-copy)\" = /opt/aicage/clipboard-shims/wl-copy
        test \"\$(command -v xclip)\" = /opt/aicage/clipboard-shims/xclip
        test \"\$(command -v xsel)\" = /opt/aicage/clipboard-shims/xsel
        test \"\$(command -v pbcopy)\" = /opt/aicage/clipboard-shims/pbcopy
        test \"\$(readlink -f \"\$(command -v wl-copy)\")\" = /opt/aicage/osc52-copy.sh
        test \"\$(readlink -f \"\$(command -v xclip)\")\" = /opt/aicage/osc52-copy.sh
        test \"\$(readlink -f \"\$(command -v xsel)\")\" = /opt/aicage/osc52-copy.sh
        test \"\$(readlink -f \"\$(command -v pbcopy)\")\" = /opt/aicage/osc52-copy.sh
      "
    '
  [ "$status" -eq 0 ]
}
