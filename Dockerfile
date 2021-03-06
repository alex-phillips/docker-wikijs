FROM lsiobase/alpine:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG WIKIJS_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

# environment settings
ENV HOME="/app"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
    nodejs \
    npm && \
 apk add --no-cache --virtual=build-dependencies \
    curl && \
 echo "**** install wiki.js ****" && \
 mkdir -p /app/wiki && \
 if [ -z ${WIKIJS_RELEASE} ]; then \
	WIKIJS_RELEASE=$(curl -sX GET "https://api.github.com/repos/Requarks/wiki/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/wiki.tar.gz -L \
	"https://github.com/Requarks/wiki/archive/${WIKIJS_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/wiki.tar.gz -C \
	/app/wiki/ --strip-components=1 && \
 cd /app/wiki && \
 npm i --no-dev && \
 npm run build && \
 echo "**** cleanup ****" && \
 apk del --purge \
    build-dependencies && \
 rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000
