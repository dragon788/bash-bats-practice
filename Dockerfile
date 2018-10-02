ARG bash_ver=latest
FROM bash:${bash_ver}
# Build using `docker build -t bats/bats:latest .`
ARG bats_core_ver=1.1.0
ARG bats_support_ver=0.3.0
ARG bats_assert_ver=0.3.0
ARG bats_file_ver=0.2.0
ARG bats_mock_ver=1.0-beta.1
ARG temppath=/tmp
ARG libpath=/usr/local/lib/bats

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

#ENV BASH_FUNC_GET_LIBS%% () { LIBPATH=\$2; LIBNAME=\$1; echo \$1 \$2 ;}
#RUN env && bash -c "GET_LIBS $BATS_VERSION /usr/local/lib/bats/"

ENV TEMPPATH "${temppath}"
ENV LIBPATH "${libpath}"

ENV BASH_FUNC_get_release_tarball%% () {\
    # \
    REPO="\$1"; REL_VERSION="\$2"; OUTNAME="\${3:-\${1##*/}}";\
    curl -sSL https://github.com/\$REPO/archive/v\$REL_VERSION.tar.gz -o $TEMPPATH/\$OUTNAME.tgz;\
    }

ENV BASH_FUNC_get_libs%% () { LIBREPO="\$1"; LIBVERSION="\$2"; LIBNAME="\${3:-\${1##*/}}"; OUTPATH="\${4:-\$LIBPATH}"; echo "\$LIBREPO \$LIBVERSION \$LIBNAME \$OUTPATH"\
    && mkdir -p \$OUTPATH/\$LIBNAME \
    && get_release_tarball \$LIBREPO \$LIBVERSION \$LIBNAME \
    && tar -zxf $TEMPPATH/\$LIBNAME.tgz -C \$OUTPATH/\$LIBNAME --strip 1; }

ENV BATS_VERSION ${bats_core_ver}
RUN bash -c "get_libs bats-core/bats-core $BATS_VERSION bats-core /tmp" \
    && bash $TEMPPATH/bats-core/install.sh /usr/local

ENV LIBS_BATS_SUPPORT_VERSION ${bats_support_ver}
RUN bash -c "get_libs ztombol/bats-support $LIBS_BATS_SUPPORT_VERSION"
ENV LIBS_BATS_ASSERT_VERSION ${bats_assert_ver}
RUN bash -c "get_libs ztombol/bats-assert $LIBS_BATS_ASSERT_VERSION"
ENV LIBS_BATS_FILE_VERSION ${bats_file_ver}
RUN bash -c "get_libs ztombol/bats-file $LIBS_BATS_FILE_VERSION"
ENV LIBS_BATS_MOCK_VERSION ${bats_mock_ver}
RUN bash -c "get_libs grayhemp/bats-mock $LIBS_BATS_MOCK_VERSION"

# RUN mkdir -p /usr/local/lib/bats/bats-support \
#     && curl -sSL https://github.com/ztombol/bats-support/archive/v$LIBS_BATS_SUPPORT_VERSION.tar.gz -o /tmp/bats-support.tgz \
#     && tar -zxf /tmp/bats-support.tgz -C /usr/local/lib/bats/bats-support --strip 1
# 
# ENV LIBS_BATS_ASSERT_VERSION ${bats_assert_ver}
# RUN mkdir -p /usr/local/lib/bats/bats-assert \
#     && curl -sSL https://github.com/ztombol/bats-assert/archive/v$LIBS_BATS_ASSERT_VERSION.tar.gz -o /tmp/bats-assert.tgz \
#     && tar -zxf /tmp/bats-assert.tgz -C /usr/local/lib/bats/bats-assert --strip 1
# 
# ENV LIBS_BATS_FILE_VERSION ${bats_file_ver}
# RUN mkdir -p /usr/local/lib/bats/bats-file \
#     && curl -sSL https://github.com/ztombol/bats-file/archive/v$LIBS_BATS_FILE_VERSION.tar.gz -o /tmp/bats-file.tgz \
#     && tar -zxf /tmp/bats-file.tgz -C /usr/local/lib/bats/bats-file --strip 1
# 
# ENV LIBS_BATS_MOCK_VERSION ${bats_mock_ver}
# RUN mkdir -p /usr/local/lib/bats/bats-mock \
#     && curl -sSL https://github.com/grayhemp/bats-mock/archive/v$LIBS_BATS_MOCK_VERSION.tar.gz -o /tmp/bats-mock.tgz \
#     && tar -zxf /tmp/bats-mock.tgz -C /usr/local/lib/bats/bats-mock --strip 1
# 
# This is a binary only install of Docker for managing a "remote" daemon via mounted /var/run/docker.sock or a tcp accessible Docker host
RUN curl -s -L https://get.docker.io/builds/Linux/x86_64/docker-latest -o /bin/docker && \
    chmod a+x /bin/docker
# Since we make it executable by any user we don't need to create a user and add it to the Docker group, this avoids issue of docker run --uid being a different user in the container

RUN rm -rf /tmp/*

# COPY resources/load.bash /usr/local/lib/bats/

VOLUME /opt/bats/
ENTRYPOINT ["/usr/local/bin/bats"]
CMD ["--help"]
