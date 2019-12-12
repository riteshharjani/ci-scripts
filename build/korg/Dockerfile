FROM ubuntu:16.04

ARG apt_mirror
ENV apt_mirror=${apt_mirror}
RUN [ -n "$apt_mirror" ] && sed -i -e "s|ports.ubuntu.com|$apt_mirror|" /etc/apt/sources.list || true

RUN apt-get -q -y update && \
    apt-get -q -y install --no-install-recommends \
      bc \
      bison \
      bsdmainutils \
      bzip2 \
      ca-certificates \
      ccache \
      cpio \
      curl \
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
      openssl \
      u-boot-tools \
      rename \
      rsync \
      xz-utils \
      && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/dpkg.log

ARG compiler_version
ARG tar_file
ARG base_url

RUN echo $base_url
RUN echo $tar_file
RUN curl -sSL $base_url/$tar_file > $tar_file && \
    curl -sSL $base_url/sha256sums.asc > sha256sums.asc && \
    grep $tar_file sha256sums.asc | sha256sum -c && \
    tar -xf $tar_file -C /opt && \
    rm $tar_file sha256sums.asc

RUN cd /opt/gcc-${compiler_version}-nolibc/powerpc64-linux/bin && \
    rename s/powerpc64-linux-/powerpc-linux-gnu-/ powerpc64-linux-*

RUN cd /usr/bin && \
    ln -s /opt/gcc-${compiler_version}-nolibc/powerpc64-linux/bin/* .

ARG uid
ARG gid

RUN groupadd --gid $gid linuxppc
RUN useradd --uid $uid --gid $gid linuxppc
USER linuxppc

COPY scripts/container-build.sh /bin/container-build.sh
