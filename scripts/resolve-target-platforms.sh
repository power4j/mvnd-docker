#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "用法: $0 <cpu_arch> <has_mvnd_amd64> <has_mvnd_arm64> <has_base_amd64> <has_base_arm64>" >&2
  exit 1
fi

cpu_arch="$1"
has_mvnd_amd64="$2"
has_mvnd_arm64="$3"
has_base_amd64="$4"
has_base_arm64="$5"

validate_bool() {
  case "$1" in
    true|false) ;;
    *)
      echo "非法布尔值: $1" >&2
      exit 1
      ;;
  esac
}

join_csv() {
  local result=""
  local value=""

  for value in "$@"; do
    if [[ -z "$result" ]]; then
      result="$value"
    else
      result="$result,$value"
    fi
  done

  printf '%s' "$result"
}

for value in "$has_mvnd_amd64" "$has_mvnd_arm64" "$has_base_amd64" "$has_base_arm64"; do
  validate_bool "$value"
done

want_amd64=false
want_arm64=false

case "$cpu_arch" in
  amd64)
    want_amd64=true
    ;;
  aarch64)
    want_arm64=true
    ;;
  all)
    want_amd64=true
    want_arm64=true
    ;;
  *)
    echo "不支持的 cpu_arch: $cpu_arch" >&2
    exit 1
    ;;
esac

resolved_platforms=()
resolved_arches=()
skip_reasons=()

collect_platform() {
  local wanted="$1"
  local has_mvnd="$2"
  local has_base="$3"
  local platform="$4"
  local arch_tag="$5"
  local mvnd_reason="$6"
  local base_reason="$7"

  if [[ "$wanted" != "true" ]]; then
    return
  fi

  if [[ "$has_mvnd" != "true" ]]; then
    skip_reasons+=("$mvnd_reason")
    return
  fi

  if [[ "$has_base" != "true" ]]; then
    skip_reasons+=("$base_reason")
    return
  fi

  resolved_platforms+=("$platform")
  resolved_arches+=("$arch_tag")
}

collect_platform "$want_amd64" "$has_mvnd_amd64" "$has_base_amd64" "linux/amd64" "amd64" "该版本不包含 Linux AMD64 资产" "基础镜像不支持 linux/amd64"
collect_platform "$want_arm64" "$has_mvnd_arm64" "$has_base_arm64" "linux/arm64" "aarch64" "该版本不包含 Linux Arm64 资产" "基础镜像不支持 linux/arm64"

resolved_count="${#resolved_platforms[@]}"
should_skip=false
skip_reason=""

if [[ "$resolved_count" -eq 0 ]]; then
  should_skip=true
  skip_reason="$(join_csv "${skip_reasons[@]}")"
fi

echo "resolved_platforms=$(join_csv "${resolved_platforms[@]}")"
echo "resolved_arches=$(join_csv "${resolved_arches[@]}")"
echo "resolved_count=$resolved_count"
echo "should_skip=$should_skip"
echo "skip_reason=$skip_reason"
