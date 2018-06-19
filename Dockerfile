FROM ubuntu

RUN apt-get update && apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:bitcoin/bitcoin && apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-all-dev pkg-config libdb4.8-dev libdb4.8++-dev git

RUN git clone https://github.com/bitcoin/bitcoin /root/bitcoin
WORKDIR /root/bitcoin

RUN ./autogen.sh
RUN ./configure
RUN make

ENTRYPOINT ["/root/bitcoin/src/bitcoind"]
