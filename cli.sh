#!/bin/sh

# Loading of env vars is based on examples in https://gist.github.com/mihow/9c7f559807069a03e302605691f85572
#
# Arg1 is the environment to load config for. Arg2 is the JMeter file to load. Examples of how to load it are
#
# $ ./cli.sh dev tests.jmx
# $ ./cli.sh local

dotenv=""

# Unlike run.sh we DO set a default file. We can't create new tests in CLI mode so there is no point in starting up
# JMeter with just the env vars loaded. tests.jmx currently contains all our tests hence its our default (though we
# set it in the case statement below).
testFile=""
testName=""

# $# is a special variable which gives the number of arguments passed in. $1 and $2 are special variables to access the
# first 2 args (goes up to $9). With this case statement we are saying
#
# - if only one arg is provided we assume its the env file to use
# - if 2 args are provided we assume the first is the env file and the second is the jmx file to load
case $# in
  1)
    dotenv="./environments/.$1.env"
    testFile="tests.jmx"
    ;;
  2)
    dotenv="./environments/.$1.env"
    testFile="$2"
    ;;
  *)
    # Raise an error to the user
    echo "ERROR! You must at least specify the environment as an arg"
    exit 1
    ;;
esac

if [ -f $dotenv ]; then
  # Load Environment Variables
  export $(cat $dotenv | grep -v '^#' | awk '/=/ {print $1}')
  echo "Testing against $CMS_BASE_URL"
  # Extract the suffix from the test file name and drop the .jmx extension. We can then use this to specify exactly
  # which JMeter output file to both delete (from a previous run) and create
  testName=$(basename -s .jmx $testFile)
  # Delete the existing JMeter output file (-f means if it doesn't we won't throw an error)
  rm -f "$testName.jtl"
  sh $CMS_JMETER_PATH -t $testFile -n -l tests.jtl
fi
