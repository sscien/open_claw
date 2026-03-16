#!/usr/bin/env bash
# ============================================================================
# OpenCLAW Setup Script for HP ProDesk 600 G6 SFF
# Run this AFTER installing Ubuntu Server 24.04 LTS
# Usage: bash setup_prodesk_600_g6.sh [--skip-docker] [--skip-tailscale]
# ============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
err()   { echo -e "${RED}[✗]${NC} $*" >&2; }
info()  { echo -e "${BLUE}[i]${NC} $*"; }
die()   { err "$@"; exit 1; }

SKIP_DOCKER=false
SKIP_TAILSCALE=false
OPENCLAW_USER="${USER}"
OPENCLAW_DIR="$HOME/.openclaw"
STATIC_IP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-docker)    SKIP_DOCKER=true; shift ;;
    --skip-tailscale) SKIP_TAILSCALE=true; shift ;;
    --ip)             STATIC_IP="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: $0 [--skip-docker] [--skip-tailscale] [--ip STATIC_IP]"
      exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OpenCLAW Setup — HP ProDesk 600 G6 SFF         ║${NC}"
echo -e "${BLUE}║  Ubuntu Server 24.04 LTS                        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# --- Verify we're on Ubuntu ------------------------------------------------
if [[ ! -f /etc/os-release ]] || ! grep -q "Ubuntu" /etc/os-release; then
  die "This script is designed for Ubuntu Server 24.04 LTS"
fi
. /etc/os-release
log "Detected: $PRETTY_NAME"

# --- Verify hardware (optional check) --------------------------------------
if lscpu | grep -q "i5-10500" 2>/dev/null; then
  log "CPU: Intel Core i5-10500 confirmed"
else
  warn "Expected i5-10500 — running on different hardware (continuing anyway)"
fi

TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
log "RAM: ${TOTAL_RAM}GB detected"

# ============================================================================
# STEP 1: System Update
# ============================================================================
info "Step 1/10: Updating system packages..."
sudo apt update -qq
sudo apt upgrade -y -qq
log "System updated"

# ============================================================================
# STEP 2: Install Essential Packages
# ============================================================================
info "Step 2/10: Installing essential packages..."
sudo apt install -y -qq \
  curl git build-essential htop tmux ufw \
  unattended-upgrades apt-listchanges \
  cpufrequtils net-tools lsof

# Enable unattended security upgrades
sudo dpkg-reconfigure -plow unattended-upgrades 2>/dev/null || true
log "Essential packages installed"

# ============================================================================
# STEP 3: Configure Firewall
# ============================================================================
info "Step 3/10: Configuring firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 18789/tcp comment "OpenCLAW Gateway"
echo "y" | sudo ufw enable 2>/dev/null || true
log "Firewall configured (SSH + port 18789)"

# ============================================================================
# STEP 4: Performance Tuning
# ============================================================================
info "Step 4/10: Applying performance tuning..."

# CPU governor
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils > /dev/null
sudo systemctl restart cpufrequtils 2>/dev/null || true

# File descriptor limits
if ! grep -q "openclaw" /etc/security/limits.conf 2>/dev/null; then
  sudo tee -a /etc/security/limits.conf > /dev/null << 'EOF'
# OpenCLAW limits
openclaw soft nofile 65536
openclaw hard nofile 65536
* soft nofile 65536
* hard nofile 65536
EOF
fi

# inotify watchers
if ! grep -q "max_user_watches" /etc/sysctl.d/99-openclaw.conf 2>/dev/null; then
  sudo tee /etc/sysctl.d/99-openclaw.conf > /dev/null << 'EOF'
fs.inotify.max_user_watches=524288
fs.inotify.max_user_instances=512
net.core.somaxconn=65535
net.ipv4.tcp_max_syn_backlog=65535
EOF
  sudo sysctl -p /etc/sysctl.d/99-openclaw.conf > /dev/null
fi

log "Performance tuning applied"

# ============================================================================
# STEP 5: Install Node.js 22
# ============================================================================
info "Step 5/10: Installing Node.js 22..."
if command -v node &>/dev/null; then
  NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
  if [[ "$NODE_VER" -ge 22 ]]; then
    log "Node.js $(node -v) already installed"
  else
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
  fi
else
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt install -y nodejs
fi
log "Node.js $(node -v) ready"

