FROM postgres:16-bookworm

RUN apt-get update && apt-get install -y \
    build-essential libreadline-dev zlib1g-dev flex bison git libicu-dev pkg-config

RUN git clone --branch v2.16.0 https://github.com/skaiworldwide-oss/agensgraph.git \
    && cd agensgraph \
    && ./configure \
    && make -j$(nproc) \
    && make install
