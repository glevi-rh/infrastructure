# Use official etcd image to get pre-built etcdctl
FROM quay.io/coreos/etcd:v3.5.18 AS etcd-source

# Use official jq image (static binary, no dependencies needed)
FROM ghcr.io/jqlang/jq:1.7.1 AS jq-source

# Final image
FROM registry.redhat.io/ubi9:9.7-1762180182

# Copy etcdctl from the official etcd image
COPY --from=etcd-source /usr/local/bin/etcdctl /usr/bin/etcdctl

# Copy jq from the official jq image (static binary)
COPY --from=jq-source /jq /usr/bin/jq

ADD defrag.sh /opt/

CMD [ "/bin/sh" ]
