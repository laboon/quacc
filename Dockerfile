FROM ubuntu:16.04
COPY . /app
RUN apt-get update && apt-get install -y \
    cppcheck \
    lcov \
    autoconf \
    automake \
    autotools-dev \
    bsdmainutils \
    build-essential \
    curl \
    doxygen \
    graphviz \
    g++-multilib \
    graphviz \
    libboost-all-dev \
    libboost-chrono-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libcurl4-openssl-dev \
    libsodium-dev \
    libdb++-dev \
    libc6-dev \
    libevent-dev \
    libgtest-dev \
    libleveldb-dev \
    libminiupnpc-dev \
    libreadline-dev \
    libsodium-dev \
    libssl-dev \
    libtool \
    libunbound-dev \
    libunwind8-dev \
    libzmq3-dev \
    miniupnpc \
    m4 \
    ncurses-dev \
    pkg-config \
    python-zmq \
    python \
    python3 \
    python-pip \
    git \
    software-properties-common \
    unzip \
    wget \
    zlib1g-dev 

RUN cd /usr/local/src \ 
    && wget https://cmake.org/files/v3.10/cmake-3.10.3.tar.gz \
    && tar xvf cmake-3.10.3.tar.gz \ 
    && cd cmake-3.10.3 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*
RUN pip install lizard "django<2"
CMD cd /app && chmod +x */*.sh && chmod 755 lizardtrim.py && python genhtml.py
