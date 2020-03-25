FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

ENV SDR=airspy-mini
ENV TZ=Etc/UTC

VOLUME ["/opt/output"]

RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common \
        build-essential \
        doxygen \
        wget \
        libssl-dev

WORKDIR /usr/src

#installing cmake takes an extraordinarily long time
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
        libhackrf-dev \
    #this is all the dependencies for building gnuradio, some of them will be duplicates of previous
    git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy \
    python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
    libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
    liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
    python3-zmq python3-scipy

#FELL THE PAIN OF COMPILING GNURADIO
WORKDIR /usr/src
RUN git clone --recursive https://github.com/gnuradio/gnuradio.git &&\
    mkdir /usr/src/gnuradio/build
WORKDIR /usr/src/gnuradio
RUN git checkout maint-3.8
WORKDIR /usr/src/gnuradio/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 ../ &&\
    make -j$(nproc) &&\
    make install &&\
    ldconfig

WORKDIR /usr/src
RUN git clone https://github.com/osmocom/gr-osmosdr &&\
    mkdir /usr/src/gr-osmosdr/build
WORKDIR /usr/src/gr-osmosdr/build
RUN cmake ../ &&\
    make -j$(nproc) &&\
    make install &&\
    ldconfig

WORKDIR /usr/src
RUN git clone https://github.com/muccc/gr-iridium &&\
    mkdir /usr/src/gr-iridium/build
WORKDIR /usr/src/gr-iridium/build
RUN cmake ../ &&\
    make -j$(nproc) &&\
    make install &&\
    ldconfig

ADD ./airspy-mini.conf /usr/src/gr-iridium/examples/
ADD ./entrypoint.sh /usr/share/

RUN cp -r /usr/local/lib/python3/dist-packages/* /usr/local/lib/python3.6/dist-packages/ &&\
    chown -R root:root /usr/local/lib/python3.6/dist-packages/

ENTRYPOINT /usr/share/entrypoint.sh
