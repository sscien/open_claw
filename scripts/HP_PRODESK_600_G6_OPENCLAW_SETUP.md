# HP ProDesk 600 G6 SFF — OpenCLAW Deployment Recommendation

## Your Hardware

| Component | Spec | Notes |
|-----------|------|-------|
| Model | HP ProDesk 600 G6 SFF | Business-class, designed for 24/7 operation |
| CPU | Intel Core i5-10500 | 6 cores / 12 threads, 3.1GHz base / 4.5GHz boost |
| RAM | 32GB DDR4-2933 | 2 DIMM slots, upgradeable to 64GB |
| Storage | 1TB NVMe Gen4 | More than enough for OpenCLAW + Docker images |
| OS | Windows 11 Pro (current) | Will be replaced per recommendation below |
| Network | Intel I219-LM GbE | Excellent Linux driver support |
| TPM | TPM 2.0 (dTPM) | Useful for disk encryption |
| PSU | 180W internal (80+ Gold) | ~25W idle, ~65W load — very efficient |
| VT-x/VT-d | Yes | Full virtualization support |

### CPU Capabilities (i5-10500, Comet Lake)
- VT-x + VT-d: Full hardware virtualization (KVM, Hyper-V, Proxmox)
- AES-NI: Hardware-accelerated encryption (important for TLS/HTTPS)
- Hyper-Threading: 12 threads from 6 cores — plenty for OpenCLAW + Docker
- TDP: 65W — the SFF chassis handles this easily with stock cooling

### RAM Upgrade Path
- 2x DIMM slots, DDR4-2933 (non-ECC)
- Current: 32GB (likely 2x16GB)
- Max: 64GB (2x32GB DDR4-2933 UDIMM)
- Recommendation: 32GB is more than enough for OpenCLAW. Save the upgrade money.

---

## The Verdict: Install Ubuntu Server 24.04 LTS

Format Windows 11 Pro and install Ubuntu Server 24.04 LTS bare metal.

### Why This Is the Right Call

OpenCLAW is a 24/7 WebSocket gateway. Its primary job is staying online, handling
persistent connections from WhatsApp/Telegram/Slack/Discord, and running browser
automation. This is a server workload. The OS choice should optimize for uptime,
low overhead, and networking simplicity.

| Factor | Ubuntu Server | Windows + WSL2 | Proxmox |
|--------|--------------|----------------|---------|
| Idle RAM overhead | ~700MB | ~6GB | ~1.8GB |
| RAM available for OpenCLAW | ~31.3GB | ~25GB | ~30GB |
| 24/7 reliability | 9.5/10 | 5/10 | 8.5/10 |
| Forced reboots | None (kernel livepatch) | Windows Update monthly | None |
| WebSocket networking | Direct bind, no NAT | WSL2 NAT + port forwarding | Bridged, works |
| Docker performance | Native kernel | VM-inside-VM | Near-native (LXC) |
| Setup complexity | 4/10 | 5/10 | 6/10 |
| Maintenance burden | 3/10 | 7/10 | 5/10 |

The Windows + WSL2 option loses 6GB of RAM to Windows overhead, has unreliable
WebSocket networking through WSL2's NAT layer, and Windows Update will force
reboots that kill all active channel connections. WSL2 was designed for
development, not production servers.

Proxmox is a solid alternative if you want snapshot/rollback capabilities, but
it adds a hypervisor layer you don't need for a single-purpose machine.

Ubuntu Server gives you 31.3GB of your 32GB for actual work, rock-solid uptime,
and dead-simple networking.

### What About Keeping Windows for Other Tasks?

If you occasionally need Windows on this machine, consider one of these instead:

1. **Proxmox VE** — Run Ubuntu Server VM for OpenCLAW + Windows VM on-demand
2. **Separate cheap PC for Windows** — Keep this box dedicated to OpenCLAW
3. **Remote Desktop to another Windows machine** — Use this box as a pure server

But if this PC's primary job is OpenCLAW, Ubuntu Server is the answer.

---

## Step-by-Step Setup Guide

### Phase 1: Prepare the USB Installer

On your current Windows machine (or any other PC):

1. Download Ubuntu Server 24.04.x LTS ISO:
   https://ubuntu.com/download/server

2. Download Rufus (Windows) or use `dd` (Mac/Linux) to create a bootable USB:
   - Rufus: https://rufus.ie
   - Select the ISO, target your USB drive, GPT partition scheme, click Start

### Phase 2: BIOS Configuration

Before installing, configure the HP BIOS for server use:

1. Power on the ProDesk, press **F10** repeatedly to enter BIOS Setup
2. Navigate to these settings:

| Setting | Location | Value | Why |
|---------|----------|-------|-----|
| Boot Order | Boot Options | USB first (temporarily) | Boot from installer |
| Secure Boot | Security | Enabled | Ubuntu supports it |
| VT-x | Security > Virtualization | Enabled | Docker/KVM support |
| VT-d | Security > Virtualization | Enabled | Device passthrough |
| Wake on LAN | Advanced > Power | Enabled | Remote wake capability |
| After Power Loss | Advanced > Power | Power On | Auto-restart after outage |
| TPM Device | Security | Available | Disk encryption support |
| Fan Always On | Thermal | Enabled | Prevent thermal throttling |

