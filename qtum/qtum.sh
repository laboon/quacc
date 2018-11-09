#!/bin/sh
# ^ Shebang allows this script to be called from command line via './qtum.sh'

# Sets start time for this script to be used in timing
start=`date +%s`

# Sets the current directory as the 'root' of the qtum directory
QTUM_PATH=$(pwd)

# Check if directory 'qtum' exists, if not, clone it from the repo
# Otherwise, pull from the repo and see if there have been changes
# since this script was run last, if not, exit
if [ ! -d "${QTUM_PATH}/qtum" ]; then
	git clone https://github.com/qtumproject/qtum.git --recursive
	cd qtum
else
	cd qtum
	GIT_UPDATE=$(git pull)
	
	if [ "${GIT_UPDATE}" = 'Already up-to-date.' ]; then
		echo "No updates since last run, exiting"
		exit
	fi
fi

# Check to see if lizard is installed, if so, run it on the repo and output the results to 'qtumlizarduncomp.txt'
# otherwise, print a message indicating lizard needs to be installed, then exit
if which lizard >/dev/null; then
	echo "Running lizard"
	lizard -l cpp > ../qtumlizarduncomp.txt
else
	echo "Lizard not found, please install lizard to complete analysis"
	exit
fi

echo "Trimming lizard results"
../../lizardtrim.py ../qtumlizarduncomp.txt


# Check that lcov is installed, if not print a message indicating it needs to be installed
# then exit, otherwise, just continue with the script
if ! which lcov >/dev/null; then
	echo "lcov not found, please install lcov to complete analysis"
	exit
fi

echo "Performing configuration"

# Perform required configuration before building and direct the output to null
./autogen.sh -q > /dev/null 2>&1

# More configuration required before making
# We apparently have to enable wallet for the cpp o files to be made properly
# The without gui option indicates we do not want to build the gui, just a headless implementation
# The enable lcov option will generate the .gcno files necessary for lcov code coverage tests
export BDB_PREFIX='/db4'
./configure -q BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-wallet --enable-lcov --with-incompatible-bdb --without-gui > /dev/null 2>&1

echo "Making..."

# actualy make the node, direct the output to null
make > /dev/null 2>&1

# Run cppcheck on the node
	# the -j option indicates how many threads we would like to use to do the checking (The more the merrier right?)
	# the -q option is quiet, we don't want the progress printed to the screen, remove if you'd like to see the progress
	# the --force (or equivalent -f) option tells cppcheck to go down through all the if/else branches and check them, will get an error without this option
	# the --enable-warning option tells cppcheck to output warnings in addition to errors as it checks the code
if which cppcheck >/dev/null; then
	echo "Running cppcheck"
	cppcheck -j 750 -q --force --enable=warning src 2> ../qtumcppcheck.txt
else
	echo "Cppcheck not found, please install cppcheck to complete analysis"
	exit
fi


echo "Running lizard on compiled code"

# Run lizard on the compiled code and output the results to the file 'qtumlizard.txt'
lizard -l cpp > ../qtumlizard.txt

# Using the script 'trimlizard.py' parse out the necessary numbers from the lizard results
# Those number will be the number of lines of code and the cyclomatic complexity
# These will be the only two numbers in the file after this script is run
echo "Trimming lizard results"
../../lizardtrim.py ../qtumlizard.txt

# The test executables live here after making, thus move to this directory so they can be run
cd src/test

echo "Running unit tests"
./test_qtum
# ./test_bitcoin_qt

echo "Clearing previous tests"

# Clears previous lcov findings in the 'src/test/data' directory
lcov --zerocounts --directory . > /dev/null 2>&1

# The two lines below copy the .gcno and .gcda files from the src/test/ directory to the current directory, '/src/test/data'
cp ../*.gcno .

cp ../*.gcda .

echo "Generating test logs"

# This is where the .info file is generated by lcov, which breaks down the code coverage
# The directory option indicates that the .gcno and .gcda files are in the current directory (note the '.')
# The capture option indicates we want to collect code coverage information from the .gcno and .gcda files
# The output file option names the resulting .info file whatever we wish to call it (Here, qtum_test)
# The redirect at the end simply directs the output of lcov to null as it spits out a lot of info we don't need
# while it is running
lcov --directory . --capture --output-file qtum_test.info > /dev/null 2>&1

echo "Generating coverage report"

# This generates some html from the .info file we created above
# Again, we redirect the output to null as there's a lot of unneccessary info generated in the process
genhtml -o ../../../../lcov qtum_test.info > /dev/null 2>&1

# Stores the ending time of the running of this script
end=`date +%s`

# Calculates the amount of time it took for this script to be run and outputs the result
# in the file 'qtumtime.txt'
echo $((end - start)) > ../../../qtumtime.txt

exit
