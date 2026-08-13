#!/usr/bin/env bash
set -euo pipefail

pacman -S --noconfirm --needed \
  python \
  python-pip \
  python-pipx \
  python-virtualenv
