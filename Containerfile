# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image - Bazzite Deck (Steam Deck UI for car entertainment)
FROM ghcr.io/ublue-os/bazzite-deck:stable

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    cp /ctx/files/install-apps.sh /usr/bin/car-edge-install-apps && \
    chmod +x /usr/bin/car-edge-install-apps && \
    cp /ctx/files/backup-configs.sh /usr/bin/car-edge-backup && \
    chmod +x /usr/bin/car-edge-backup && \
    cp /ctx/files/car-edge-setup-wizard.sh /usr/bin/car-edge-setup-wizard && \
    chmod +x /usr/bin/car-edge-setup-wizard && \
    cp /ctx/files/car-edge-upgrade.sh /usr/bin/car-edge-upgrade && \
    chmod +x /usr/bin/car-edge-upgrade && \
    cp /ctx/files/car-edge-setup-wizard.service /tmp/ && \
    bash /ctx/files/enable-setup-wizard.sh && \
    cp /ctx/files/car-edge-setup-wizard.sh /usr/bin/car-edge-setup-wizard && \
    chmod +x /usr/bin/car-edge-setup-wizard
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
