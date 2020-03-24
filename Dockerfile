FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

ENV SDR=airspy-mini

VOLUME ["/opt/output"]

RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common \
        build-essential \
        doxygen \
        wget \
        libssl-dev

WORKDIR /usr/src

RUN wget https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0.tar.gz && \
    tar -xzf cmake-3.17.0.tar.gz
WORKDIR /usr/src/cmake-3.17.0
RUN ./bootstrap &&\
    make -j$(nproc) &&\
    make install

RUN add-apt-repository ppa:gnuradio/gnuradio-releases
RUN apt install -y git \
        liborc-0.4-dev \
        libairspy-dev \
        libairspyhf-dev \
        libsoapysdr-dev \
        librtlsdr-dev \
        gnuradio \
        gnuradio-dev \
        gr-osmosdr

WORKDIR /usr/src
RUN git clone https://github.com/osmocom/gr-osmosdr &&\
    mkdir /usr/src/gr-osmosdr/build
WORKDIR /usr/src/gr-iridium/build
RUN cmake ../ &&\
    make -j$(nproc)&& \
    make install &&\
    ldconfig

WORKDIR /usr/src
RUN git clone https://github.com/muccc/gr-iridium &&\
    mkdir /usr/src/gr-iridium/build
WORKDIR /usr/src/gr-iridium/build
RUN cmake ../ &&\
    make -j$(nproc)&& \
    make install &&\
    ldconfig

ADD ./airspy-mini.conf /usr/src/gr-iridium/examples/

RUN cp -r /usr/local/lib/python3/dist-packages/* /usr/local/lib/python3.6/dist-packages/ &&\
    chown -R root:root /usr/local/lib/python3.6/dist-packages/

ENTRYPOINT iridium-extractor -D 4 /usr/src/gr-iridium/examples/$SDR.conf | grep "A:OK" > /opt/output/output.bits
