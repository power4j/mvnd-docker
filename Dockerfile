ARG BASE_IMAGE=eclipse-temurin:17-jdk-jammy
ARG ALPINE_CN=false

FROM alpine:3.15.0 AS downloader

LABEL maintainer="https://github.com/power4j/mvnd-docker"


RUN if [ "${ALPINE_CN}" = "true" ] ; then \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories ; \
    fi

RUN apk update \
    && apk upgrade \
    && apk add --no-cache wget unzip curl


ARG MVND_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN echo "Building for os: ${TARGETOS}, arch: ${TARGETARCH}, base image: ${BASE_IMAGE}" && \
    if [ "${TARGETOS}" != "linux" ]; then \
        echo "Unsupported target os: ${TARGETOS}" >&2; \
        exit 1; \
    fi && \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        MVND_ARCH="amd64"; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
        MVND_ARCH="aarch64"; \
    else \
        echo "Unsupported target arch: ${TARGETARCH}" >&2; \
        exit 1; \
    fi && \
    MVND_URL="https://github.com/apache/maven-mvnd/releases/download/${MVND_VERSION}/maven-mvnd-${MVND_VERSION}-linux-${MVND_ARCH}.zip" && \
    echo "Downloading mvnd from: $MVND_URL" && \
    curl -fsSL -o /tmp/mvnd.zip "$MVND_URL"

RUN mkdir -p /tmp/zip \
    && unzip /tmp/mvnd.zip -d /tmp/zip \
    && mv /tmp/zip/`ls /tmp/zip | head -n 1` /tmp/mvnd

RUN rm -rf /var/cache/apk/* /tmp/zip /tmp/mvnd.zip


FROM ${BASE_IMAGE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends git git-lfs \
    && rm -rf /var/lib/apt/lists/*

COPY --from=downloader /tmp/mvnd /usr/local/mvnd

ENV MVND_HOME=/usr/local/mvnd
ENV MAVEN_HOME=$MVND_HOME/mvn
ENV PATH=.:$MVND_HOME/bin:$MAVEN_HOME/bin:$PATH

RUN mkdir -p $HOME/.m2


CMD ["mvnd"]
