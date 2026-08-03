ARG BASE_IMAGE=quay.io/fedora/fedora-bootc:44
FROM $BASE_IMAGE
ARG BASE_IMAGE

# Copy rootfs and build script
COPY rootfs/ /
COPY build.sh /tmp/build.sh

# Run single-layer setup script
RUN bash /tmp/build.sh "$BASE_IMAGE" && rm -f /tmp/build.sh

