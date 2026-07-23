#!/usr/bin/env bash
set -euo pipefail

pacman -S --noconfirm --needed \
  wl-clipboard \
  xclip \
  xsel
