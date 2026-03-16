#!/usr/bin/env bash
# ============================================================================
# OpenCLAW Linux Server Deployment Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch
# Usage: bash deploy_linux.sh [--source] [--no-voice] [--systemd] [--help]
# ============================================================================
set -euo pipefail

# --- Colors & Helpers -------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
err()   { echo -e "${RED}[✗]${NC} $*" >&2; }
info()  { echo -e "${BLUE}[i]${NC} $*"; }
die()   { err "$@"; exit 1; }

# --- Defaults ---------------------------------------------------------------
INSTALL_MODE="npm"
ENABLE_VOICE=true
SETUP_SYSTEMD=false
NODE_MIN_VERSION=22
OPENCLAW_DIR="$HOME/.openclaw"
CLONE_DIR="$HOME/openclaw"

# --- Parse Arguments --------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)    INSTALL_MODE="source"; shift ;;
    --no-voice)  ENABLE_VOICE=false; shift ;;
    --systemd)   SETUP_SYSTEMD=true; shift ;;
    --help|-h)
      echo "Usage: $0 [--source] [--no-voice] [--systemd] [--help]"
      echo "  --source    Build from source instead of npm"
      echo "  --no-voice  Skip voice setup (headless servers)"
      echo "  --systemd   Install and enable systemd service"
      exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

# --- Banner -----------------------------------------------------------------
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    OpenCLAW Linux Deployment Script      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Detect Distro ----------------------------------------------------------
detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO_ID="$ID"
    DISTRO_NAME="$PRETTY_NAME"
  elif command -v lsb_release &>/dev/null; then
    DISTRO_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    DISTRO_NAME=$(lsb_release -sd)
  else
    DISTRO_ID="unknown"
    DISTRO_NAME="Unknown Linux"
  fi
}
detect_distro
info "Detected: $DISTRO_NAME"

# --- Step 1: Install System Dependencies ------------------------------------
info "Step 1/7: Installing system dependencies..."

install_deps_debian() {
  sudo apt-get update -qq
  sudo apt-get install -y curl git build-essential ca-certificates gnupg
}

install_deps_rhel() {
  sudo dnf install -y curl git gcc-c++ make ca-certificates
}

install_deps_arch() {
  sudo pacman -Sy --noconfirm curl git base-devel
}

case "$DISTRO_ID" in
  ubuntu|debian|pop|linuxmint|elementary)
    install_deps_debian ;;
  fedora|rhel|centos|rocky|alma)
    install_deps_rhel ;;
  arch|manjaro|endeavouros)
    install_deps_arch ;;
  *)
    warn "Unknown distro '$DISTRO_ID'. Attempting Debian-style install..."
    install_deps_debian ;;
esac
log "System dependencies installed"

# --- Step 2: Install Node.js ------------------------------------------------
info "Step 2/7: Checking Node.js..."

install_node_debian() {
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

install_node_rhel() {
  curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
  sudo dnf install -y nodejs
}

install_node_arch() {
  sudo pacman -S --noconfirm nodejs npm
}

install_node_nvm() {
  info "Installing via nvm as fallback..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install 22
  nvm use 22
}

if command -v node &>/dev/null; then
  NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
  if [[ "$NODE_VER" -lt "$NODE_MIN_VERSION" ]]; then
    warn "Node.js v$NODE_VER found, need v$NODE_MIN_VERSION+. Upgrading..."
    case "$DISTRO_ID" in
      ubuntu|debian|pop|linuxmint) install_node_debian ;;
      fedora|rhel|centos|rocky|alma) install_node_rhel ;;
      arch|manjaro) install_node_arch ;;
      *) install_node_nvm ;;
    esac
  else
    log "Node.js $(node -v) found"
  fi
else
  case "$DISTRO_ID" in
    ubuntu|debian|pop|linuxmint) install_node_debian ;;
    fedora|rhel|centos|rocky|alma) install_node_rhel ;;
    arch|manjaro) install_node_arch ;;
    *) install_node_nvm ;;
  esac
fi
log "Node.js $(node -v) ready"

# --- Step 3: Install OpenCLAW -----------------------------------------------
info "Step 3/7: Installing OpenCLAW ($INSTALL_MODE mode)..."

if [[ "$INSTALL_MODE" == "source" ]]; then
  if ! command -v pnpm &>/dev/null; then
    corepack enable
    log "pnpm enabled via corepack"
  fi

  if [[ -d "$CLONE_DIR" ]]; then
    info "Updating existing clone..."
    cd "$CLONE_DIR"
    git pull --ff-only
  else
    git clone https://github.com/openclaw/openclaw.git "$CLONE_DIR"
    cd "$CLONE_DIR"
  fi

  pnpm install
  pnpm build
  log "Source build complete"
