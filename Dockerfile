FROM ghcr.io/linuxserver/baseimage-rdesktop-web:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BETA=true
ARG COMPASS_RELEASE=1.34.0-beta.6
LABEL build_version="mmarcon mdb compass version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="mmarcon"

ENV \
  CUSTOM_PORT="8080" \
  GUIAUTOSTART="true" \
  HOME="/config" \
  TITLE="MongoDB Compass"

# Some of the libraries and dependencies below are needed
# some are probably not needed but they don't hurt either
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dbus \
    fcitx-rime \
    fonts-wqy-microhei \
    libnss3 \
    libopengl0 \
    libqpdf28 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    poppler-utils \
    python3 \
    python3-xdg \
    ttf-wqy-zenhei && \
  apt-get install -y \
    speech-dispatcher
  RUN echo "**** install compass ****" && \
  [ "$BETA" = "true" ] && COMPASS_URL="https://downloads.mongodb.com/compass/beta/mongodb-compass-beta_${COMPASS_RELEASE}_amd64.deb" || COMPASS_URL="https://downloads.mongodb.com/compass/mongodb-compass_${COMPASS_RELEASE}_amd64.deb" && \
  curl -o /tmp/compass.deb -L $COMPASS_URL && \
  dpkg -i /tmp/compass.deb || true && \
  apt-get -f -y install && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

## Configure OpenBox to autostart Compass
RUN echo 'mongodb-compass-beta $(cat ~/connection-string.txt) &' >> /etc/xdg/openbox/autostart 