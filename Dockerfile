FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install qbittorrent-nox and dependencies
RUN apt-get update && \
    apt-get install -y \
    qbittorrent-nox \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create qBittorrent config directory
RUN mkdir -p /config /downloads

# Set environment variables
ENV QBT_WEBUI_PORT=8080
ENV QBT_PROFILE=/config

# Create configuration file to allow external access
RUN mkdir -p /config/qBittorrent && \
    echo '[Preferences]\n\
WebUI\\Address=*\n\
WebUI\\Port=8080\n\
WebUI\\LocalHostAuth=false\n\
WebUI\\AuthSubnetWhitelistEnabled=false\n\
WebUI\\CSRFProtection=false' > /config/qBittorrent/qBittorrent.conf

# Create a simple entrypoint script
RUN echo '#!/bin/bash\n\
echo "Starting qBittorrent-nox..."\n\
echo "WebUI will be available at: http://0.0.0.0:8080"\n\
echo "Default credentials - Username: admin, Password: adminadmin"\n\
echo "Please change the password after first login!"\n\
exec qbittorrent-nox \
    --profile=/config \
    --webui-port=8080' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Expose the WebUI port
EXPOSE 8080

# Expose torrenting port (TCP/UDP)
EXPOSE 6881

# Set working directory
WORKDIR /downloads

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

# Run qBittorrent-nox
ENTRYPOINT ["/entrypoint.sh"]
