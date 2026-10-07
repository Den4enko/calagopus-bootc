ARG BASE_IMAGE=quay.io/fedora/fedora-bootc:44
FROM $BASE_IMAGE
ARG BASE_IMAGE
ARG CALAGOPUS_VERSION=1.2.4

# Copy rootfs and build script
COPY rootfs/ /
COPY build.sh /tmp/build.sh

# Run single-layer setup script
RUN bash /tmp/build.sh "$BASE_IMAGE" "$CALAGOPUS_VERSION" && rm -f /tmp/build.sh

