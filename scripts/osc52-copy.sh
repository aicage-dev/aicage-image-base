#!/usr/bin/env sh
set -eu

# osc52-copy.sh
# Container-to-host clipboard shim for terminal sessions that support OSC 52.

MAX_PAYLOAD=102400
self="$(basename "$0")"

# Match the basic copy-side behavior of the command name we were invoked as.
# Read-back flags are treated as successful no-ops because OSC 52 is write-only.
case "$self" in
  xclip)
    for arg in "$@"; do
      case "$arg" in
        -o | -out | --output)
          exit 0
          ;;
      esac
    done
    set --
    ;;
  xsel)
    for arg in "$@"; do
      case "$arg" in
        -o | --output)
          exit 0
          ;;
      esac
    done
    set --
    ;;
  pbcopy | wl-copy)
    set --
    ;;
esac

# Bound the payload size before encoding so one accidental large copy does not
# flood the terminal stream or overrun common OSC 52 clipboard expectations.
if [ "$#" -gt 0 ]; then
  payload="$(printf '%s' "$*" | head -c "$MAX_PAYLOAD")"
else
  payload="$(head -c "$MAX_PAYLOAD")"
fi

[ -n "$payload" ] || exit 1

# Write directly to the controlling terminal rather than stdout so callers can
# still pipe or capture normal command output without swallowing the escape.
encoded="$(printf '%s' "$payload" | base64 | tr -d '\n')"
printf '\033]52;c;%s\007' "$encoded" >/dev/tty
