FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

VOLUME ["/opt/output"]

RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common \
        build-essential \
        cmake \
        doxygen

RUN add-apt-repository ppa:gnuradio/gnuradio-releases
RUN apt install -y git \
        liborc-0.4-dev
        libairspy-dev \
        libairspyhf-dev \
        libsoapysdr-dev \
        librtlsdr-dev \
        gnuradio \
        gnuradio-dev \
        gr-osmosdr

WORKDIR /usr/src
RUN git clone https://github.com/muccc/gr-iridium &&\
    mkdir /usr/src/gr-iridium/build
WORKDIR /usr/src/gr-iridium/build
RUN cmake ../ &&\
    make && \
    make install &&\
    ldconfig

WORKDIR /usr/share
ADD airspy-mini.conf

RUN cp -r /usr/local/lib/python3/dist-packages/* /usr/local/lib/python3.6/dist-packages/ &&\
    chown -R root:root /usr/local/lib/python3.6/dist-packages/

ENTRYPOINT iridium-extractor -D 4 airspy-mini.conf | grep "A:OK" > /opt/output/output.bits
