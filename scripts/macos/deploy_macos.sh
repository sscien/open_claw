#!/usr/bin/env bash
# ============================================================================
# OpenCLAW macOS Deployment Script
# Automated setup for macOS (Intel & Apple Silicon)
# Usage: bash deploy_macos.sh [--source] [--no-voice] [--help]
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
INSTALL_MODE="npm"       # npm | source
ENABLE_VOICE=true
NODE_MIN_VERSION=22
OPENCLAW_DIR="$HOME/.openclaw"
CLONE_DIR="$HOME/openclaw"

# --- Parse Arguments --------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)    INSTALL_MODE="source"; shift ;;
    --no-voice)  ENABLE_VOICE=false; shift ;;
    --help|-h)
      echo "Usage: $0 [--source] [--no-voice] [--help]"
      echo "  --source    Build from source instead of npm"
      echo "  --no-voice  Skip voice/ElevenLabs setup"
      exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

# --- Banner -----------------------------------------------------------------
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     OpenCLAW macOS Deployment Script     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Detect Architecture ----------------------------------------------------
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  info "Detected Apple Silicon (arm64)"
else
  info "Detected Intel Mac (x86_64)"
fi

# --- Check macOS Version ----------------------------------------------------
MACOS_VERSION=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo "$MACOS_VERSION" | cut -d. -f1)
if [[ "$MACOS_MAJOR" -lt 13 ]]; then
  warn "macOS $MACOS_VERSION detected. macOS 13+ recommended."
fi
log "macOS $MACOS_VERSION"

# --- Step 1: Install Homebrew if missing ------------------------------------
info "Step 1/6: Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  warn "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  if [[ "$ARCH" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  fi
  log "Homebrew installed"
else
  log "Homebrew found: $(brew --version | head -1)"
fi

# --- Step 2: Install Node.js -----------------------------------------------
info "Step 2/6: Checking Node.js..."
install_node() {
  brew install node@22
  brew link --overwrite node@22 2>/dev/null || true
}

if command -v node &>/dev/null; then
  NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
  if [[ "$NODE_VER" -lt "$NODE_MIN_VERSION" ]]; then
    warn "Node.js v$NODE_VER found, need v$NODE_MIN_VERSION+. Upgrading..."
    install_node
  else
    log "Node.js $(node -v) found"
  fi
else
  warn "Node.js not found. Installing v22..."
  install_node
fi
log "Node.js $(node -v) ready"
log "npm $(npm -v) ready"

# --- Step 3: Install OpenCLAW -----------------------------------------------
info "Step 3/6: Installing OpenCLAW ($INSTALL_MODE mode)..."

if [[ "$INSTALL_MODE" == "source" ]]; then
  # Source build
  if ! command -v pnpm &>/dev/null; then
    corepack enable
    log "pnpm enabled via corepack"
  fi

  if [[ -d "$CLONE_DIR" ]]; then
    info "Updating existing clone at $CLONE_DIR..."
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
  # NPM global install
  npm install -g openclaw@latest
  log "OpenCLAW installed globally via npm"
fi

# --- Step 4: Create config directory ----------------------------------------
info "Step 4/6: Setting up configuration..."
mkdir -p "$OPENCLAW_DIR"

if [[ ! -f "$OPENCLAW_DIR/.env" ]]; then
  cat > "$OPENCLAW_DIR/.env" << 'ENVEOF'
# OpenCLAW Configuration — macOS
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

# === Voice (optional, macOS native supported) ===
# ELEVENLABS_API_KEY=
ENVEOF
  log "Created $OPENCLAW_DIR/.env template"
  warn "Edit $OPENCLAW_DIR/.env and add your API keys before onboarding!"
else
  log "Config file already exists at $OPENCLAW_DIR/.env"
fi

# --- Step 5: Voice Setup (macOS-specific) -----------------------------------
info "Step 5/6: Voice setup..."
if [[ "$ENABLE_VOICE" == true ]]; then
  log "Voice Wake/Talk Mode is natively supported on macOS"
  info "For ElevenLabs voice synthesis, add ELEVENLABS_API_KEY to .env"
else
  info "Voice setup skipped (--no-voice)"
fi

# --- Step 6: Run Onboarding -------------------------------------------------
info "Step 6/6: Running onboarding wizard..."
echo ""
warn "Make sure you've added at least one API key to $OPENCLAW_DIR/.env"
echo ""
read -rp "Ready to run onboarding? (y/n): " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy] ]]; then
  if [[ "$INSTALL_MODE" == "source" ]]; then
    cd "$CLONE_DIR"
    pnpm openclaw onboard --install-daemon
  else
    openclaw onboard --install-daemon
  fi
  log "Onboarding complete!"
else
  info "Skipped onboarding. Run manually later:"
  info "  openclaw onboard --install-daemon"
fi

# --- Post-Install Summary ---------------------------------------------------
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     macOS Deployment Complete!           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "Quick reference:"
echo "  openclaw doctor          — Run diagnostics"
echo "  openclaw gateway status  — Check Gateway"
echo "  openclaw channels list   — List connected channels"
echo "  openclaw logs --tail 20  — View recent logs"
echo ""
echo "Config:    $OPENCLAW_DIR/.env"
echo "Docs:      https://docs.openclaw.ai"
echo "Discord:   https://discord.gg/clawd"
echo ""
