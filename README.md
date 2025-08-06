# MVND Docker Images

![Docker Hub Version](https://img.shields.io/docker/v/power4j/mvnd?label=Docker%20Hub)

This repository contains a set of Dockerfiles and GitHub Actions workflows to build multi-platform Docker images for the Apache Maven Daemon (`mvnd`). The project leverages multi-stage builds to create a lean and efficient image that includes both the `mvnd` tool and a specific JDK version.

The images are designed to be flexible, supporting various CPU architectures and Java Development Kit (JDK) versions, allowing you to choose the perfect environment for your Maven projects.

## Features

-   **Multi-Platform Support**: Built for `linux/amd64`, `darwin/amd64`, and `darwin/aarch64`.
-   **Multi-JDK Support**: Images are available for JDK 8 and JDK 17.