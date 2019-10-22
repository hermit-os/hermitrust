# Download base image ubuntu 18.04
FROM ubuntu:latest AS build
COPY . /src

# Update Software repository
RUN apt-get clean 
RUN apt-get -qq update

# Install required packets from ubuntu repository
RUN apt-get install -y apt-transport-https curl wget vim git binutils autoconf automake make cmake qemu-kvm qemu-system-x86 nasm gcc g++ build-essential libtool bsdmainutils libssl-dev python pkg-config lld swig python-dev libncurses5-dev

# download latest version
RUN git clone --depth 1 -b rusty-hermit https://github.com/hermitcore/rust.git

# Install Rust toolchain
RUN cp /src/config.toml rust
RUN cd rust && ./x.py install

ENV PATH="/root/.cargo/bin:${PATH}"
ENV XARGO_RUST_SRC="/root/.cargo/lib/rustlib/src/rust/src/"
ENV EDITOR=vim
RUN PATH="/root/.cargo/bin:${PATH}" /root/.cargo/bin/cargo install cargo-xbuild

# build libos
ENV LATEST="$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')"
RUN echo ${LATEST}
RUN cd /root && curl -sOL "https://github.com/hermitcore/libhermit-rs/archive/${LATEST}.tar.gz"
RUN cd /root && tar -xzvf *.tar.gz
RUN cd /root/${LATEST} &&  make && cp target/x86_64-unknown-hermit-kernel/debug/libhermit.a /root/.cargo/lib/rustlib/x86_64-unknown-hermit/lib

# final stage
FROM ubuntu:latest

# Update Software repository
RUN apt-get clean 
RUN apt-get -qq update

# Install required packets from ubuntu repository
RUN apt-get install -y apt-transport-https curl wget vim git binutils autoconf automake make cmake qemu-kvm qemu-system-x86 nasm gcc g++ build-essential libtool bsdmainutils lld

# add path to hermitcore packets
RUN echo "deb [trusted=yes] https://dl.bintray.com/hermitcore/ubuntu bionic main" | tee -a /etc/apt/sources.list

# Update Software repository
RUN apt-get -qq update

# Install required packets from ubuntu repository
#RUN apt-get install -y --allow-unauthenticated binutils-hermit gcc-hermit-rs #newlib-hermit-rs pte-hermit-rs gcc-hermit-rs libhermit-rs

COPY --from=build /root/.cargo .

ENV PATH="/opt/hermit/bin:/root/.cargo/bin:${PATH}"
ENV XARGO_RUST_SRC="/root/.cargo/lib/rustlib/src/rust/src/"
ENV EDITOR=vim

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
