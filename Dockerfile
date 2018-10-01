ARG bash_ver=latest
FROM bash:${bash_ver}
# Build using `docker build -t bats/bats:latest .`
ARG bats_core_ver=1.1.0
ARG bats_support_ver=0.3.0
ARG bats_assert_ver=0.3.0
ARG bats_file_ver=0.2.0
ARG bats_mock_ver=1.0-beta.1
ARG bats_stub_ver=1.0-beta.1

MAINTAINER dragon788 <dragon788@users.noreply.github.com>

# Need GNU `readlink` from `coreutils` to have sane `-e` option 
# Need ncurses for pretty checkmarks, but it causes failures in the tests
# To shrink image could use wget instead of curl and busybox tar instead of external
RUN apk --no-cache add \
        coreutils \
        ncurses \
        curl \
        zip \
        unzip \
        tar \
        gzip

ENV BATS_VERSION ${bats_core_ver}
RUN curl -sSL https://github.com/bats-core/bats-core/archive/v$BATS_VERSION.tar.gz -o /tmp/bats.tgz \
    && tar -zxf /tmp/bats.tgz -C /tmp \
    && /bin/bash /tmp/bats-core-$BATS_VERSION/install.sh /usr/local

ENV LIBS_BATS_SUPPORT_VERSION ${bats_support_ver}
RUN mkdir -p /usr/local/lib/bats/bats-support \
    && curl -sSL https://github.com/ztombol/bats-support/archive/v$LIBS_BATS_SUPPORT_VERSION.tar.gz -o /tmp/bats-support.tgz \
    && tar -zxf /tmp/bats-support.tgz -C /usr/local/lib/bats/bats-support --strip 1

ENV LIBS_BATS_ASSERT_VERSION ${bats_assert_ver}
RUN mkdir -p /usr/local/lib/bats/bats-assert \
    && curl -sSL https://github.com/ztombol/bats-assert/archive/v$LIBS_BATS_ASSERT_VERSION.tar.gz -o /tmp/bats-assert.tgz \
    && tar -zxf /tmp/bats-assert.tgz -C /usr/local/lib/bats/bats-assert --strip 1

ENV LIBS_BATS_FILE_VERSION ${bats_file_ver}
RUN mkdir -p /usr/local/lib/bats/bats-file \
    && curl -sSL https://github.com/ztombol/bats-file/archive/v$LIBS_BATS_FILE_VERSION.tar.gz -o /tmp/bats-file.tgz \
    && tar -zxf /tmp/bats-file.tgz -C /usr/local/lib/bats/bats-file --strip 1

ENV LIBS_BATS_MOCK_VERSION ${bats_mock_ver}
RUN mkdir -p /usr/local/lib/bats/bats-mock \
    && curl -sSL https://github.com/grayhemp/bats-mock/archive/v$LIBS_BATS_MOCK_VERSION.tar.gz -o /tmp/bats-mock.tgz \
    && tar -zxf /tmp/bats-mock.tgz -C /usr/local/lib/bats/bats-mock --strip 1

# This is a binary only install of Docker for managing a "remote" daemon via mounted /var/run/docker.sock or a tcp accessible Docker host
RUN curl -s -L https://get.docker.io/builds/Linux/x86_64/docker-latest -o /bin/docker && \
    chmod a+x /bin/docker
# Since we make it executable by any user we don't need to create a user and add it to the Docker group, this avoids issue of docker run --uid being a different user in the container

RUN rm -rf /tmp/*

COPY resources/load.bash /usr/local/lib/bats/

VOLUME /opt/bats/
ENTRYPOINT ["/usr/local/bin/bats"]
CMD ["--help"]
