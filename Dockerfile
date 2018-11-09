FROM ubuntu:14.04
COPY . /app
RUN apt-get update && apt-get install -y \
    cppcheck \
    lcov \
    cmake \
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
    libdb++-dev \
    libc6-dev \
    libevent-dev \
    libgtest-dev \
    libleveldb-dev \
    libminiupnpc-dev \
    libreadline-dev \
    libsoduim-dev \
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
    zlib1g-dev \
    pkg-config \
    python3 \
    python-pip \
    git \
    software-properties-common
RUN add-apt-repository ppa:george-edison55/cmake-3.x && apt-get update && apt-get -y upgrade
RUN pip install lizard
CMD cd /app && chmod +x */*.sh && chmod 755 lizardtrim.py && python genhtml.py