# https://www.jacoco.org/jacoco/

ARG jacoco_version=0.8.4
ARG alpine_version=latest
ARG openjdk_version=8u242-jre-slim

FROM alpine:$alpine_version as downloader

ARG jacoco_version
ARG alpine_version

WORKDIR /jacoco

RUN apk update && apk add curl && apk add unzip && \
    checksum=$(curl -f https://www.jacoco.org/jacoco/download/jacoco-$jacoco_version.zip.md5.txt | cut -d ' ' -f 1) && \
    curl -f https://repo1.maven.org/maven2/org/jacoco/jacoco/$jacoco_version/jacoco-$jacoco_version.zip -o jacoco.zip && \
    sum=$(cat jacoco.zip | md5sum | cut -d ' ' -f 1) && \
    if [ ! $sum == $checksum ]; then exit 1; fi && \
    unzip jacoco.zip -d /jacoco && \
    rm jacoco.zip


# https://www.jacoco.org/jacoco/trunk/doc/cli.html
FROM openjdk:$openjdk_version as prod

ARG jacoco_version
ARG openjdk_version

ENV JACOCO_VERSION $jacoco_version

WORKDIR /jacoco/lib

COPY --from=downloader /jacoco/lib/jacococli.jar .

ENTRYPOINT [ "java", "-jar", "/jacoco/lib/jacococli.jar" ]

CMD ["--help"]