FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install qbittorrent-nox and dependencies
RUN apt-get update && \
    apt-get install -y \
    qbittorrent-nox \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create qBittorrent config directory
RUN mkdir -p /config/qBittorrent /downloads

# Set environment variables
ENV QBT_WEBUI_PORT=8080
ENV QBT_PROFILE=/config

# Create entrypoint script that sets up config before starting
RUN echo '#!/bin/bash\n\
\n\
CONFIG_FILE="/config/qBittorrent/qBittorrent.conf"\n\
mkdir -p /config/qBittorrent\n\
\n\
# Create configuration file\n\
cat > "$CONFIG_FILE" << EOF\n\
[Preferences]\n\
WebUI\\Address=*\n\
WebUI\\Port=8080\n\
WebUI\\LocalHostAuth=false\n\
WebUI\\AuthSubnetWhitelistEnabled=false\n\
WebUI\\CSRFProtection=false\n\
WebUI\\ClickjackingProtection=false\n\
WebUI\\HostHeaderValidation=false\n\
WebUI\\Username=admin\n\
WebUI\\Password_PBKDF2="@ByteArray(ARQ77eY1NUZaQsuDHbIMCA==:0WMRkYTUWVT9wVvdDtHAjU9b3b7uB8NR1Gur2hmQCvCDpm39Q+PsJRJPaCU51dEiz+dTzh8qbPsL8WkFljQYFQ==)"\n\
EOF\n\
\n\
echo "Starting qBittorrent-nox..."\n\
echo "WebUI will be available at: http://0.0.0.0:8080"\n\
echo "Default credentials - Username: admin, Password: adminadmin"\n\
echo "IMPORTANT: Change the password after first login!"\n\
echo ""\n\
echo "Config applied to allow access from any IP address"\n\
\n\
exec qbittorrent-nox --profile=/config --webui-port=8080\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

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
