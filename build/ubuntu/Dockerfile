ARG from
FROM ${from}

COPY ubuntu/packages.sh /tmp/packages.sh

RUN apt-get -q -y update && \
    apt-get -q -y install --no-install-recommends \
      bc \
      bison \
      bsdmainutils \
      bzip2 \
      ccache \
      file \
      flex \
      gcc \
      git \
      libc-dev \
      libelf-dev \
      liblz4-tool \
      libssl-dev \
      lzop \
      make \
      u-boot-tools \
      rsync \
      xz-utils \
      $(/tmp/packages.sh) && \
    rm -rf /var/lib/apt/lists/* /tmp/packages.sh /var/cache/* /var/log/dpkg.log

ARG uid
ARG gid

RUN groupadd --gid $gid linuxppc
RUN useradd --uid $uid --gid $gid linuxppc
USER linuxppc

COPY scripts/container-build.sh /bin/container-build.sh

ENV PATH=$PATH:/ppc64/bin:/ppc64le/bin
