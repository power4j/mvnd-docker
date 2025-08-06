ARG BASE_IMAGE
ARG ALPINE_CN

FROM alpine:3.15.0

LABEL maintainer="https://github.com/power4j/mvnd-docker"


RUN if [[ "${ALPINE_CN}" = "true" ]] ; then \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories ; \
    fi

RUN apk update \
    && apk upgrade \
    && apk add --no-cache wget unzip curl


ARG MVND_URL

RUN echo "Downloading mvnd from: $MVND_URL" && \
    curl -fsSL -o mvnd.zip "$MVND_URL"

RUN mkdir -p /tmp/zip \
    && unzip mvnd.zip -d /tmp/zip \
    && mv /tmp/zip/`ls /tmp/zip | head -n 1` /tmp/mvnd

RUN rm -rf /var/cache/apk/* && rm -rf /tmp/zip

FROM ${BASE_IMAGE}

COPY --from=0 /tmp/mvnd /usr/local/mvnd

ENV MVND_HOME=/usr/local/mvnd

ENV PATH=.:$MVND_HOME/bin:$PATH

CMD ["mvnd"]