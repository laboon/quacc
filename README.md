# cryptoquality
A Cryptocurrency code quality analyzer  

To run, the following dependencies are needed:  

__Lizard__  
```shell
pip install lizard
```  

__CPPCheck__  
```shell
sudo apt-get install cppcheck
```  

__LCOV__  
```shell
sudo apt-get install lcov
```  

__cmake__  
```shell
sudo apt-get install cmake
```  


The following dependencies are used by some or all of the cryptocurrencies:  

```shell
sudo apt-get install autoconf \
automake \
autotools-dev \
bsdmainutils \
build-essential \
curl \
doxygen \
graphviz \
g++-multilib \
libboost-all-dev \
libboost-chrono-dev \
libboost-filesystem-dev \
libboost-program-options-dev \
libboost-system-dev \
libboost-test-dev \
libboost-thread-dev \
libcurl4-openssl-dev \
libc6-dev \
libevent-dev \
libgtest-dev \
libleveldb-dev \
libminiupnpc-dev \
libreadline-dev \
libssl-dev \
libtool \
libunbound-dev \
libunwind8-dev \
libzmq3-dev
miniupnpc \
m4 \
ncurses-dev \
pkg-config \
python-zmq \
python3 \
unzip \
wget \
zlib1g-dev \
```  

Once all dependencies have been installed, the report can be generated by entering the command:  
```shell
./genhtml.py
```

To add a new cryptocurrency, ensure the following conventions are followed:  
- The script to build the crypto can be called from the command line via <_cryptoname_\>.sh  
- The results of lizard for the **uncompiled** code are stored in a file <_cryptoname_\>lizarduncomp.txt  
- The results of lizard for the **compiled** code are stored in a file <_cryptoname_\>lizard.txt  
- A file <_cryptoname_\>url.txt is present in the crypto's directory and contains the url for the crypto's github page on a single line
- The time it takes for the script to run is stored in a file <_cryptoname_\>time.txt and only contains the time it takes the script to run in milliseconds  
- The results of CPP-Check are stored in a file <_cryptoname_\>cppcheck.txt and contain both errors and warnings  
- The results of the lcov report are stored in a directory named 'lcov' and this directory is in the same directory as <_cryptoname_\>.sh  

If all these conventions are followed, you can simply two lines to genhtml.py:  
- runscript("<_cryptoname_\>")
- generate("<_cryptoname_\>")  

Now, when genhtml.py is run, it will automatically build the cryptocurrency and add the results to the report.html file
