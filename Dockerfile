# Download base image ubuntu 18.04
FROM ubuntu:latest AS build
COPY . /src
WORKDIR /root/

# Update and install required packets from ubuntu repository
RUN apt-get clean && apt-get -qq update && apt-get install -y apt-transport-https curl wget vim git binutils autoconf automake make cmake qemu-kvm qemu-system-x86 nasm gcc g++ build-essential libtool bsdmainutils libssl-dev python pkg-config lld swig python-dev libncurses5-dev

# download latest version
RUN git clone --depth 1 -b master https://github.com/rust-lang/rust.git

# Install Rust toolchain
RUN cp /src/config.toml rust
RUN cd rust && ./x.py install

ENV PATH="/root/.cargo/bin:${PATH}"
ENV XARGO_RUST_SRC="/root/.cargo/lib/rustlib/src/rust/src/"
ENV EDITOR=vim
RUN PATH="/root/.cargo/bin:${PATH}" /root/.cargo/bin/cargo install cargo-xbuild

# build libos
ARG LATEST
ENV RUSTY_LATEST=$LATEST
RUN curl -sOL "https://github.com/hermitcore/libhermit-rs/archive/${RUSTY_LATEST}.tar.gz" && mkdir libhermit && tar xzvf ${RUSTY_LATEST}.tar.gz --one-top-level=libhermit --strip-components 1 && cd libhermit &&  make lib && cp target/x86_64-unknown-hermit-kernel/debug/libhermit.a /root/.cargo/lib/rustlib/x86_64-unknown-hermit/lib

# final stage
FROM ubuntu:latest
WORKDIR /root/


# Update and install required packets from ubuntu repository
RUN apt-get clean && apt-get -qq update && apt-get install -y apt-transport-https curl wget vim git binutils autoconf automake make cmake qemu-kvm qemu-system-x86 nasm gcc g++ build-essential libtool bsdmainutils lld net-tools iputils-ping

# add path to hermitcore packets
RUN echo "deb [trusted=yes] https://dl.bintray.com/hermitcore/ubuntu bionic main" | tee -a /etc/apt/sources.list

# Update Software repository
#RUN apt-get -qq update

# Install required packets from ubuntu repository
#RUN apt-get install -y --allow-unauthenticated binutils-hermit gcc-hermit-rs #newlib-hermit-rs pte-hermit-rs gcc-hermit-rs libhermit-rs

RUN mkdir -p /root/.cargo
COPY --from=build /root/.cargo /root/.cargo
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-objcopy /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-objdump /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-readelf /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-size /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-ar /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-strip /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-readobj /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-nm /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/
COPY --from=build /root/rust/build/x86_64-unknown-linux-gnu/llvm/build/bin/llvm-profdata /root/.cargo/lib/rustlib/x86_64-unknown-linux-gnu/bin/

ENV PATH="/opt/hermit/bin:/root/.cargo/bin:${PATH}"
ENV XARGO_RUST_SRC="/root/.cargo/lib/rustlib/src/rust/src/"
ENV EDITOR=vim

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
