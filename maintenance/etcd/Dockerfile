# Use official etcd image to get pre-built etcdctl
FROM quay.io/coreos/etcd:v3.5.18 AS etcd-source

# Get jq from UBI image with jq installed
FROM registry.redhat.io/ubi9:9.7-1762180182 AS jq-source
RUN dnf -y install jq && dnf clean all

# Final image
FROM registry.redhat.io/ubi9:9.7-1762180182

# Copy etcdctl from the official etcd image
COPY --from=etcd-source /usr/local/bin/etcdctl /usr/bin/etcdctl

# Copy jq and its dependencies from the jq-source stage
COPY --from=jq-source /usr/bin/jq /usr/bin/jq
COPY --from=jq-source /usr/lib64/libjq.so.1 /usr/lib64/libjq.so.1
COPY --from=jq-source /usr/lib64/libonig.so.5 /usr/lib64/libonig.so.5

ADD defrag.sh /opt/

CMD [ "/bin/sh" ]
