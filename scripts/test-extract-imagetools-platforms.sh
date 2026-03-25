#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT_PATH="$ROOT_DIR/scripts/extract-imagetools-platforms.sh"

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

if [[ ! -x "$SCRIPT_PATH" ]]; then
  echo "缺少待测脚本: $SCRIPT_PATH" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cat <<'EOF' > "$tmp_dir/single-arch-with-attestation.txt"
Name:      docker.io/power4j/mvnd:tmp-tag-amd64
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:single

Manifests:
  Name:        docker.io/power4j/mvnd:tmp-tag-amd64@sha256:image
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/amd64

  Name:        docker.io/power4j/mvnd:tmp-tag-amd64@sha256:attestation
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    unknown/unknown
  Annotations:
    vnd.docker.reference.digest: sha256:image
    vnd.docker.reference.type:   attestation-manifest
EOF

cat <<'EOF' > "$tmp_dir/multi-arch-with-attestation.txt"
Name:      docker.io/power4j/mvnd:tmp-tag
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:multi

Manifests:
  Name:        docker.io/power4j/mvnd:tmp-tag@sha256:amd64
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/amd64

  Name:        docker.io/power4j/mvnd:tmp-tag@sha256:amd64-attestation
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    unknown/unknown
  Annotations:
    vnd.docker.reference.digest: sha256:amd64
    vnd.docker.reference.type:   attestation-manifest

  Name:        docker.io/power4j/mvnd:tmp-tag@sha256:arm64
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/arm64

  Name:        docker.io/power4j/mvnd:tmp-tag@sha256:arm64-attestation
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    unknown/unknown
  Annotations:
    vnd.docker.reference.digest: sha256:arm64
    vnd.docker.reference.type:   attestation-manifest
EOF

single_arch_result="$("$SCRIPT_PATH" < "$tmp_dir/single-arch-with-attestation.txt")"
assert_eq "linux/amd64" "$single_arch_result" "单架构镜像应忽略 attestation 平台"

multi_arch_result="$("$SCRIPT_PATH" < "$tmp_dir/multi-arch-with-attestation.txt")"
assert_eq "linux/amd64,linux/arm64" "$multi_arch_result" "多架构 manifest 应忽略 attestation 平台"

echo "imagetools 平台提取脚本测试通过"
