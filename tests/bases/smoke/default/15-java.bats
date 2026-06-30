#!/usr/bin/env bats

@test "java toolchain present" {
  run docker run --rm \
    --env AICAGE_WORKSPACE=/workspace \
    "${AICAGE_IMAGE_BASE_IMAGE}" \
    -c '
      set -euo pipefail
      command -v java
      command -v javac
      command -v mvn
      command -v ant
      command -v protoc

      mkdir -p /tmp/java-smoke/src
      cat >/tmp/java-smoke/src/Hello.java <<'"'"'EOF'"'"'
public class Hello {
  public static void main(String[] args) {
    System.out.println("ok-java");
  }
}
EOF
      javac -d /tmp/java-smoke/out /tmp/java-smoke/src/Hello.java
      java -cp /tmp/java-smoke/out Hello | grep -qx ok-java

      cat >/tmp/java-smoke/build.xml <<'"'"'EOF'"'"'
<project name="smoke" default="hello">
  <target name="hello">
    <echo message="ok-ant"/>
  </target>
</project>
EOF
      ant -f /tmp/java-smoke/build.xml hello | grep -qx ".*ok-ant"

      cat >/tmp/java-smoke/hello.proto <<'"'"'EOF'"'"'
syntax = "proto3";

message Hello {
  string message = 1;
}
EOF
      mkdir -p /tmp/java-smoke/proto-out
      protoc --java_out=/tmp/java-smoke/proto-out /tmp/java-smoke/hello.proto
      test -f /tmp/java-smoke/proto-out/HelloOuterClass.java
    '
  [ "$status" -eq 0 ]
}
