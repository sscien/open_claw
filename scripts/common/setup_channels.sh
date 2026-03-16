#!/usr/bin/env bash
# ============================================================================
# OpenCLAW Channel Setup Helper
# Interactive guide for connecting messaging channels
# Usage: bash setup_channels.sh
# ============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
info()  { echo -e "${BLUE}[i]${NC} $*"; }

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    OpenCLAW Channel Setup                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Check openclaw is available
if ! command -v openclaw &>/dev/null; then
  echo -e "${RED}Error: openclaw not found. Run the deployment script first.${NC}"
  exit 1
fi

echo "Available channels:"
echo ""
echo -e "  ${CYAN}1${NC}) Telegram       — Bot-based, easy setup"
echo -e "  ${CYAN}2${NC}) Discord        — Bot-based, server integration"
echo -e "  ${CYAN}3${NC}) Slack          — Workspace app integration"
echo -e "  ${CYAN}4${NC}) WhatsApp       — QR code pairing (via Baileys)"
echo -e "  ${CYAN}5${NC}) Signal         — Privacy-focused messaging"
echo -e "  ${CYAN}6${NC}) iMessage       — macOS only (via BlueBubbles)"
echo -e "  ${CYAN}7${NC}) Microsoft Teams"
echo -e "  ${CYAN}8${NC}) Matrix         — Decentralized protocol"
echo -e "  ${CYAN}9${NC}) Google Chat"
echo -e "  ${CYAN}10${NC}) WebChat       — Built-in web interface"
echo -e "  ${CYAN}0${NC}) Exit"
echo ""

while true; do
  read -rp "Select channel to set up (0-10): " CHOICE

  case "$CHOICE" in
    1)
      echo ""
      echo -e "${CYAN}=== Telegram Setup ===${NC}"
      echo ""
      echo "Steps to get a Telegram Bot Token:"
      echo "  1. Open Telegram and search for @BotFather"
      echo "  2. Send /newbot and follow the prompts"
      echo "  3. Copy the bot token (format: 123456:ABC-DEF...)"
      echo ""
      read -rp "Enter your Telegram Bot Token: " TOKEN
      if [[ -n "$TOKEN" ]]; then
        openclaw channels add telegram --token "$TOKEN"
        log "Telegram channel added!"
      fi
      ;;
    2)
      echo ""
      echo -e "${CYAN}=== Discord Setup ===${NC}"
      echo ""
      echo "Steps to get a Discord Bot Token:"
      echo "  1. Go to https://discord.com/developers/applications"
      echo "  2. Create New Application > Bot > Reset Token"
      echo "  3. Enable MESSAGE CONTENT INTENT under Privileged Intents"
      echo "  4. Use OAuth2 URL Generator to invite bot to your server"
      echo "     Scopes: bot | Permissions: Send Messages, Read Messages"
      echo ""
      read -rp "Enter your Discord Bot Token: " TOKEN
      if [[ -n "$TOKEN" ]]; then
        openclaw channels add discord --token "$TOKEN"
        log "Discord channel added!"
      fi
      ;;
    3)
      echo ""
      echo -e "${CYAN}=== Slack Setup ===${NC}"
      echo ""
      echo "Steps to get a Slack Bot Token:"
      echo "  1. Go to https://api.slack.com/apps"
      echo "  2. Create New App > From Scratch"
      echo "  3. OAuth & Permissions > Add scopes:"
      echo "     chat:write, channels:history, channels:read, im:history, im:read"
      echo "  4. Install to Workspace > Copy Bot User OAuth Token"
      echo ""
      read -rp "Enter your Slack Bot Token (xoxb-...): " TOKEN
      if [[ -n "$TOKEN" ]]; then
        openclaw channels add slack --token "$TOKEN"
        log "Slack channel added!"
      fi
      ;;
    4)
      echo ""
      echo -e "${CYAN}=== WhatsApp Setup ===${NC}"
      echo ""
      echo "WhatsApp uses QR code pairing (no token needed)."
      echo "A QR code will appear in your terminal."
      echo "Scan it with WhatsApp > Linked Devices > Link a Device"
      echo ""
      read -rp "Ready to pair? (y/n): " CONFIRM
      if [[ "$CONFIRM" =~ ^[Yy] ]]; then
        openclaw channels add whatsapp
        log "WhatsApp channel paired!"
      fi
      ;;
    5)
      echo ""
      echo -e "${CYAN}=== Signal Setup ===${NC}"
      echo ""
      echo "Signal requires signal-cli to be installed."
      echo "  brew install signal-cli  (macOS)"
      echo "  sudo apt install signal-cli  (Linux)"
      echo ""
      info "Follow the openclaw docs for Signal setup:"
      echo "  https://docs.openclaw.ai/channels/signal"
      ;;
    6)
      echo ""
      echo -e "${CYAN}=== iMessage Setup (macOS only) ===${NC}"
      echo ""
      if [[ "$(uname)" != "Darwin" ]]; then
        warn "iMessage is only available on macOS."
      else
        echo "iMessage integration uses BlueBubbles."
        echo "  1. Install BlueBubbles: https://bluebubbles.app"
        echo "  2. Set up the BlueBubbles server on your Mac"
        echo "  3. Get the server URL and password"
        echo ""
        info "Follow the openclaw docs for iMessage setup:"
        echo "  https://docs.openclaw.ai/channels/imessage"
      fi
      ;;
    7)
      echo ""
      echo -e "${CYAN}=== Microsoft Teams Setup ===${NC}"
      echo ""
      echo "Teams requires an Azure Bot registration."
      echo "  1. Go to https://portal.azure.com"
      echo "  2. Create a Bot Channels Registration"
      echo "  3. Configure the messaging endpoint"
      echo ""
      info "Follow the openclaw docs for Teams setup:"
      echo "  https://docs.openclaw.ai/channels/teams"
      ;;
    8)
      echo ""
      echo -e "${CYAN}=== Matrix Setup ===${NC}"
      echo ""
      echo "Matrix requires a homeserver account."
      read -rp "Enter Matrix homeserver URL (e.g., https://matrix.org): " SERVER
      read -rp "Enter Matrix username: " USER
      read -rsp "Enter Matrix password: " PASS
      echo ""
      if [[ -n "$SERVER" && -n "$USER" ]]; then
        openclaw channels add matrix --server "$SERVER" --user "$USER" --password "$PASS"
        log "Matrix channel added!"
      fi
      ;;
    9)
      echo ""
      echo -e "${CYAN}=== Google Chat Setup ===${NC}"
      echo ""
      echo "Google Chat requires a Google Workspace service account."
      info "Follow the openclaw docs for Google Chat setup:"
      echo "  https://docs.openclaw.ai/channels/google-chat"
      ;;
    10)
      echo ""
      echo -e "${CYAN}=== WebChat Setup ===${NC}"
      echo ""
      echo "WebChat is built-in and available at the Gateway URL."
      echo "No additional setup needed — just access the Canvas UI."
      log "WebChat is ready at ws://127.0.0.1:18789"
      ;;
    0)
      echo ""
      log "Channel setup complete!"
      echo ""
      echo "Connected channels:"
      openclaw channels list 2>/dev/null || info "Run 'openclaw channels list' to see connected channels"
      exit 0
      ;;
    *)
      warn "Invalid choice. Enter 0-10."
      ;;
  esac
  echo ""
done
