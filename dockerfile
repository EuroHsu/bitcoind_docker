FROM alpine:3.8 as db
ENV BITCOIN_ROOT=/bitcoin
ENV BDB_PREFIX="${BITCOIN_ROOT}/db4"
RUN mkdir -p $BDB_PREFIX

RUN apk update && \
    apk upgrade && \
    apk add --no-cache boost libtool libzmq boost-dev libressl-dev libevent-dev zeromq-dev

RUN apk add --no-cache git autoconf automake g++ make file

RUN  wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz' && \
    echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c

RUN tar -xzf db-4.8.30.NC.tar.gz
RUN cd db-4.8.30.NC/build_unix/ && \
    ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX && \
    make -j4 && \
    make install && \
    rm -rf $BITCOIN_ROOT/db-4.8.30.NC* && \
    apk del git autoconf automake g++ make file

FROM alpine:3.9 as builder

ENV BITCOIN_VERSION=v22.0
ENV BITCOIN_ROOT=/bitcoin
ENV BDB_PREFIX="${BITCOIN_ROOT}/db4" BITCOIN_REPO="${BITCOIN_ROOT}/repo"

RUN mkdir -p $BITCOIN_ROOT

COPY --from=db $BITCOIN_ROOT/db4 $BITCOIN_ROOT/db4

WORKDIR $BITCOIN_ROOT

RUN apk update && \
    apk upgrade && \
    apk add --no-cache boost libtool libzmq boost-dev libressl-dev libevent-dev zeromq-dev

RUN apk add --no-cache git autoconf automake g++ make file

RUN git clone -b $BITCOIN_VERSION https://github.com/bitcoin/bitcoin.git $BITCOIN_REPO

RUN cd $BITCOIN_REPO && \
    ./autogen.sh && \
    ./configure \
        LDFLAGS="-L${BDB_PREFIX}/lib/" \
        CPPFLAGS="-I${BDB_PREFIX}/include/" \
        CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768" \
        --disable-tests \
        --disable-bench \
        --disable-ccache \
        --with-gui=no \
        --with-utils \
        --with-libs \
        --with-daemon \
        --prefix=$BITCOIN_ROOT && \
    make -j4 && \
    make install && \
    rm -rf $BDB_PREFIX/docs && \
    rm -rf $BITCOIN_REPO && \
    strip $BITCOIN_ROOT/bin/bitcoin-cli && \
    strip $BITCOIN_ROOT/bin/bitcoin-tx && \
    strip $BITCOIN_ROOT/bin/bitcoin-wallet && \
    strip $BITCOIN_ROOT/bin/bitcoind && \
    strip $BITCOIN_ROOT/lib/libbitcoinconsensus.a && \
    strip $BITCOIN_ROOT/lib/libbitcoinconsensus.so.0.0.0 && \
    apk del git autoconf automake g++ make file

FROM alpine:3.9

ENV BITCOIN_ROOT=/bitcoin
ENV PATH="${BITCOIN_ROOT}/bin:$PATH"

RUN apk update && \
    apk upgrade && \
    apk add --no-cache libressl boost libevent libtool libzmq && \
    mkdir chaindata config

COPY --from=builder $BITCOIN_ROOT/bin $BITCOIN_ROOT/bin
