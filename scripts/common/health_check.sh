#!/usr/bin/env bash
# ============================================================================
# OpenCLAW Health Check & Diagnostics
# Run after deployment to verify everything is working
# Usage: bash health_check.sh
# ============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

PASS=0; FAIL=0; WARN_COUNT=0

check_pass() { echo -e "  ${GREEN}✓${NC} $*"; ((PASS++)); }
check_fail() { echo -e "  ${RED}✗${NC} $*"; ((FAIL++)); }
check_warn() { echo -e "  ${YELLOW}!${NC} $*"; ((WARN_COUNT++)); }

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    OpenCLAW Health Check                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Node.js ----------------------------------------------------------------
echo "Node.js:"
if command -v node &>/dev/null; then
  NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
  if [[ "$NODE_VER" -ge 22 ]]; then
    check_pass "Node.js $(node -v)"
  else
    check_warn "Node.js $(node -v) — v22+ recommended"
  fi
else
  check_fail "Node.js not found"
fi

# --- OpenCLAW Binary --------------------------------------------------------
echo "OpenCLAW:"
if command -v openclaw &>/dev/null; then
  check_pass "openclaw binary found"
  VER=$(openclaw --version 2>/dev/null || echo "unknown")
  check_pass "Version: $VER"
else
  check_fail "openclaw not found in PATH"
fi

# --- Config -----------------------------------------------------------------
echo "Configuration:"
CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
if [[ -d "$CONFIG_DIR" ]]; then
  check_pass "Config directory: $CONFIG_DIR"
else
  check_fail "Config directory not found: $CONFIG_DIR"
fi

if [[ -f "$CONFIG_DIR/.env" ]]; then
  check_pass ".env file exists"
  # Check for API keys (without revealing them)
  if grep -q "ANTHROPIC_API_KEY=sk-" "$CONFIG_DIR/.env" 2>/dev/null; then
    check_pass "Anthropic API key configured"
  elif grep -q "OPENAI_API_KEY=sk-" "$CONFIG_DIR/.env" 2>/dev/null; then
    check_pass "OpenAI API key configured"
  else
    check_warn "No API key found in .env — at least one provider required"
  fi
else
  check_fail ".env file not found"
fi

# --- Gateway ----------------------------------------------------------------
echo "Gateway:"
if command -v openclaw &>/dev/null; then
  if openclaw gateway status &>/dev/null 2>&1; then
    check_pass "Gateway is running"
  else
    check_warn "Gateway not running (start with: openclaw gateway start)"
  fi
fi

# Check port
if command -v lsof &>/dev/null; then
  if lsof -i :18789 &>/dev/null; then
    check_pass "Port 18789 is in use (Gateway)"
  else
    check_warn "Port 18789 is free (Gateway not listening)"
  fi
elif command -v ss &>/dev/null; then
  if ss -tlnp | grep -q 18789; then
    check_pass "Port 18789 is in use (Gateway)"
  else
    check_warn "Port 18789 is free (Gateway not listening)"
  fi
fi

# --- Docker (if applicable) -------------------------------------------------
echo "Docker (optional):"
if command -v docker &>/dev/null; then
  check_pass "Docker: $(docker --version 2>/dev/null | head -1)"
  if docker ps 2>/dev/null | grep -q openclaw; then
    check_pass "OpenCLAW container is running"
  else
    check_warn "No OpenCLAW container running"
  fi
else
  check_warn "Docker not installed (only needed for Docker deployments)"
fi

# --- Summary ----------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${GREEN}Passed: $PASS${NC}  ${RED}Failed: $FAIL${NC}  ${YELLOW}Warnings: $WARN_COUNT${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$FAIL" -gt 0 ]]; then
  echo ""
  echo "Run 'openclaw doctor' for more detailed diagnostics."
  exit 1
fi
echo ""