# ============================================================================
# STEP 6: Install Docker
# ============================================================================
if [[ "$SKIP_DOCKER" == false ]]; then
  info "Step 6/10: Installing Docker..."
  if command -v docker &>/dev/null; then
    log "Docker already installed: $(docker --version)"
  else
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$OPENCLAW_USER"
    sudo systemctl enable docker
    log "Docker installed (re-login needed for group change)"
  fi
else
  info "Step 6/10: Skipping Docker (--skip-docker)"
fi

# ============================================================================
# STEP 7: Install OpenCLAW
# ============================================================================
info "Step 7/10: Installing OpenCLAW..."
sudo npm install -g openclaw@latest
log "OpenCLAW installed: $(openclaw --version 2>/dev/null || echo 'latest')"

# ============================================================================
# STEP 8: Configure OpenCLAW
# ============================================================================
info "Step 8/10: Configuring OpenCLAW..."
mkdir -p "$OPENCLAW_DIR"

if [[ ! -f "$OPENCLAW_DIR/.env" ]]; then
  cat > "$OPENCLAW_DIR/.env" << 'ENVEOF'
# ============================================================================
# OpenCLAW Configuration — HP ProDesk 600 G6 SFF
# ============================================================================

# === Model Provider (at least one required) ===
# ANTHROPIC_API_KEY=sk-ant-...
# OPENAI_API_KEY=sk-...

# === Node.js Performance ===
NODE_OPTIONS="--max-old-space-size=4096"

# === Channels (uncomment and fill as needed) ===
# TELEGRAM_BOT_TOKEN=
# DISCORD_BOT_TOKEN=
# SLACK_BOT_TOKEN=

# === Voice (optional) ===
# ELEVENLABS_API_KEY=
ENVEOF
  chmod 600 "$OPENCLAW_DIR/.env"
  log "Created $OPENCLAW_DIR/.env"
  warn "IMPORTANT: Edit $OPENCLAW_DIR/.env and add your API key!"
else
  log "Config already exists"
fi

# ============================================================================
# STEP 9: Create systemd Service
# ============================================================================
info "Step 9/10: Creating systemd service..."
sudo tee /etc/systemd/system/openclaw-gateway.service > /dev/null << EOF
[Unit]
Description=OpenCLAW Gateway
After=network-online.target docker.service
Wants=network-online.target

[Service]
Type=simple
User=$OPENCLAW_USER
Group=$OPENCLAW_USER
WorkingDirectory=/home/$OPENCLAW_USER
EnvironmentFile=/home/$OPENCLAW_USER/.openclaw/.env
ExecStart=$(which openclaw) gateway start
Restart=always
RestartSec=5
StartLimitIntervalSec=60
StartLimitBurst=5
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable openclaw-gateway
log "systemd service created and enabled"

# ============================================================================
# STEP 10: Install Tailscale (Remote Access)
# ============================================================================
if [[ "$SKIP_TAILSCALE" == false ]]; then
  info "Step 10/10: Installing Tailscale..."
  if command -v tailscale &>/dev/null; then
    log "Tailscale already installed"
  else
    curl -fsSL https://tailscale.com/install.sh | sh
    log "Tailscale installed"
    info "Run 'sudo tailscale up' to authenticate"
  fi
else
  info "Step 10/10: Skipping Tailscale (--skip-tailscale)"
fi

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup Complete!                                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo ""
echo -e "  ${CYAN}1.${NC} Edit your API key:"
echo "     nano ~/.openclaw/.env"
echo ""
echo -e "  ${CYAN}2.${NC} Run onboarding:"
echo "     openclaw onboard --install-daemon"
echo ""
echo -e "  ${CYAN}3.${NC} Start the gateway:"
echo "     sudo systemctl start openclaw-gateway"
echo ""
echo -e "  ${CYAN}4.${NC} Set up Tailscale (remote access):"
echo "     sudo tailscale up"
echo ""
echo -e "  ${CYAN}5.${NC} Connect channels:"
echo "     openclaw channels add telegram --token YOUR_TOKEN"
echo "     openclaw channels add whatsapp"
echo ""
echo -e "  ${CYAN}6.${NC} Verify everything:"
echo "     openclaw doctor"
echo "     sudo systemctl status openclaw-gateway"
echo ""
echo "Server details:"
echo "  IP:       $(hostname -I | awk '{print $1}')"
echo "  Hostname: $(hostname)"
echo "  Gateway:  ws://$(hostname -I | awk '{print $1}'):18789"
echo "  RAM:      ${TOTAL_RAM}GB total"
echo ""
