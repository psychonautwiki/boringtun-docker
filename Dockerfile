FROM rust:1.42.0 as build

ARG BORINGTUN_VERSION=96bc927b2c3c354f2bbba15632f7e495a88f302b

RUN export target=`uname -m`-unknown-linux-musl \
 && rustup target install $target \
 && apt update && apt install -y musl-tools \
 && cargo install boringtun --git='https://github.com/cloudflare/boringtun.git' --rev=${BORINGTUN_VERSION} --target=$target \
 && rm -rf /usr/local/cargo/registry 

FROM scratch
COPY --from=build /usr/local/cargo/bin/boringtun .
VOLUME ["/var/run/wireguard/"]
ENTRYPOINT ["./boringtun", "--log=/dev/stdout", "--err=/dev/stderr", "--foreground"]
