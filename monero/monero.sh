
# Monero Code Analysis

# If starting on a new machine, use the following line to install necessary dependencies:
#sudo apt-get install build-essential cmake libboost-all-dev miniupnpc \
#libunbound-dev graphviz doxygen libunwind8-dev pkg-config libssl-dev \
#libcurl4-openssl-dev libgtest-dev libreadline-dev libminiupnpc-dev libzmq3-dev


# Assumes the path will be wherever this script is called from
XMR_PATH=$(pwd)
start=`date +%s`
# Downloading latest version of monero
# If monero repo doesn't exist, clone down entire thing
# Else, just pull down latest version
if [ ! -d "${XMR_PATH}/monero" ]; then
  git clone -q --recursive https://github.com/monero-project/monero.git
else
  cd monero
   GIT_UPDATE=$(git pull)
  #if [ "${GIT_UPDATE}" = 'Already up-to-date.' ]; then
	#echo "No updates since last run, exiting"
	#exit
  #fi
  cd ..
fi

echo "Running lizard on source code..."
# "Running lizard on source code"
lizard monero/src 1>monerolizarduncomp.txt

# Trim the output file
../lizardtrim.py monerolizarduncomp.txt

echo "Running cppcheck..."
# Running cppcheck on source code
cppcheck -j 750 -q --force --enable=warning monero/src 2>monerocppcheck.txt

# Here I am replacing the downloaded copy of the top-level CMakeLists.txt
# with my own local version that has the appropriate flags set to support lcov
cd monero
rm CMakeLists.txt
cd ..
cp CMakeLists.txt monero

echo "Building Monero..."
# Compile Monero without optimizations
cd monero
make debug
cd ..
echo "Done building"

lizard monero/src 1>monerolizard.txt
../lizardtrim.py monerolizard.txt

# Clear lcov data directory from previous run
echo "Preparing coverage analysis"
echo "Cleaning previous run..."
if [ -d "${XMR_PATH}/lcov" ]; then
  rm -r lcov
fi
mkdir lcov

# Run lcov initially, get base data
lcov --directory monero --zerocounters
lcov --capture --initial --directory monero --output-file coverageBase.info

# Run relevant tests
echo "Running tests..."
# Run crypto tests
cd monero/build/debug/tests/crypto
ctest
# Run hash tests
cd ..
cd hash
ctest
# Run unit tests
cd ..
cd unit_tests
ctest

# Return to top-level directory, then run lcov again
cd ../../../../..
echo "Collecting coverage data..."
lcov --capture --directory monero --output-file coverageTest.info
lcov --add-tracefile coverageBase.info --add-tracefile coverageTest.info --output-file coverageAll.info
# Extract only the information about relevant lines 
#(before these operations, coverageAll.info contained mostly data about external libraries)
lcov --extract coverageAll.info *src/* --output-file temp1Coverage.info
lcov --extract coverageAll.info *tests/* --output-file temp2Coverage.info
lcov --add-tracefile temp1Coverage.info --add-tracefile temp2Coverage.info --output-file coverageFinal.info


# Generate HTML coverage report
echo "Generating index.html..."
genhtml coverageFinal.info --output-directory ${XMR_PATH}/lcov 

# Clean up extra .info files (keep coverageFinal.info just in case)
rm coverageBase.info
rm coverageTest.info
rm coverageAll.info
rm temp1Coverage.info
rm temp2Coverage.info


echo "Done"
end=`date +%s`
echo $((end - start)) > ${XMR_PATH}/monerotime.txt
exit
