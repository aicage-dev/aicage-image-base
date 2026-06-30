#!/usr/bin/env bats

@test "go toolchain present" {
  run docker run --rm \
    --env AICAGE_WORKSPACE=/workspace \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -c '
      set -euo pipefail
      command -v go
      cat >/tmp/hello.go <<'"'"'EOF'"'"'
package main

import "fmt"

func main() {
  fmt.Println("ok-go")
}
EOF
      go run /tmp/hello.go | grep -qx ok-go
    '
  [ "$status" -eq 0 ]
}
