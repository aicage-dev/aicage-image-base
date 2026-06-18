#!/usr/bin/env bash
set -euo pipefail

pacman -S --noconfirm --needed \
  docker \
  docker-buildx \
  docker-compose
