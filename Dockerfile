#Use ci-stage image 
FROM creditcoin/ci-linux:production AS builder
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /creditcoin-node
COPY Cargo.toml .
COPY Cargo.lock .
ADD node /creditcoin-node/node
ADD pallets /creditcoin-node/pallets
ADD primitives /creditcoin-node/primitives
ADD runtime /creditcoin-node/runtime
ADD sha3pow /creditcoin-node/sha3pow
RUN source ~/.cargo/env && cargo build --release

FROM ubuntu:20.04
EXPOSE 30333/tcp
EXPOSE 30333/udp
EXPOSE 9944 9933 9615
COPY --from=builder /creditcoin-node/target/release/creditcoin-node /bin/creditcoin-node
COPY chainspecs .
COPY entrypoint.sh .
COPY iconv.sh .
RUN chmod +x /entrypoint.sh
RUN chmod +x /iconv.sh
ENTRYPOINT [ "/bin/bash", "-c", "./entrypoint.sh |& ./iconv.sh" ]