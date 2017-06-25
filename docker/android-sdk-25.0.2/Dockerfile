# Repo details: https://github.com/pedroamador/ci-scripts
#
# Build ci-scripts:25.0.2 docker image with "bin/buildDockerImage.sh --sdkVersion=25.0.2" from the root path
# 
FROM     ubuntu:16.04
MAINTAINER pedroamador [dot] rodriguez [at] gmail [dot] com

# Install basics
RUN apt-get update &&  \
    apt-get install -y apt-utils && \
    apt-get install -y git wget curl unzip make g++ ruby ruby-dev locales

# Locale settings
RUN locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Env settings
ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux

#FASTLANE
RUN gem install fastlane -NV

#ANDROID
#JAVA

# install python-software-properties (so you can do add-apt-repository)
RUN apt-get install -y -q python-software-properties software-properties-common  && \
    add-apt-repository ppa:webupd8team/java -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update && apt-get -y install oracle-java8-installer

# ANDROID STUFF
RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --force-yes expect ant wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android SDK
RUN cd /opt && \
    wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
    tar xzf android-sdk.tgz && \
    rm -f android-sdk.tgz && \
    chown -R root. /opt

# Setup environment

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/tools

# Install sdk elements
COPY tools /opt/tools

RUN ["/opt/tools/android-accept-licenses.sh", "android update sdk --all --no-ui --filter platform-tools,tools,extra-android-support,extra-android-m2repository,extra-google-m2repository"]
RUN unzip ${ANDROID_HOME}/temp/*.zip -d ${ANDROID_HOME}
RUN ["/opt/tools/android-accept-licenses.sh", "android update sdk --all --no-ui --filter build-tools-25.0.2,android-25"]

# Add applivery plugin
RUN fastlane add_plugin applivery &> /dev/null

# Copy debug keystore
COPY .android/ /root/.android/

# Exec
WORKDIR myApp
