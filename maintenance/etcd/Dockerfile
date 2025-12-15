# Use official etcd image to get pre-built etcdctl
FROM quay.io/coreos/etcd:v3.5.18 AS etcd-source

# Final image
FROM registry.redhat.io/ubi9:9.7-1762180182

# Copy etcdctl from the official etcd image
COPY --from=etcd-source /usr/local/bin/etcdctl /usr/bin/etcdctl

ADD defrag.sh /opt/

RUN dnf -y install jq && dnf clean all

CMD [ "/bin/sh" ]
