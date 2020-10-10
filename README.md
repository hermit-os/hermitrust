# hermitrust
[![Build Status](https://git.rwth-aachen.de/acs/public/hermitcore/hermitrust/badges/master/pipeline.svg)](https://git.rwth-aachen.de/acs/public/hermitcore/hermitrust/pipelines)

These scripts build a plain docker environment for  [RustyHermit](https://github.com/hermitcore/libhermit-rs).
The toolchain is built every night with the latest nightly version of Rust.

## Usage

The Docker container for *RustyHermit* provides an simple way to get the toolchain for RustyHermit.
Please pull the container and use *cargo* to cross compile the application.
As an example, the following commands create the test application *Hello World* for RustyHermit.

```sh
docker pull registry.git.rwth-aachen.de/acs/public/hermitcore/hermitrust:latest
docker run -v $PWD:/volume -e USER=$USER -w /volume --rm -t registry.git.rwth-aachen.de/acs/public/hermitcore/hermitrust cargo new hello_world --bin
cd hello_world
docker run -v $PWD:/volume -e USER=$USER -w /volume --rm -t registry.git.rwth-aachen.de/acs/public/hermitcore/hermitrust cargo build --target x86_64-unknown-hermit
```
