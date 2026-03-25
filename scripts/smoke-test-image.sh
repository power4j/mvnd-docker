#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "用法: $0 <image_tag> <platform>" >&2
  exit 1
fi

image_tag="$1"
platform="$2"
docker_bin="${DOCKER_BIN:-docker}"

run_in_image() {
  "$docker_bin" run --rm --platform "$platform" "$image_tag" "$@"
}

run_in_image uname -a
run_in_image java -version
run_in_image mvnd --version
run_in_image mvn -v
run_in_image sh -c 'echo "MVND_HOME: $MVND_HOME" && $MVND_HOME/bin/mvnd --version'
