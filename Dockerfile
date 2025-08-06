FROM alpine:3.15.0

LABEL maintainer="https://github.com/power4j/mvnd-docker"

ARG BASE_IMAGE
ARG ALPINE_CN

RUN if [[ "${ALPINE_CN}" = "true" ]] ; then \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories ; \
    fi

RUN apk update \
    && apk upgrade \
    && apk add --no-cache wget unzip curl

ARG MVND_VERSION=latest
ARG MVND_ARCHIVE_FILE

ARG MVND_DOWNLOAD_URL=https://github.com/apache/maven-mvnd/releases/download/${MVND_VERSION}/${MVND_ARCHIVE_FILE}

RUN if [[ "$MVND_VERSION" = "latest" || "$MVND_VERSION" = "dev" ]];then \
    echo "Downloading latest version of mvnd" ; \
    curl -fsSL -o mvnd.zip `wget -qO- -t1 -T2 "https://api.github.com/repos/apache/maven-mvnd/releases/latest" | grep "browser_download_url" | grep "${MVND_ARCHIVE_FILE}" | head -n 1 | awk -F ': "' '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'` ; \
    else \
    echo "Downloading version ${MVND_VERSION} of mvnd" ; \
    curl -fsSL -o mvnd.zip ${MVND_DOWNLOAD_URL} ; \
    fi

RUN mkdir -p /tmp/zip \
    && unzip mvnd.zip -d /tmp/zip \
    && mv /tmp/zip/`ls /tmp/zip | head -n 1` /tmp/mvnd

RUN rm -rf /var/cache/apk/* && rm -rf /tmp/zip

FROM ${BASE_IMAGE}

COPY --from=0 /tmp/mvnd /usr/local/mvnd

ENV MVND_HOME=/usr/local/mvnd

ENV PATH=.:$MVND_HOME/bin:$PATH

CMD ["mvnd"]