3. Save and exit (F10)

The "After Power Loss → Power On" setting is critical — if there's a power
outage, the PC will automatically restart and your OpenCLAW gateway comes
back up via systemd.

### Phase 3: Install Ubuntu Server 24.04 LTS

1. Boot from USB
2. Select "Install Ubuntu Server"
3. Language: English
4. Network: The Intel I219-LM will auto-detect via DHCP. Note the IP.
5. Proxy: Skip (unless your network requires one)
6. Mirror: Default (archive.ubuntu.com)
7. Storage layout: **Use entire disk** with LVM
   - Enable encryption if you want full-disk encryption (recommended for
     a machine handling messaging data)
8. Profile setup:
   - Name: your name
   - Server name: `openclaw-server` (or your preference)
   - Username: `openclaw`
   - Password: strong password
9. SSH: **Install OpenSSH server** ← critical for remote management
10. Featured snaps: Skip all
11. Wait for installation to complete, remove USB, reboot

### Phase 4: Initial Server Configuration

SSH into the server from your main machine:

```bash
ssh openclaw@<IP-ADDRESS>
```

Run these commands:

```bash
# Update everything
sudo apt update && sudo apt upgrade -y

# Set static IP (replace with your network details)
sudo tee /etc/netplan/01-static.yaml > /dev/null << 'EOF'
network:
  version: 2
  ethernets:
    eno1:
      dhcp4: false
      addresses:
        - 192.168.1.100/24    # Choose an IP outside your DHCP range
      routes:
        - to: default
          via: 192.168.1.1    # Your router IP
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
EOF
sudo netplan apply

# Set timezone
sudo timedatectl set-timezone America/New_York  # Adjust to your timezone

# Enable automatic security updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Install essential tools
sudo apt install -y curl git build-essential htop tmux ufw

# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 18789/tcp comment "OpenCLAW Gateway"
sudo ufw enable
```

### Phase 5: Install Node.js 22

```bash
# Install Node.js 22 via NodeSource
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node -v   # Should show v22.x.x
npm -v    # Should show 10.x.x
```

### Phase 6: Install Docker

```bash
# Install Docker Engine (not Docker Desktop)
curl -fsSL https://get.docker.com | sudo sh

# Add your user to the docker group
sudo usermod -aG docker $USER

# Enable Docker to start on boot
sudo systemctl enable docker

# Log out and back in for group change to take effect
exit
# SSH back in
ssh openclaw@192.168.1.100

# Verify
docker run hello-world
```

### Phase 7: Install OpenCLAW

```bash
# Install OpenCLAW globally
sudo npm install -g openclaw@latest

# Create config directory
mkdir -p ~/.openclaw

# Create environment file
cat > ~/.openclaw/.env << 'EOF'
# === Model Provider (at least one required) ===
ANTHROPIC_API_KEY=sk-ant-YOUR-KEY-HERE

# === Optional: Additional providers ===
# OPENAI_API_KEY=sk-...

# === Channels (add as needed) ===
# TELEGRAM_BOT_TOKEN=
# DISCORD_BOT_TOKEN=
# SLACK_BOT_TOKEN=

# === Voice (optional) ===
# ELEVENLABS_API_KEY=
EOF

# IMPORTANT: Secure the env file
chmod 600 ~/.openclaw/.env

# Edit and add your actual API key
nano ~/.openclaw/.env
```

### Phase 8: Run Onboarding

```bash
openclaw onboard --install-daemon
```

Follow the wizard. It will:
- Set up the Gateway
- Configure your workspace
- Generate a gateway token
- Install the daemon

### Phase 9: Create systemd Service

```bash
sudo tee /etc/systemd/system/openclaw-gateway.service > /dev/null << 'EOF'
[Unit]
Description=OpenCLAW Gateway
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=simple
User=openclaw
Group=openclaw
WorkingDirectory=/home/openclaw
EnvironmentFile=/home/openclaw/.openclaw/.env
ExecStart=/usr/bin/openclaw gateway start
Restart=always
RestartSec=5
StartLimitIntervalSec=60
StartLimitBurst=5

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/openclaw/.openclaw /home/openclaw/openclaw-workspace
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable openclaw-gateway
sudo systemctl start openclaw-gateway

# Verify it's running
sudo systemctl status openclaw-gateway
```

### Phase 10: Set Up Remote Access (Tailscale)

Do NOT expose port 18789 directly to the internet. Use Tailscale instead:

```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Authenticate
sudo tailscale up

# Note your Tailscale IP (100.x.x.x)
tailscale ip -4
```

Now you can access your OpenCLAW gateway from any device on your Tailscale
network at `ws://100.x.x.x:18789`.

### Phase 11: Connect Channels

```bash
# Connect Telegram
openclaw channels add telegram --token YOUR_BOT_TOKEN

# Connect Discord
openclaw channels add discord --token YOUR_BOT_TOKEN

# Connect WhatsApp (QR code pairing)
openclaw channels add whatsapp

# Verify all channels
openclaw channels list
```