else
  sudo npm install -g openclaw@latest
  log "OpenCLAW installed globally via npm"
fi

# --- Step 4: Configure Environment ------------------------------------------
info "Step 4/7: Setting up configuration..."
mkdir -p "$OPENCLAW_DIR"

if [[ ! -f "$OPENCLAW_DIR/.env" ]]; then
  cat > "$OPENCLAW_DIR/.env" << 'ENVEOF'
# OpenCLAW Configuration — Linux Server
# Uncomment and fill in the keys you need

# === Model Provider (at least one required) ===
# ANTHROPIC_API_KEY=sk-ant-...
# OPENAI_API_KEY=sk-...

# === Gateway ===
# OPENCLAW_GATEWAY_TOKEN=  (auto-generated during onboard)

# === Channels (optional) ===
# TELEGRAM_BOT_TOKEN=
# DISCORD_BOT_TOKEN=
# SLACK_BOT_TOKEN=

# === Voice (optional) ===
# ELEVENLABS_API_KEY=
ENVEOF
  log "Created $OPENCLAW_DIR/.env template"
  warn "Edit $OPENCLAW_DIR/.env and add your API keys!"
else
  log "Config already exists at $OPENCLAW_DIR/.env"
fi

# --- Step 5: Firewall -------------------------------------------------------
info "Step 5/7: Firewall configuration..."
if command -v ufw &>/dev/null; then
  info "UFW detected. Gateway binds to localhost only — no rule needed."
  info "If you need remote access, use Tailscale or SSH tunnel."
elif command -v firewall-cmd &>/dev/null; then
  info "firewalld detected. Gateway binds to localhost only — no rule needed."
fi
log "Firewall check complete"

# --- Step 6: Systemd Service ------------------------------------------------
info "Step 6/7: Systemd service setup..."

if [[ "$SETUP_SYSTEMD" == true ]]; then
  SERVICE_FILE="/etc/systemd/system/openclaw-gateway.service"
  EXEC_CMD="openclaw"
  if [[ "$INSTALL_MODE" == "source" ]]; then
    EXEC_CMD="$CLONE_DIR/node_modules/.bin/pnpm openclaw"
  fi

  sudo tee "$SERVICE_FILE" > /dev/null << SVCEOF
[Unit]
Description=OpenCLAW Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
EnvironmentFile=$OPENCLAW_DIR/.env
ExecStart=$EXEC_CMD gateway start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SVCEOF

  sudo systemctl daemon-reload
  sudo systemctl enable openclaw-gateway
  log "Systemd service installed and enabled"
  info "Start with: sudo systemctl start openclaw-gateway"
else
  info "Skipped systemd setup (use --systemd to enable)"
fi

# --- Step 7: Run Onboarding -------------------------------------------------
info "Step 7/7: Running onboarding wizard..."
echo ""
warn "Make sure you've added at least one API key to $OPENCLAW_DIR/.env"
echo ""
read -rp "Ready to run onboarding? (y/n): " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy] ]]; then
  VOICE_FLAG=""
  if [[ "$ENABLE_VOICE" == false ]]; then
    VOICE_FLAG="--no-voice"
  fi

  if [[ "$INSTALL_MODE" == "source" ]]; then
    cd "$CLONE_DIR"
    pnpm openclaw onboard --install-daemon $VOICE_FLAG
  else
    openclaw onboard --install-daemon $VOICE_FLAG
  fi
  log "Onboarding complete!"
else
  info "Skipped. Run manually: openclaw onboard --install-daemon"
fi

# --- Summary ----------------------------------------------------------------
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Linux Deployment Complete!            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "Quick reference:"
echo "  openclaw doctor          — Run diagnostics"
echo "  openclaw gateway status  — Check Gateway"
echo "  openclaw channels list   — List connected channels"
echo "  openclaw logs --tail 20  — View recent logs"
if [[ "$SETUP_SYSTEMD" == true ]]; then
  echo "  sudo systemctl status openclaw-gateway  — Service status"
  echo "  sudo journalctl -u openclaw-gateway -f   — Stream logs"
fi
echo ""
echo "Config:    $OPENCLAW_DIR/.env"
echo "Docs:      https://docs.openclaw.ai"
echo "Discord:   https://discord.gg/clawd"
echo ""
