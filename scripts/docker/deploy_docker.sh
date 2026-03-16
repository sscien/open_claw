#!/usr/bin/env bash
# ============================================================================
# OpenCLAW Docker Deployment Script
# Works on any OS with Docker installed
# Usage: bash deploy_docker.sh [--podman] [--browser] [--build-only] [--help]
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
CONTAINER_ENGINE="docker"
INSTALL_BROWSER=false
BUILD_ONLY=false
OPENCLAW_DATA_DIR="${OPENCLAW_DATA_DIR:-$HOME/.openclaw}"
OPENCLAW_WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/openclaw-workspace}"
GATEWAY_PORT=18789

# --- Parse Arguments --------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --podman)      CONTAINER_ENGINE="podman"; shift ;;
    --browser)     INSTALL_BROWSER=true; shift ;;
    --build-only)  BUILD_ONLY=true; shift ;;
    --help|-h)
      echo "Usage: $0 [--podman] [--browser] [--build-only] [--help]"
      echo "  --podman      Use Podman instead of Docker"
      echo "  --browser     Include Chromium for web scraping skills"
      echo "  --build-only  Build image without starting containers"
      exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

# --- Banner -----------------------------------------------------------------
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    OpenCLAW Docker Deployment Script     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
info "Container engine: $CONTAINER_ENGINE"

# --- Step 1: Check Container Engine -----------------------------------------
info "Step 1/7: Checking $CONTAINER_ENGINE..."
if ! command -v "$CONTAINER_ENGINE" &>/dev/null; then
  die "$CONTAINER_ENGINE is not installed. Install it first:
    Docker:  https://docs.docker.com/get-docker/
    Podman:  https://podman.io/getting-started/installation"
fi
log "$CONTAINER_ENGINE found: $($CONTAINER_ENGINE --version)"

# Check compose (Docker only)
if [[ "$CONTAINER_ENGINE" == "docker" ]]; then
  if docker compose version &>/dev/null; then
    log "Docker Compose found: $(docker compose version --short)"
  else
    die "Docker Compose v2 not found. Update Docker Desktop or install compose plugin."
  fi
fi

# --- Step 2: Clone Repository -----------------------------------------------
info "Step 2/7: Getting OpenCLAW source..."
REPO_DIR="${OPENCLAW_REPO_DIR:-$(pwd)/openclaw}"

if [[ -d "$REPO_DIR/.git" ]]; then
  info "Existing clone found at $REPO_DIR, pulling latest..."
  cd "$REPO_DIR"
  git pull --ff-only
else
  git clone https://github.com/openclaw/openclaw.git "$REPO_DIR"
  cd "$REPO_DIR"
fi
log "Source ready at $REPO_DIR"

# --- Step 3: Configure Environment ------------------------------------------
info "Step 3/7: Setting up environment..."
if [[ ! -f .env ]]; then
  cp .env.example .env
  log "Created .env from template"
  warn "Edit .env and add your API keys before continuing!"
  echo ""
  read -rp "Press Enter after editing .env (or Ctrl+C to abort)..."
else
  log ".env already exists"
fi

# Generate gateway token if not set
if ! grep -q "OPENCLAW_GATEWAY_TOKEN=." .env 2>/dev/null; then
  TOKEN=$(openssl rand -hex 32 2>/dev/null || python3 -c "import secrets; print(secrets.token_hex(32))")
  echo "OPENCLAW_GATEWAY_TOKEN=$TOKEN" >> .env
  log "Generated gateway token"
fi

# --- Step 4: Create Data Directories ----------------------------------------
info "Step 4/7: Creating data directories..."
mkdir -p "$OPENCLAW_DATA_DIR" "$OPENCLAW_WORKSPACE"
log "Data dir:      $OPENCLAW_DATA_DIR"
log "Workspace dir: $OPENCLAW_WORKSPACE"

# --- Step 5: Build Image ----------------------------------------------------
info "Step 5/7: Building container image..."
BUILD_ARGS=""
if [[ "$INSTALL_BROWSER" == true ]]; then
  BUILD_ARGS="--build-arg INSTALL_BROWSER=true"
  info "Including Chromium for web scraping skills"
fi

$CONTAINER_ENGINE build $BUILD_ARGS -t openclaw:latest .
log "Image built: openclaw:latest"

if [[ "$BUILD_ONLY" == true ]]; then
  log "Build complete (--build-only). Exiting."
  exit 0
fi

# --- Step 6: Start Services -------------------------------------------------
info "Step 6/7: Starting services..."

if [[ "$CONTAINER_ENGINE" == "docker" ]]; then
  # Use docker compose
  docker compose up -d
  log "Services started via docker compose"
else
  # Podman: run directly
  $CONTAINER_ENGINE run -d \
    --name openclaw-gateway \
    --restart unless-stopped \
    -p "127.0.0.1:${GATEWAY_PORT}:${GATEWAY_PORT}" \
    -v "$OPENCLAW_DATA_DIR:/data:Z" \
    -v "$OPENCLAW_WORKSPACE:/workspace:Z" \
    --env-file .env \
    openclaw:latest
  log "Gateway started via Podman"
fi

# --- Step 7: Verify ----------------------------------------------------------
info "Step 7/7: Verifying deployment..."
sleep 3

if $CONTAINER_ENGINE ps | grep -q openclaw; then
  log "Container is running"
else
  err "Container may not have started. Check logs:"
  echo "  $CONTAINER_ENGINE logs openclaw-gateway"
  exit 1
fi

# --- Summary ----------------------------------------------------------------
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Docker Deployment Complete!           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "Quick reference:"
echo "  $CONTAINER_ENGINE logs -f openclaw-gateway  — Stream logs"
echo "  $CONTAINER_ENGINE exec -it openclaw-gateway openclaw doctor"
echo "  $CONTAINER_ENGINE compose down              — Stop services"
echo "  $CONTAINER_ENGINE compose up -d             — Restart services"
echo ""
echo "Gateway:   ws://127.0.0.1:$GATEWAY_PORT"
echo "Data:      $OPENCLAW_DATA_DIR"
echo "Workspace: $OPENCLAW_WORKSPACE"
echo ""
