#!/usr/bin/env bash
# ============================================================================
# OpenCLAW Cloud Deployment Script (Fly.io + Render)
# Usage: bash deploy_cloud.sh [--fly|--render] [--region REGION] [--help]
# ============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
err()   { echo -e "${RED}[✗]${NC} $*" >&2; }
info()  { echo -e "${BLUE}[i]${NC} $*"; }
die()   { err "$@"; exit 1; }

PLATFORM="fly"
REGION="iad"
VOLUME_SIZE=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fly)     PLATFORM="fly"; shift ;;
    --render)  PLATFORM="render"; shift ;;
    --region)  REGION="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: $0 [--fly|--render] [--region REGION]"
      exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    OpenCLAW Cloud Deployment Script      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Clone Repo -------------------------------------------------------------
REPO_DIR="${OPENCLAW_REPO_DIR:-$(pwd)/openclaw}"
if [[ -d "$REPO_DIR/.git" ]]; then
  cd "$REPO_DIR"
  git pull --ff-only
else
  git clone https://github.com/openclaw/openclaw.git "$REPO_DIR"
  cd "$REPO_DIR"
fi
log "Source ready"

# ============================================================================
# FLY.IO DEPLOYMENT
# ============================================================================
if [[ "$PLATFORM" == "fly" ]]; then
  info "Deploying to Fly.io (region: $REGION)..."

  # Check flyctl
  if ! command -v fly &>/dev/null && ! command -v flyctl &>/dev/null; then
    info "Installing flyctl..."
    curl -L https://fly.io/install.sh | sh
    export PATH="$HOME/.fly/bin:$PATH"
  fi
  log "flyctl available"

  # Auth
  if ! fly auth whoami &>/dev/null; then
    info "Please log in to Fly.io..."
    fly auth login
  fi
  log "Authenticated with Fly.io"

  # Launch app
  info "Launching app..."
  fly launch --copy-config --region "$REGION" --no-deploy

  # Set secrets
  echo ""
  read -rp "Enter your ANTHROPIC_API_KEY: " API_KEY
  GATEWAY_TOKEN=$(openssl rand -hex 32)

  fly secrets set \
    ANTHROPIC_API_KEY="$API_KEY" \
    OPENCLAW_GATEWAY_TOKEN="$GATEWAY_TOKEN"
  log "Secrets configured"

  # Create volume
  info "Creating persistent volume (${VOLUME_SIZE}GB)..."
  fly volumes create openclaw_data --size "$VOLUME_SIZE" --region "$REGION" -y
  log "Volume created"

  # Deploy
  info "Deploying..."
  fly deploy
  log "Deployed to Fly.io!"

  echo ""
  echo "Your OpenCLAW instance:"
  fly status
  echo ""
  echo "Gateway token: $GATEWAY_TOKEN"
  echo "Save this token — you'll need it to connect clients."

# ============================================================================
# RENDER DEPLOYMENT
# ============================================================================
elif [[ "$PLATFORM" == "render" ]]; then
  info "Deploying to Render..."
  echo ""
  echo "Render uses a Blueprint (render.yaml) for auto-deployment."
  echo ""
  echo "Steps:"
  echo "  1. Push this repo to your GitHub account"
  echo "  2. Go to https://dashboard.render.com/select-repo?type=blueprint"
  echo "  3. Connect your GitHub repo"
  echo "  4. Render will auto-detect render.yaml and configure the service"
  echo "  5. Set environment variables in the Render dashboard:"
  echo "     - ANTHROPIC_API_KEY"
  echo "     - OPENCLAW_GATEWAY_TOKEN (generate with: openssl rand -hex 32)"
  echo ""

  read -rp "Would you like to fork the repo to your GitHub now? (y/n): " FORK
  if [[ "$FORK" =~ ^[Yy] ]]; then
    if command -v gh &>/dev/null; then
      gh repo fork openclaw/openclaw --clone=false
      log "Forked! Now go to Render dashboard to connect it."
    else
      warn "GitHub CLI not installed. Fork manually at:"
      echo "  https://github.com/openclaw/openclaw/fork"
    fi
  fi
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Cloud Deployment Complete!            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "Security reminders:"
echo "  - Enable HTTPS (Fly.io does this automatically)"
echo "  - Use the Gateway token for all client connections"
echo "  - Enable DM pairing mode for unknown senders"
echo ""
