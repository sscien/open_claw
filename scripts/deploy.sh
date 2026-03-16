#!/usr/bin/env bash
# ============================================================================
# OpenCLAW Master Deployment Launcher
# Detects your OS and runs the appropriate deployment script
# Usage: bash deploy.sh [options]
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    OpenCLAW Deployment Launcher          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Darwin)
    echo -e "Detected: ${CYAN}macOS${NC} ($(uname -m))"
    echo ""
    echo "Options:"
    echo "  1) macOS deployment (npm or source)"
    echo "  2) Docker deployment"
    echo "  3) Cloud deployment (Fly.io / Render)"
    echo ""
    read -rp "Choose (1-3): " CHOICE
    case "$CHOICE" in
      1) bash "$SCRIPT_DIR/macos/deploy_macos.sh" "$@" ;;
      2) bash "$SCRIPT_DIR/docker/deploy_docker.sh" "$@" ;;
      3) bash "$SCRIPT_DIR/common/deploy_cloud.sh" "$@" ;;
      *) echo "Invalid choice"; exit 1 ;;
    esac
    ;;
  Linux)
    echo -e "Detected: ${CYAN}Linux${NC} ($(uname -m))"
    # Check if running in WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
      echo -e "  ${YELLOW}(Running inside WSL)${NC}"
    fi
    echo ""
    echo "Options:"
    echo "  1) Linux server deployment"
    echo "  2) Docker deployment"
    echo "  3) Cloud deployment (Fly.io / Render)"
    echo ""
    read -rp "Choose (1-3): " CHOICE
    case "$CHOICE" in
      1) bash "$SCRIPT_DIR/linux/deploy_linux.sh" "$@" ;;
      2) bash "$SCRIPT_DIR/docker/deploy_docker.sh" "$@" ;;
      3) bash "$SCRIPT_DIR/common/deploy_cloud.sh" "$@" ;;
      *) echo "Invalid choice"; exit 1 ;;
    esac
    ;;
  MINGW*|MSYS*|CYGWIN*)
    echo -e "Detected: ${CYAN}Windows${NC} (Git Bash / MSYS)"
    echo ""
    echo "For Windows, use the PowerShell script instead:"
    echo "  .\\windows\\deploy_windows.ps1 -Mode native"
    echo "  .\\windows\\deploy_windows.ps1 -Mode wsl"
    echo "  .\\windows\\deploy_windows.ps1 -Mode docker"
    echo ""
    echo "Or run the batch file:"
    echo "  .\\windows\\deploy_windows.bat"
    echo ""
    echo "Alternatively, choose Docker deployment (works from Git Bash):"
    read -rp "Run Docker deployment? (y/n): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy] ]]; then
      bash "$SCRIPT_DIR/docker/deploy_docker.sh" "$@"
    fi
    ;;
  *)
    echo "Unknown OS: $OS"
    echo "Try running the Docker deployment script directly:"
    echo "  bash docker/deploy_docker.sh"
    exit 1
    ;;
esac

echo ""
echo "Post-deployment:"
echo "  bash $SCRIPT_DIR/common/health_check.sh   — Verify installation"
echo "  bash $SCRIPT_DIR/common/setup_channels.sh  — Connect messaging channels"
echo ""
