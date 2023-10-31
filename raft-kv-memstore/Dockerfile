FROM rust:1.73

RUN apt-get update
RUN apt-get install -y pcp-zeroconf

WORKDIR /usr/src/raft
COPY . .
RUN cargo install --path .

CMD ["./container-scripts/create-node.sh"]