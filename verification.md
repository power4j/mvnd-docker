# 验证报告

- 日期：2026-03-24
- 执行者：Codex
- 任务：mvnd 1.0.5 Linux AArch64 GitHub Actions 改造实施

## 已执行验证

- `bash scripts/test-resolve-target-platforms.sh`
  - 结果：通过
- `bash scripts/test-smoke-test-image.sh`
  - 结果：通过
- `git diff --check`
  - 结果：通过
- `python3 -c 'import pathlib, yaml; yaml.safe_load(pathlib.Path(".github/workflows/docker-build.yml").read_text()); yaml.safe_load(pathlib.Path(".github/workflows/ci.yml").read_text()); yaml.safe_load(pathlib.Path(".github/workflows/push-images.yml").read_text())'`
  - 结果：通过
- `docker buildx build --platform linux/amd64 --load --tag power4j/mvnd:local-temurin-17-jdk-jammy-amd64 --build-arg MVND_VERSION=1.0.5 --build-arg BASE_IMAGE=eclipse-temurin:17-jdk-jammy .`
  - 结果：通过
- `./scripts/smoke-test-image.sh power4j/mvnd:local-temurin-17-jdk-jammy-amd64 linux/amd64`
  - 结果：通过
- `docker buildx build --platform linux/arm64 --load --tag power4j/mvnd:local-temurin-17-jdk-jammy-aarch64 --build-arg MVND_VERSION=1.0.5 --build-arg BASE_IMAGE=eclipse-temurin:17-jdk-jammy .`
  - 结果：通过
- `./scripts/smoke-test-image.sh power4j/mvnd:local-temurin-17-jdk-jammy-aarch64 linux/arm64`
  - 结果：通过
- `rg -n "1\\.0\\.4|platforms:" README.md README.zh-CN.md .github/workflows`
  - 结果：无输出，说明未残留旧版本示例与旧的 `platforms` 输入

## 最终复检

- 在自审后修正了 `docker-build.yml` 的远端平台校验实现，避免对单架构 tag 使用 `imagetools inspect --raw` 造成误判。
- 修正后重新执行了以下命令：
  - `git diff --check`
  - `python3 -c 'import pathlib, yaml; yaml.safe_load(pathlib.Path(".github/workflows/docker-build.yml").read_text()); yaml.safe_load(pathlib.Path(".github/workflows/ci.yml").read_text()); yaml.safe_load(pathlib.Path(".github/workflows/push-images.yml").read_text())'`
  - `docker buildx build --platform linux/amd64 --load --tag power4j/mvnd:local-temurin-17-jdk-jammy-amd64 --build-arg MVND_VERSION=1.0.5 --build-arg BASE_IMAGE=eclipse-temurin:17-jdk-jammy .`
  - `docker buildx build --platform linux/arm64 --load --tag power4j/mvnd:local-temurin-17-jdk-jammy-aarch64 --build-arg MVND_VERSION=1.0.5 --build-arg BASE_IMAGE=eclipse-temurin:17-jdk-jammy .`
  - `./scripts/smoke-test-image.sh power4j/mvnd:local-temurin-17-jdk-jammy-amd64 linux/amd64`
  - `./scripts/smoke-test-image.sh power4j/mvnd:local-temurin-17-jdk-jammy-aarch64 linux/arm64`
- 结果：全部通过。

## 限制与未执行项

- 未在本地执行 GitHub Actions 远端推送与 manifest 组装，因为这会影响 Docker Hub 远端制品，适合在 GitHub Actions 受控环境中执行。
- 未在本地调用 GitHub Release API 与 `docker buildx imagetools inspect` 远端校验 workflow 路径，因为本轮重点是验证仓库内实现和本地 Docker 构建链路。
