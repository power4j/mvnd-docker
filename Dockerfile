ARG BASE_IMAGE=eclipse-temurin:17-jdk-jammy
ARG ALPINE_CN=false

FROM alpine:3.15.0

LABEL maintainer="https://github.com/power4j/mvnd-docker"


RUN if [[ "${ALPINE_CN}" = "true" ]] ; then \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories ; \
    fi

RUN apk update \
    && apk upgrade \
    && apk add --no-cache wget unzip curl


ARG MVND_URL_LINUX_AMD64
ARG MVND_URL_DARWIN_AMD64
ARG MVND_URL_DARWIN_ARM64
ARG TARGETPLATFORM

RUN echo "Building for platform: $TARGETPLATFORM,Use base image: $BASE_IMAGE" && \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        MVND_URL="$MVND_URL_LINUX_AMD64"; \
    elif [ "$TARGETPLATFORM" = "darwin/amd64" ]; then \
        MVND_URL="$MVND_URL_DARWIN_AMD64"; \
    elif [ "$TARGETPLATFORM" = "darwin/arm64" ]; then \
        MVND_URL="$MVND_URL_DARWIN_ARM64"; \
    else \
        echo "Unsupported platform: $TARGETPLATFORM"; \
        exit 1; \
    fi && \
    echo "Downloading mvnd from: $MVND_URL" && \
    curl -fsSL -o mvnd.zip "$MVND_URL"

RUN mkdir -p /tmp/zip \
    && unzip mvnd.zip -d /tmp/zip \
    && mv /tmp/zip/`ls /tmp/zip | head -n 1` /tmp/mvnd

RUN rm -rf /var/cache/apk/* && rm -rf /tmp/zip


FROM ${BASE_IMAGE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends git git-lfs \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /tmp/mvnd /usr/local/mvnd

ENV MVND_HOME=/usr/local/mvnd
ENV MAVEN_HOME=$MVND_HOME/mvn
ENV PATH=.:$MVND_HOME/bin:$MAVEN_HOME/bin:$PATH

RUN mkdir -p $HOME/.m2


CMD ["mvnd"]