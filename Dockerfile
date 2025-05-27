# Use Ubuntu Noble (24.04) as the base image
FROM ubuntu:noble

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Define PRoot version
ENV PROOT_VERSION=5.4.0

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        ca-certificates \
        iproute2 \
        xz-utils \
        bzip2 \
        sudo \
        locales \
        adduser && \
    rm -rf /var/lib/apt/lists/*

# Configure system locale
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Download and install PRoot
RUN ARCH=$(dpkg --print-architecture) && \
    mkdir -p /usr/local/bin && \
    curl -Lso /usr/local/bin/proot \
      "https://github.com/ysdragon/proot-static/releases/download/v${PROOT_VERSION}/proot-${ARCH}-static" && \
    chmod +x /usr/local/bin/proot

# Create a non-root user
RUN useradd -m -d /home/container -s /bin/bash container

# Set user context
USER container
ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

# Copy scripts into the container and ensure ownership & permissions
COPY --chown=container:container ./entrypoint.sh ./install.sh ./helper.sh ./run.sh ./
RUN chmod +x entrypoint.sh install.sh helper.sh run.sh

# Default command
CMD ["/bin/bash", "/home/container/entrypoint.sh"]
