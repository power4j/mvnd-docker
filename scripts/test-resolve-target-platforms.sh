#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT_PATH="$ROOT_DIR/scripts/resolve-target-platforms.sh"

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

run_case() {
  local cpu_arch="$1"
  local has_mvnd_amd64="$2"
  local has_mvnd_arm64="$3"
  local has_base_amd64="$4"
  local has_base_arm64="$5"

  declare -gA CASE_RESULT=()

  while IFS='=' read -r key value; do
    CASE_RESULT["$key"]="$value"
  done < <("$SCRIPT_PATH" "$cpu_arch" "$has_mvnd_amd64" "$has_mvnd_arm64" "$has_base_amd64" "$has_base_arm64")
}

if [[ ! -x "$SCRIPT_PATH" ]]; then
  echo "缺少待测脚本: $SCRIPT_PATH" >&2
  exit 1
fi

run_case all true true true true
assert_eq "linux/amd64,linux/arm64" "${CASE_RESULT[resolved_platforms]:-}" "双架构解析结果"
assert_eq "amd64,aarch64" "${CASE_RESULT[resolved_arches]:-}" "双架构标签结果"
assert_eq "2" "${CASE_RESULT[resolved_count]:-}" "双架构数量"
assert_eq "false" "${CASE_RESULT[should_skip]:-}" "双架构不应跳过"
assert_eq "" "${CASE_RESULT[skip_reason]:-}" "双架构不应带跳过原因"

run_case all true false true true
assert_eq "linux/amd64" "${CASE_RESULT[resolved_platforms]:-}" "旧版本全架构应仅保留 amd64"
assert_eq "amd64" "${CASE_RESULT[resolved_arches]:-}" "旧版本全架构标签"
assert_eq "1" "${CASE_RESULT[resolved_count]:-}" "旧版本全架构数量"
assert_eq "false" "${CASE_RESULT[should_skip]:-}" "旧版本全架构不应整体跳过"

run_case aarch64 true false true true
assert_eq "" "${CASE_RESULT[resolved_platforms]:-}" "旧版本 arm64 专用不应解析出平台"
assert_eq "" "${CASE_RESULT[resolved_arches]:-}" "旧版本 arm64 专用不应解析出标签"
assert_eq "0" "${CASE_RESULT[resolved_count]:-}" "旧版本 arm64 专用数量应为 0"
assert_eq "true" "${CASE_RESULT[should_skip]:-}" "旧版本 arm64 专用应跳过"
assert_contains "Linux Arm64" "${CASE_RESULT[skip_reason]:-}" "旧版本 arm64 专用应给出清晰原因"

run_case all true true true false
assert_eq "linux/amd64" "${CASE_RESULT[resolved_platforms]:-}" "基础镜像仅 amd64 时应只保留 amd64"
assert_eq "amd64" "${CASE_RESULT[resolved_arches]:-}" "基础镜像仅 amd64 时标签"
assert_eq "1" "${CASE_RESULT[resolved_count]:-}" "基础镜像仅 amd64 时数量"
assert_eq "false" "${CASE_RESULT[should_skip]:-}" "基础镜像仅 amd64 时不应整体跳过"

echo "平台解析脚本测试通过"
