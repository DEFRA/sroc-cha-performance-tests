#!/bin/sh

# When running JMeter using our default command we need to ensure that the /opt/output/report folder is emptied first
# else we'll get an error (it's a JMeter thing!) So, the main purpose of this script is to clear the folder and then
# run our default JMeter CMD.
#
# But there may be times we just want to shell into a container for debug purposes. So, we also have some logic to
# determine if JMeter should be run. If the first arg passed in starts with - then we assume the CMD is passing in
# arguments for JMeter. This could be from our default CMD in the Dockerfile or an overrided passed in the `docker run`
# call. Else we just call whatever was passed in, for example, '/bin/bash'.

# Note - this is a POSIX compatible way of extracting the first character from the first arg passed in. We got errors
# when using the most common examples you find on the internet as they rely on bash features
# Credit https://stackoverflow.com/a/51078275/6117745
if [ "$1" = "${1#-}" ]; then
  $@
else
  rm -rf /opt/output/report && mkdir /opt/report
  jmeter $@
fi
