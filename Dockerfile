FROM ubuntu:15.10
MAINTAINER Keloran <keloran@nordicarts.net>
LABEL Description="Docker for Vapor + Cappuchino"

# ENV Settings
ENV SWIFT_BRANCH development
ENV SWIFT_VERSION DEVELOPMENT-SNAPSHOT-2016-03-01-a
ENV SWIFT_PLATFORM_VERSION=ubuntu15.10
ENV SWIFT_PLATFORM ubuntu1510
ENV HOME /root
ENV WORK_DIR /root/code
ENV MONGODB_VER 1.3.3

# Work Directory
WORKDIR ${WORK_DIR}

# APT-GET
RUN apt-get update && \
  apt-get install -y build-essential \
    autoconf \
    libtool \
    libkqueue-dev \
    libkqueue0 \
    libdispatch-dev \
    libdispatch0 \
    libhttp-parser-dev \
    libcurl4-openssl-dev \
    libhiredis-dev \
    wget \
    clang \
    libedit-dev \
    python2.7 \
    python2.7-dev \
    libicu55 \
    libicu-dev \
    rsync \
    libxml2 \
    libglib2.0-dev \
    automake \
    git \
    curl \
    telnet \
    vim \
    libblocksruntime-dev \
    openssh-server \
    net-tools \
    supervisor \
    bash-completion \
    screen \
    htop \
    multitail \
    zsh \
    tree \
    pwgen
RUN apt-get autoremove -y
RUN apt-get clean
RUN apt-get autoclean


# ZSH
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
  && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
  && chsh -s /bin/zsh

# Clean APT
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Swift Key
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import && \
  gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Swift
RUN SWIFT_ARCHIVE_NAME=swift-$SWIFT_VERSION-$SWIFT_PLATFORM_VERSION && \
  SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/swift-$SWIFT_VERSION/$SWIFT_ARCHIVE_NAME.tar.gz && \
  wget $SWIFT_URL && \
  wget $SWIFT_URL.sig && \
  gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig && \
  tar -zxvf $SWIFT_ARCHIVE_NAME.tar.gz --directory / --strip-components=1 && \
  rm -rf $SWIFT_ARCHIVE_NAME* /tmp/* /var/tmp/*

# Mongo
RUN wget https://github.com/mongodb/mongo-c-driver/releases/download/${MONGODB_VER}/mongo-c-driver-$MONGODB_VER.tar.gz && \
  tar -zxvf mongo-c-driver-$MONGODB_VER.tar.gz && \
  cd mongo-c-driver-$MONGODB_VER && \
  ./configure && \
  make && \
  make install

# PCRE
RUN wget http://ftp.exim.org/pub/pcre/pcre2-10.20.tar.gz && \
  tar -zxvf pcre2-10.20.tar.gz && \
  cd pcre2-10.20 && \
  ./configure && \
  make && \
  make install

  # LibDispatch
RUN git clone https://github.com/apple/swift-corelibs-libdispatch.git
RUN cd swift-corelibs-libdispatch && \
  git submodule init && \
  git submodule update && \
  sh ./autogen.sh && \
  ./configure --with-swift-toolchain=/usr --prefix=/usr && \
  make && \
  make install

# Set lib path
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/include:/usr/local/include/libbson-1.0:$LD_LIBRARY_PATH

# Set Path
ENV PATH /usr/bin/:$WORK_DIR/:$PATH

# See if swift works
CMD ["/usr/bin/swift", "--version"]

# Add mount
VOLUME ${WORK_DIR}

# Expose port
EXPOSE 22
EXPOSE 80

# Source
RUN mkdir /root/code/experiment
COPY Code/* /root/code/experiment/

# SuperVisor
ADD Scripts/supervisord.conf /etc/supervisord.conf

# Scripts
ADD Scripts/start.sh /start.sh
CMD ["/bin/chmod", "755", "/start.sh"]
CMD ["/bin/bash", "/start.sh"]