### Phase 12: Health Check

```bash
# Run built-in diagnostics
openclaw doctor

# Check Gateway status
openclaw gateway status

# View logs
journalctl -u openclaw-gateway -f
```

---

## Monitoring & Maintenance

### Daily (automated)
- `unattended-upgrades` handles security patches
- systemd auto-restarts OpenCLAW if it crashes
- "After Power Loss → Power On" BIOS setting handles power outages

### Weekly (manual, 5 minutes)
```bash
# SSH in and check status
ssh openclaw@192.168.1.100
openclaw doctor
journalctl -u openclaw-gateway --since "1 week ago" --priority err
```

### Monthly (manual, 15 minutes)
```bash
# Update OpenCLAW
sudo npm update -g openclaw

# Update system packages
sudo apt update && sudo apt upgrade -y

# Check disk usage
df -h

# Restart gateway after updates
sudo systemctl restart openclaw-gateway
```

### Kernel Updates (every few months)
Ubuntu Pro (free for up to 5 machines) provides kernel livepatch — no reboot
needed for most kernel security updates:

```bash
# Enable Ubuntu Pro (free tier)
sudo pro attach
sudo pro enable livepatch
```

---

## Performance Tuning for This Hardware

### Optimize for the i5-10500

```bash
# Set CPU governor to performance (prevents frequency scaling delays)
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo apt install -y cpufrequtils
sudo systemctl restart cpufrequtils

# Increase file descriptor limits (for many WebSocket connections)
sudo tee -a /etc/security/limits.conf > /dev/null << 'EOF'
openclaw soft nofile 65536
openclaw hard nofile 65536
EOF

# Increase inotify watchers (for skill file watching)
echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.d/99-openclaw.conf
sudo sysctl -p /etc/sysctl.d/99-openclaw.conf
```

### Node.js Memory Allocation

With 32GB RAM and ~700MB OS overhead, you have ~31GB available. Configure
Node.js to use a generous heap:

```bash
# Add to ~/.openclaw/.env
NODE_OPTIONS="--max-old-space-size=4096"
```

4GB heap is generous for OpenCLAW. The remaining ~27GB is available for Docker
containers, browser automation (Chromium), and OS file cache.

### Resource Budget

| Component | RAM Allocation | Notes |
|-----------|---------------|-------|
| Ubuntu Server OS | ~700MB | Kernel + systemd + base services |
| Docker daemon | ~200MB | Container management overhead |
| OpenCLAW Gateway | ~500MB-2GB | Depends on active sessions |
| Node.js heap reserve | 4GB | For peak loads |
| Chromium (browser automation) | 1-3GB | Per browser instance |
| OS file cache | Remaining | Linux uses free RAM as disk cache |
| **Total used** | **~6-10GB** | |
| **Available headroom** | **~22-26GB** | Plenty of room |

You do NOT need to upgrade to 64GB. 32GB is overkill for OpenCLAW.

---

## Power & Thermal Considerations

The HP ProDesk 600 G6 SFF is designed for business environments and handles
24/7 operation well:

- Idle power: ~25W (very efficient for an always-on server)
- Load power: ~65W (during browser automation or heavy processing)
- Annual electricity cost at idle: ~$25-30/year (at $0.12/kWh)
- The 180W 80+ Gold PSU is efficient at low loads
- Stock cooling is adequate — the SFF chassis has good airflow for a 65W TDP CPU
- Place the PC in a well-ventilated area, not inside a closed cabinet

---

## Backup Strategy

```bash
# Install restic for encrypted backups
sudo apt install -y restic

# Initialize backup repository (local or remote)
restic init --repo /mnt/backup/openclaw
# Or to a remote location:
# restic init --repo sftp:user@backup-server:/backups/openclaw

# Create backup script
cat > ~/backup-openclaw.sh << 'BKEOF'
#!/bin/bash
set -euo pipefail
REPO="/mnt/backup/openclaw"
restic backup \
  --repo "$REPO" \
  ~/.openclaw \
  ~/openclaw-workspace \
  /etc/systemd/system/openclaw-gateway.service \
  --exclude '*.log' \
  --exclude 'node_modules'
restic forget --repo "$REPO" --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
BKEOF
chmod +x ~/backup-openclaw.sh

# Schedule daily backup at 3 AM
(crontab -l 2>/dev/null; echo "0 3 * * * /home/openclaw/backup-openclaw.sh") | crontab -
```

---

## Quick Reference Card

```
Server IP:        192.168.1.100 (adjust to your network)
Tailscale IP:     100.x.x.x (after Tailscale setup)
Gateway:          ws://192.168.1.100:18789
SSH:              ssh openclaw@192.168.1.100

# Service management
sudo systemctl status openclaw-gateway
sudo systemctl restart openclaw-gateway
sudo systemctl stop openclaw-gateway
journalctl -u openclaw-gateway -f

# OpenCLAW commands
openclaw doctor
openclaw gateway status
openclaw channels list
openclaw logs --tail 50

# System monitoring
htop
df -h
free -h
```

---

*Generated: 2026-02-19 | For HP ProDesk 600 G6 SFF + OpenCLAW*
