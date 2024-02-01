FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV BUILD_FOLDER /tmp/build

RUN mkdir -p ${BUILD_FOLDER}

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -y update && apt-get -y upgrade

# dependency
RUN apt-get install -y \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
    libcurl4-openssl-dev \
    liblua5.3-dev \
    libspeexdsp-dev \
    libconfig-dev \
    pkg-config \
    libtool \
    automake \
    sudo make git doxygen graphviz cmake \
    curl wget lsof vim tcpdump gstreamer1.0-tools

# libnice
RUN cd ${BUILD_FOLDER} \
  && apt-get remove -y libnice-dev libnice10 \
  && apt-get update -y && apt-get install -y python3-pip ninja-build \
  && pip3 install meson \
  && git clone https://gitlab.freedesktop.org/libnice/libnice \
  && cd libnice \
  && meson --prefix=/usr build \
  && ninja -C build \
  && sudo ninja -C build install

# libsrtp
RUN cd ${BUILD_FOLDER} \
  && SRTP="2.3.0" && wget https://github.com/cisco/libsrtp/archive/v$SRTP.tar.gz \
  && tar xfv v$SRTP.tar.gz \
  && cd libsrtp-$SRTP \
  && ./configure --prefix=/usr --enable-openssl \
  && make shared_library && sudo make install

# datachannel build (sctp)
RUN cd ${BUILD_FOLDER} \
  && git clone https://github.com/sctplab/usrsctp \
  && cd usrsctp \
  && ./bootstrap \
  && ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 \
  && make && sudo make install

# libwebsockets
RUN cd ${BUILD_FOLDER} \
  && git clone https://github.com/warmcat/libwebsockets.git \
  && cd libwebsockets \
  && git checkout v4.3-stable \
  && mkdir build \
  && cd build \
  && cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" -DLWS_IPV6="ON" .. \
  && make && sudo make install

# rabbitmq
RUN cd ${BUILD_FOLDER} \
  && git clone https://github.com/alanxz/rabbitmq-c \
  && cd rabbitmq-c \
  && git submodule init \
  && git submodule update \
  && mkdir build && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. \
  && make && sudo make install

## janus if build use --enable-post-processing
RUN apt-get update -y && apt-get install -y libavutil56 libavcodec58 libavformat58 libavutil-dev libavcodec-dev libavformat-dev

# janus
RUN cd ${BUILD_FOLDER} && git clone https://github.com/meetecho/janus-gateway.git \
  && cd janus-gateway \
  && sh autogen.sh \
  && ./configure --prefix=/usr/local \
    --enable-post-processing \
    --enable-docs \
    --disable-mqtt \
    --disable-nanomsg \
    --disable-gelf \
    --disable-mqtt-event-handler \
    --disable-nanomsg-event-handler \
    --disable-gelf-event-handler \
  && make && make install && make configs

# default janus looger directory
RUN mkdir -p /usr/local/lib/janus/loggers

# FFmpeg install
RUN apt update -y && sudo apt install  -y ffmpeg && ffmpeg -version

# nginx
RUN apt-get update -y && apt-get install -y nginx
# COPY ./config/nginx.conf /etc/nginx/nginx.conf

# clean
RUN rm -rf ${BUILD_FOLDER}
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-l", "-euxo", "pipefail", "-c"]

# nginx: 8086, jauns http: 8088, janus websocket: 8188
EXPOSE 8086 8088 8188

# entrypoint 스크립트를 이미지에 추가
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD nginx && /usr/local/bin/janus -F /usr/local/etc/janus

ENTRYPOINT ["/entrypoint.sh"]