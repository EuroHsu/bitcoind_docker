FROM ubuntu:18.04
RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common wget && \
    wget https://bitcoin.org/bin/bitcoin-core-0.20.0/bitcoin-0.20.0-x86_64-linux-gnu.tar.gz && \
    tar zxf bitcoin-0.20.0-x86_64-linux-gnu.tar.gz && \
    ln -fs /bitcoin-0.20.0/bin/bitcoind /usr/local/bin/bitcoind && \
    ln -fs /bitcoin-0.20.0/bin/bitcoin-cli /usr/local/bin/bitcoin-cli && \
    mkdir chaindata