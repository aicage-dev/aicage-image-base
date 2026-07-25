# check=skip=InvalidDefaultArgInFrom
ARG FROM_IMAGE
ARG IMAGE_SOURCE_URL

FROM ${FROM_IMAGE} AS from_image

ARG IMAGE_SOURCE_URL
ARG OS_INSTALLER

LABEL org.opencontainers.image.title="aicage-image-base" \
      org.opencontainers.image.description="Prebuilt base layer for agent images" \
      org.opencontainers.image.source="${IMAGE_SOURCE_URL}" \
      org.opencontainers.image.licenses="Apache-2.0"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NPM_CONFIG_PREFIX=/usr/local \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/opt/pipx/bin \
    PATH="/opt/pipx/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

RUN --mount=type=bind,source=scripts/os-installers,target=/tmp/aicage/scripts/os-installers,readonly \
    --mount=type=bind,source=scripts/entrypoint.sh,target=/tmp/aicage/scripts/entrypoint.sh,readonly \
    --mount=type=bind,source=scripts/osc52-copy.sh,target=/tmp/aicage/scripts/osc52-copy.sh,readonly \
    /tmp/aicage/scripts/os-installers/${OS_INSTALLER} && \
    cp /tmp/aicage/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh && \
    echo "Install: Configure optional OSC 52 clipboard shims ..." && \
    install -d /opt/aicage/clipboard-shims && \
    cp /tmp/aicage/scripts/osc52-copy.sh /opt/aicage/osc52-copy.sh && \
    chmod 755 /opt/aicage/osc52-copy.sh && \
    ln -s ../osc52-copy.sh /opt/aicage/clipboard-shims/wl-copy && \
    ln -s ../osc52-copy.sh /opt/aicage/clipboard-shims/xclip && \
    ln -s ../osc52-copy.sh /opt/aicage/clipboard-shims/xsel && \
    ln -s ../osc52-copy.sh /opt/aicage/clipboard-shims/pbcopy

ENV AICAGE_ENTRYPOINT_CMD=bash

# Use tini from PATH to work across distros (e.g. Alpine installs it in /sbin).
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
