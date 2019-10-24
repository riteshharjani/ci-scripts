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

ENV base_url=https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/4.6.3/
ENV tar_file=x86_64-gcc-4.6.3-nolibc_powerpc64-linux.tar.xz
ENV sum_file=sha256sums.asc

RUN curl -sSL $base_url/$tar_file > $tar_file && \
    curl -sSL $base_url/$sum_file > $sum_file && \
    grep $tar_file $sum_file | sha256sum -c && \
    tar -xf $tar_file -C /opt && \
    rm $tar_file $sum_file

RUN cd /opt/gcc-4.6.3-nolibc/powerpc64-linux/bin && \
    rename s/powerpc64-linux-/powerpc-linux-gnu-/ powerpc64-linux-*

RUN cd /usr/bin && \
    ln -s /opt/gcc-4.6.3-nolibc/powerpc64-linux/bin/* .

ARG uid
ARG gid

RUN groupadd --gid $gid linuxppc
RUN useradd --uid $uid --gid $gid linuxppc
USER linuxppc

COPY scripts/container-build.sh /bin/container-build.sh
