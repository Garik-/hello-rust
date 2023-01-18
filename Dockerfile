ARG RUST_VERSION=1.66
ARG ALPINE_VERSION=3.17

FROM rust:$RUST_VERSION as builder

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

ARG ZIG_VERSION=0.10.0

# Install Zig
RUN curl -L "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-$(uname -m)-${ZIG_VERSION}.tar.xz" | tar -J -x -C /usr/local && \
    ln -s "/usr/local/zig-linux-$(uname -m)-${ZIG_VERSION}/zig" /usr/local/bin/zig

RUN cargo install cargo-zigbuild
RUN rustup target add x86_64-unknown-linux-musl    

WORKDIR /usr/src

RUN USER=root cargo new hello-rust

# We want dependencies cached, so copy those first.
COPY Cargo.toml Cargo.lock /usr/src/hello-rust/

WORKDIR /usr/src/hello-rust

# This is a dummy build to get the dependencies cached.
RUN cargo zigbuild --target x86_64-unknown-linux-musl --release

# Now copy in the rest of the sources
COPY src /usr/src/hello-rust/src/

## Touch main.rs to prevent cached release build
RUN touch /usr/src/hello-rust/src/main.rs

# This is the actual application build.
RUN cargo zigbuild --target x86_64-unknown-linux-musl --release

#############

FROM alpine:$ALPINE_VERSION AS runtime 

# Copy application binary from builder image
COPY --from=builder /usr/src/hello-rust/target/x86_64-unknown-linux-musl/release/hello-rust /usr/local/bin

EXPOSE 3000

# Run the application
CMD ["/usr/local/bin/hello-rust"]


