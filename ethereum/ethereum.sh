# Ethereum Code Analysis
# ^ Shebang allows this script to be called from command line via './ethereum.sh'

# Sets start time for this script to be used in timing
start=`date +%s`

# Sets the current directory as the 'root' of the ethereum directory
ETHPATH=$(pwd)

# Check to see if the repo has been updated since the last run, if not just exit after 
# printing a message to that effect
# Otherwise, run the script as expected
if [ ! -d "${ETHPATH}/cpp-ethereum" ]; then
	echo "Starting Download of cpp-ethereum Repository"
	git clone --recursive https://github.com/ethereum/cpp-ethereum.git
else
	cd cpp-ethereum
	GIT_OUTPUT=$(git pull)
	
	if [ "${GIT_OUTPUT}" = 'Already up-to-date.' ]; then
		echo "No updates since last run, exiting"
		exit
	fi
	cd ..
fi

echo "Starting Cyclomatic Complexity Analysis on Unbuilt Code"

# Run lizard on the uncompiled code and pipe the results to the file ethereumlizarduncomp.txt
# Then run the lizardtrim script on that file which will result in the file containing two numbers
# The number of lines of code and the average cyclomatic complexity
lizard cpp-ethereum 1>ethereumlizarduncomp.txt

../lizardtrim.py ethereumlizarduncomp.txt

echo "Preparing Build of cpp-ethereum Repository"

# Create a directory in the cpp-ethereum directory which will contain the built code then run cmake
# to generate a CMakeCache.txt file
cd cpp-ethereum
mkdir build
cd build
cmake .. -DGUI=0 #DGUI=0 may be disabled

# Once build files are written, remove CMakeCache.txt in ../ethereum/cpp-ethereum/build and replace it with
# the version in ../ethereum/ that enables coverage support
# *** DO NOT DELETE THE FILE WITH THE PATH '../ethereum/CMakeCache.txt' OTHERWISE ***
# *** YOU'LL HAVE TO MAKE THE CMAKECACHE FILE AND ALTER IT AGAIN, NOT FUN! ***

rm CMakeCache.txt

# Return to ../ethereum/
cd ..
cd ..

# Replace CMakeCache.txt in cpp-ethereum/build with the one in the current directory (../ethereum/)
cp CMakeCache.txt cpp-ethereum/build

# Run the actual build
echo "Building cpp-ethereum"
cd cpp-ethereum
cd build
# --enable-testing --ctest_coverage
cmake --build .
echo "Build complete"

# Return to ../ethereum/
cd ..
cd ..

# Run cpp-check on built code with 750 threads, forcing all if branches, and outputing warnings as well as errors
echo "Running cppcheck"
cppcheck -j 750 -q --force --enable=warning cpp-ethereum 2> ethereumcppcheck.txt

# Run lizard on the compiled code and pipe the results to the file ethereumlizard.txt
# Then run the lizardtrim script on that file which will result in the file containing two numbers
# The number of lines of code and the average cyclomatic complexity
echo "Running lizard on built code"
lizard cpp-ethereum 1>ethereumlizard.txt

../lizardtrim.py ethereumlizard.txt

# Run coverage test
echo "Running test suite"
cd cpp-ethereum
CPP_ETHEREUM_PATH=$(pwd)
BUILD_DIR=$CPP_ETHEREUM_PATH/build
TEST_MODE=""

# Check for args in command line, alters testing
for i in "$@"
do
case $i in
	-builddir)
	shift
	((i++))
	BUILD_DIR=${!i}
	shift 
	;;
	--all)
	TEST_MODE="--all"
	shift 
	;;
	--filltests)
	TEST_FILL="--filltests"
	shift
	;;
esac
done

# Check to see if code has been built yet, if not tests can't be run and coverage report can't be generated
which $BUILD_DIR/test/testeth >/dev/null 2>&1
if [ $? != 0 ]
then
	echo "You need to compile and build ethereum with cmake -DPROFILING option to the build dir!"
	exit;
fi

# Using lcov, generate the coverage report and output the report.html file to the $ETHPATH directory
OUTPUT_DIR=$BUILD_DIR/test/coverage
if which lcov >/dev/null; then
	if which genhtml >/dev/null; then
		echo Cleaning previous report...
		if [ -d "${OUTPUT_DIR}" ]; then
			rm -r $OUTPUT_DIR
		fi
		mkdir $OUTPUT_DIR
		lcov --directory $BUILD_DIR --zerocounters
		lcov --capture --initial --directory $BUILD_DIR --output-file $OUTPUT_DIR/coverage_base.info

		echo Running testeth...
		$BUILD_DIR/test/testeth $TEST_MODE $TEST_FILL
		$BUILD_DIR/test/testeth -t StateTests --jit $TEST_MODE
		$BUILD_DIR/test/testeth -t VMTests --jit $TEST_MODE

		echo Preparing coverage info...
		lcov --capture --directory $BUILD_DIR --output-file $OUTPUT_DIR/coverage_test.info
		lcov --add-tracefile $OUTPUT_DIR/coverage_base.info --add-tracefile $OUTPUT_DIR/coverage_test.info --output-file $OUTPUT_DIR/coverage_all.info
		lcov --extract $OUTPUT_DIR/coverage_all.info *cpp-ethereum/* --output-file $OUTPUT_DIR/coverage_export.info
		genhtml -o ${ETHPATH}/lcov $OUTPUT_DIR/coverage_export.info
	else
		echo genhtml not found
		exit;
	fi
else
	echo lcov not found
	exit;
fi

# Stores the ending time of the running of this script
end=`date +%s`

# Calculates the amount of time it took for this script to be run and outputs the result
# in the file 'ethereumtime.txt'
echo $((end - start)) > ${ETHPATH}/ethereumtime.txt

exit;
