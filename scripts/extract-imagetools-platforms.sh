#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "用法: $0 [inspect_output_file]" >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then
  input_stream=$(cat "$1")
else
  input_stream=$(cat)
fi

printf '%s\n' "$input_stream" \
  | awk '
      /^[[:space:]]*Platform:[[:space:]]*/ {
        sub(/^[[:space:]]*Platform:[[:space:]]*/, "", $0)
        if ($0 != "" && $0 != "unknown/unknown") {
          print $0
        }
      }
    ' \
  | sort -u \
  | paste -sd, -
