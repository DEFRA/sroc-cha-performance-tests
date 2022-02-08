FROM openjdk:8-slim-bullseye

# Let folks know who created the image. You might see MAINTAINER <name> in older
# examples, but this instruction is now deprecated
LABEL org.opencontainers.image.authors="alan.cruikshanks@defra.gov.uk"
LABEL org.opencontainers.image.description="JMeter based performance tests for the Charging Module API service"
LABEL uk.gov.defra.jmeter-version="5.4.3"

# ARG values are only available whe building the image. We use these to simplify things when we want to update the
# version of something used. It means we only have to set the version in one place.
ARG JMETER_VERSION=5.4.3
ARG JMETER_PLUGINS_MANAGER_VERSION=1.7
ARG CMDRUNNER_JAR_VERSION=2.2

# These are values we want set in any container created from this image
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV PATH=${JMETER_HOME}/bin:$PATH

RUN apt-get update \
  && apt-get install -y curl \
  && rm -rf /var/lib/apt/lists/*

# Start in the /tmp folder and download everything there. We'll be hopping into other folders as we process the next
# RUN command
WORKDIR /tmp

# Explanation
# - Download JMeter tar gzip file
# - Download matching sha12 file
# - Confirm the checksum of the tar file (makes sure we haven't downloaded something dodgy or corrupt!)
# - Extract JMeter: -x = extract all files, -z = confirm its a gzip archive, -f = confirm its a file and not a tape
#   drive! -C directory to extract to
# - Remove the tar gzip and sha12 file we downloaded
# - Download JMeter plugin manager and save it directly to jmeter's /lib/ext folder (used for JMeter components and
#   plugins)
# - Download cmdrunner, a tool needed to use the plugin manager outside the GUI and place it in the JMeter lib folder
#  (see https://jmeter-plugins.org/wiki/PluginsManagerAutomated/)
# - Install PluginsManagerCMD.sh using cmdrunner. The script is used for installing JMeter plugins
# - Use PluginsManagerCMD.sh to install the plugins we need
# - Create the /opt/output/report directory. /opt/output should be mounted in the docker run command in order to access the
#   jmeter results, log, and generated HTML reports (found in /report) from the host
RUN curl --location --show-error --output apache-jmeter-${JMETER_VERSION}.tgz https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
  && curl --location --show-error --output apache-jmeter-${JMETER_VERSION}.tgz.sha512 https://www.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz.sha512 \
  && sha512sum -c apache-jmeter-${JMETER_VERSION}.tgz.sha512 \
  && tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
  && rm -R -f apache* \
  && curl --location --show-error --output ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/${JMETER_PLUGINS_MANAGER_VERSION}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar \
  && curl --location --show-error --output ${JMETER_HOME}/lib/cmdrunner-${CMDRUNNER_JAR_VERSION}.jar https://repo1.maven.org/maven2/kg/apc/cmdrunner/${CMDRUNNER_JAR_VERSION}/cmdrunner-${CMDRUNNER_JAR_VERSION}.jar \
  && java -cp ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
  && PluginsManagerCMD.sh install jpgc-functions,jpgc-dummy \
  && mkdir -p /opt/output/report

# Set the working directory as /opt. If any one ever shells into a running container this is where they'll start
WORKDIR /opt

# Copy files from the project
# - log4j2.xml is a customised version of what comes with JMeter and allows us to send the log output to the console.
#   This means it will be streamed out when `docker run` is called
# - entrypoint.sh is always run and handles deleting the /opt/output/report if jmeter is to be run. Else it just runs
#   whatever command is passed to `docker run`
COPY docker/log4j2.xml docker/entrypoint.sh ./
# This should be set in the project but just in case we ensure entrypoint.sh is executable
RUN chmod +x entrypoint.sh

# Copy main test plan from the project. We do this separately and as the very last last step as it's the most likely to
# change. Doing it this way means we can take better advantage of docker's build cache to speed up build times
COPY tests.jmx ./

# Tell docker to use our entrypoint script. The script will _always_ be run
ENTRYPOINT [ "/opt/entrypoint.sh" ]

# Provide a default command. If this is not overidden in the `docker run` call it will work in conjunction with our
# entrypoint script to run JMeter and the main test plan.
#
# Explanation
# -n                          run in non-gui mode (obviously!)
# -t tests.jmx                test plan to run
# -f                          force overwrite of the results file (will error if not empty)
# -l output/tests.jtl         file to write test results to
# -j output/jmeter.log        file to write the JMeter log to
# --jmeterlogconf log4j2.xml  use our custom log4j2.xml file as this enables streaming the log to the console
# -e                          generate the html report of results
# -o output/report            where to generate the report. Will error if not empty but we handle this in entrypoint.sh
CMD ["-n", "-t", "tests.jmx", "-f", "-l", "output/tests.jtl", "-j", "output/jmeter.log", "--jmeterlogconf", "log4j2.xml", "-e", "-o", "output/report"]
