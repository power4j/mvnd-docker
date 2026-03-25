#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT_PATH="$ROOT_DIR/scripts/smoke-test-image.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [[ "$expected" != "$actual" ]]; then
    echo "断言失败: $message" >&2
    echo "期望: $expected" >&2
    echo "实际: $actual" >&2
    exit 1
  fi
}

assert_contains() {
  local expected_fragment="$1"
  local actual="$2"
  local message="$3"

  if [[ "$actual" != *"$expected_fragment"* ]]; then
    echo "断言失败: $message" >&2
    echo "期望包含: $expected_fragment" >&2
    echo "实际: $actual" >&2
    exit 1
  fi
}

if [[ ! -x "$SCRIPT_PATH" ]]; then
  echo "缺少待测脚本: $SCRIPT_PATH" >&2
  exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

FAKE_DOCKER="$TMP_DIR/docker"
LOG_FILE="$TMP_DIR/docker.log"

cat <<'EOF' > "$FAKE_DOCKER"
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$LOG_FILE"
exit 0
EOF

chmod +x "$FAKE_DOCKER"

export LOG_FILE
DOCKER_BIN="$FAKE_DOCKER" "$SCRIPT_PATH" "power4j/mvnd:test-arm64" "linux/arm64"

mapfile -t LINES < "$LOG_FILE"

assert_eq "5" "${#LINES[@]}" "应执行 5 条 smoke test 命令"
assert_contains "run --rm --platform linux/arm64 power4j/mvnd:test-arm64 uname -a" "${LINES[0]}" "第一条命令应检查内核信息"
assert_contains "run --rm --platform linux/arm64 power4j/mvnd:test-arm64 java -version" "${LINES[1]}" "第二条命令应检查 Java 版本"
assert_contains "run --rm --platform linux/arm64 power4j/mvnd:test-arm64 mvnd --version" "${LINES[2]}" "第三条命令应检查 mvnd 版本"
assert_contains "run --rm --platform linux/arm64 power4j/mvnd:test-arm64 mvn -v" "${LINES[3]}" "第四条命令应检查 mvn 版本"
assert_contains "run --rm --platform linux/arm64 power4j/mvnd:test-arm64 sh -c echo \"MVND_HOME: \$MVND_HOME\" && \$MVND_HOME/bin/mvnd --version" "${LINES[4]}" "第五条命令应检查 MVND_HOME 下的 mvnd"

echo "smoke test 脚本测试通过"
