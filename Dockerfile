# Download base image ubuntu 18.04
FROM ubuntu:latest AS build
COPY . /src

# Install required packets from ubuntu repository
RUN apt-get install -y apt-transport-https curl wget vim git binutils autoconf automake make cmake qemu-kvm qemu-system-x86 nasm gcc g++ build-essential libtool bsdmainutils libssl-dev python pkg-config lld swig python-dev libncurses5-dev

# download latest version
RUN git clone --depth 1 -b rusty-hermit https://github.com/hermitcore/rust.git

ENV PATH="/opt/hermit/bin:/root/.cargo/bin:${PATH}"
ENV XARGO_RUST_SRC="/root/.cargo/lib/rustlib/src/rust/src/"
ENV EDITOR=vim

# Install Rust toolchain
RUN cp /src/config.toml /src/rust
RUN cd /src/rust && ./x.py install
RUN PATH="/root/.cargo/bin:${PATH}" /root/.cargo/bin/cargo install cargo-xbuild

# final stage
FROM ubuntu:latest
# Install required packets from ubuntu repository
RUN apt-get install -y apt-transport-https curl wget vim git binutils autoconf automake make cmake qemu-kvm qemu-system-x86 nasm gcc g++ build-essential libtool bsdmainutils libssl-dev python pkg-config lld swig python-dev libncurses5-dev

COPY --from=build /root/.cargo .

ENV PATH="/opt/hermit/bin:/root/.cargo/bin:${PATH}"
ENV XARGO_RUST_SRC="/root/.cargo/lib/rustlib/src/rust/src/"
ENV EDITOR=vim

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
