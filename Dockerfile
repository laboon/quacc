FROM ubuntu:14.04
COPY . /app
RUN apt-get update && apt-get install -y \
    cppcheck \
    lcov \
    cmake \
    automake \
    autotools-dev \
    bsdmainutils \
    build-essential \
    doxygen \
    graphviz \
    libboost-all-dev \
    libboost-chrono-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libgtest-dev \
    libleveldb-dev \
    libminiupnpc-dev \
    libreadline-dev \
    libssl-dev \
    libtool \
    libunbound-dev \
    libunwind8-dev \
    libzmq3-dev \
    miniupnpc \
    pkg-config \
    python3 \
    python-pip \
    git \
    software-properties-common
RUN add-apt-repository ppa:george-edison55/cmake-3.x && apt-get update && apt-get -y upgrade
RUN pip install lizard
CMD cd /app && chmod +x */*.sh && chmod 755 lizardtrim.py && python genhtml.py