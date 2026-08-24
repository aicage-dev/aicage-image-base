#!/usr/bin/env bash
set -euo pipefail

dnf -y install \
  ruby \
  ruby-devel \
  rubygem-bundler
