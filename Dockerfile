# check=skip=InvalidDefaultArgInFrom
ARG FROM_IMAGE
ARG IMAGE_SOURCE_URL

FROM ${FROM_IMAGE} AS from_image

ARG IMAGE_SOURCE_URL
ARG OS_INSTALLER
ARG PRE_INSTALL
ARG POST_INSTALL
ARG PACKAGE_ENV_FILE

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
    --mount=type=bind,source=${PACKAGE_ENV_FILE},target=/tmp/aicage/package.env,readonly \
    if [ -f /tmp/aicage/package.env ]; then \
      set -a; \
      . /tmp/aicage/package.env; \
      set +a; \
    fi && \
    /tmp/aicage/scripts/os-installers/${PRE_INSTALL} && \
    /tmp/aicage/scripts/os-installers/${OS_INSTALLER} && \
    /tmp/aicage/scripts/os-installers/${POST_INSTALL} && \
    cp /tmp/aicage/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

ENV AICAGE_ENTRYPOINT_CMD=bash

# Use tini from PATH to work across distros (e.g. Alpine installs it in /sbin).
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
