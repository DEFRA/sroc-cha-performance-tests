#!/bin/sh

# Based on examples in https://gist.github.com/mihow/9c7f559807069a03e302605691f85572
#
# Arg1 is the environment to load config for. Arg2 is the JMeter file to load. Examples of how to load it are
#
# $ ./gui.sh dev tests.jmx
# $ ./gui.sh local

dotenv=""

# We don't set a default file. This allows the script to be used to start an instance of JMeter from the command line
# that has all the env vars loaded ready for creating a new test.
testFile=""

# $# is a special variable which gives the number of arguments passed in. $1 and $2 are special variables to access the
# first 2 args (goes up to $9). With this case statement we are saying
#
# - if only one arg is provided we assume its the env file to use
# - if 2 args are provided we assume the first is the env file and the second is the jmx file to load
case $# in
  1)
    dotenv="./environments/.$1.env"
    ;;
  2)
    dotenv="./environments/.$1.env"
    testFile="-t $2"
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
  sh $CMS_JMETER_PATH $testFile
fi
