# OpenCLAW Deployment Guide

> Comprehensive step-by-step guide for deploying OpenCLAW on macOS, Windows, Linux,
> Docker, and cloud platforms (Fly.io, Render).

**Source**: https://github.com/openclaw/openclaw
**Docs**: https://docs.openclaw.ai
**License**: MIT

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [macOS Deployment](#macos-deployment)
4. [Windows Deployment](#windows-deployment)
5. [Linux Server Deployment](#linux-server-deployment)
6. [Docker Deployment](#docker-deployment)
7. [Cloud Deployment (Fly.io / Render)](#cloud-deployment)
8. [Configuration Reference](#configuration-reference)
9. [Channel Setup](#channel-setup)
10. [Troubleshooting](#troubleshooting)

---

## Overview

OpenCLAW is a self-hosted personal AI assistant that connects to multiple messaging
channels (WhatsApp, Telegram, Slack, Discord, Signal, iMessage, Teams, Matrix, etc.).

**Architecture**:
- **Gateway**: WebSocket control plane running at `ws://127.0.0.1:18789`
- **CLI**: Command-line interface for management and interaction
- **Channels**: Messaging platform connectors
- **Skills**: Extensible capabilities via ClawHub marketplace
- **Canvas**: Visual workspace with agent-driven UI

**Recommended Model**: Anthropic Claude Opus 4.6 (via Claude Pro/Max subscription)

---

## Prerequisites

| Requirement       | Version   | Notes                                    |
|-------------------|-----------|------------------------------------------|
| Node.js           | >= 22.12  | Required for all platforms               |
| pnpm              | >= 10.23  | Only for source builds                   |
| Git               | Latest    | Only for source builds                   |
| Docker            | >= 24.0   | Only for Docker/cloud deployments        |
| Docker Compose    | >= 2.20   | Only for Docker deployments              |

**API Keys** (at least one required):
- Anthropic API key (`ANTHROPIC_API_KEY`) — recommended
- OpenAI API key (`OPENAI_API_KEY`) — alternative

---

## macOS Deployment

### Option A: NPM Global Install (Recommended)

```bash
# 1. Install Node.js 22+ via Homebrew
brew install node@22

# 2. Install OpenCLAW globally
npm install -g openclaw@latest

# 3. Run the onboarding wizard (sets up Gateway + workspace)
openclaw onboard --install-daemon

# 4. Verify installation
openclaw doctor
```

### Option B: Source Build

```bash
# 1. Install dependencies
brew install node@22 git
corepack enable

# 2. Clone and build
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm build

# 3. Run onboarding
pnpm openclaw onboard --install-daemon
```

### macOS-Specific Notes
- Voice Wake/Talk Mode is natively supported on macOS
- iMessage integration available via BlueBubbles
- The Gateway daemon installs as a launchd service
- Run `scripts/macos/deploy_macos.sh` for automated setup

---

## Windows Deployment

### Option A: Native Windows (Node.js)

```powershell
# 1. Install Node.js 22+ from https://nodejs.org or via winget
winget install OpenJS.NodeJS.LTS

# 2. Open PowerShell as Administrator
npm install -g openclaw@latest

# 3. Run onboarding
openclaw onboard --install-daemon

# 4. Verify
openclaw doctor
```

### Option B: WSL2 (Recommended for full feature support)

```powershell
# 1. Enable WSL2
wsl --install -d Ubuntu-24.04

# 2. Inside WSL2 terminal:
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs git build-essential

# 3. Install OpenCLAW
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

### Option C: Docker Desktop on Windows

```powershell
# 1. Install Docker Desktop from https://docker.com
# 2. Enable WSL2 backend in Docker Desktop settings
# 3. Use the Docker deployment scripts (see Docker section)
```

### Windows-Specific Notes
- WSL2 is recommended for channel integrations that need Unix sockets
- Native Windows works for basic CLI + WebChat usage
- Voice features require WSL2 or are limited on native Windows
- Run `scripts/windows/deploy_windows.ps1` for automated setup

---

## Linux Server Deployment

### Ubuntu/Debian

```bash
# 1. Install Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs git build-essential

# 2. Install OpenCLAW
npm install -g openclaw@latest

# 3. Run onboarding (headless mode for servers)
openclaw onboard --install-daemon

# 4. Enable as systemd service
sudo cp ~/.openclaw/openclaw-gateway.service /etc/systemd/system/
sudo systemctl enable openclaw-gateway
sudo systemctl start openclaw-gateway
```

### RHEL/CentOS/Fedora

```bash
# 1. Install Node.js 22
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo dnf install -y nodejs git gcc-c++ make

# 2. Install and onboard
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

### Source Build on Linux

```bash
# 1. Install prerequisites
sudo apt-get install -y nodejs git build-essential
corepack enable

# 2. Clone and build
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm build

# 3. Onboard
pnpm openclaw onboard --install-daemon
```

### Linux-Specific Notes
- Headless servers: use `--no-voice` flag if no audio hardware
- Firewall: open port 18789 only on localhost (default)
- For remote access, use Tailscale or SSH tunnel — do NOT expose Gateway directly
- Run `scripts/linux/deploy_linux.sh` for automated setup

---

## Docker Deployment

### Quick Start

```bash
# 1. Clone the repo (for docker-compose.yml)
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 2. Copy and configure environment
cp .env.example .env
# Edit .env with your API keys and preferences

# 3. Run the Docker setup script
bash docker-setup.sh

# 4. Or use docker-compose directly
docker compose up -d
```

### Docker Compose Services

The `docker-compose.yml` defines two services:
- `openclaw-gateway`: The persistent Gateway daemon
- `openclaw-cli`: Interactive CLI for management

### Custom Docker Build

```bash
# Build with browser support (for web scraping skills)
docker build \
  --build-arg INSTALL_BROWSER=true \
  --build-arg EXTRA_APT_PACKAGES="ffmpeg" \
  -t openclaw:custom .

# Run
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  -v openclaw-data:/data \
  -e ANTHROPIC_API_KEY=your-key-here \
  openclaw:custom
```

### Podman (Rootless Alternative)

```bash
# Use the provided Podman setup script
bash setup-podman.sh --container

# Or with systemd Quadlet integration
bash setup-podman.sh --quadlet
```

Run `scripts/docker/deploy_docker.sh` for automated Docker setup.

---

## Cloud Deployment

### Fly.io

```bash
# 1. Install flyctl
curl -L https://fly.io/install.sh | sh

# 2. Login and launch
fly auth login
fly launch --copy-config

# 3. Set secrets
fly secrets set ANTHROPIC_API_KEY=your-key
fly secrets set OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)

# 4. Create persistent volume
fly volumes create openclaw_data --size 1 --region iad

# 5. Deploy
fly deploy
```

### Render

Push to GitHub and connect the repo to Render. The `render.yaml` blueprint
auto-configures a web service with a 1GB persistent disk.

---

## Configuration Reference

### Environment Variables

| Variable                  | Required | Description                              |
|---------------------------|----------|------------------------------------------|
| `ANTHROPIC_API_KEY`       | Yes*     | Anthropic API key                        |
| `OPENAI_API_KEY`          | Yes*     | OpenAI API key (*one provider required)  |
| `OPENCLAW_GATEWAY_TOKEN`  | Auto     | Gateway auth token (auto-generated)      |
| `OPENCLAW_CONFIG_DIR`     | No       | Config directory (default: ~/.openclaw)  |
| `OPENCLAW_WORKSPACE_DIR`  | No       | Workspace directory                      |
| `OPENCLAW_STATE_DIR`      | No       | State/data directory                     |
| `TELEGRAM_BOT_TOKEN`      | No       | Telegram bot token                       |
| `DISCORD_BOT_TOKEN`       | No       | Discord bot token                        |
| `SLACK_BOT_TOKEN`         | No       | Slack bot token                          |
| `ELEVENLABS_API_KEY`      | No       | Voice synthesis (ElevenLabs)             |

### Config Precedence

Environment variables are resolved in this order:
1. Process environment
2. `./.env` (project directory)
3. `~/.openclaw/.env` (user config)
4. `openclaw.json`

---

## Channel Setup

After deployment, connect messaging channels:

```bash
# List available channels
openclaw channels list

# Connect Telegram
openclaw channels add telegram --token YOUR_BOT_TOKEN

# Connect Discord
openclaw channels add discord --token YOUR_BOT_TOKEN

# Connect Slack
openclaw channels add slack --token YOUR_BOT_TOKEN

# Connect WhatsApp (QR code pairing)
openclaw channels add whatsapp
```

---

## Troubleshooting

### Common Issues

| Issue                        | Solution                                          |
|------------------------------|---------------------------------------------------|
| `EACCES` on npm install      | Use `sudo npm install -g` or fix npm permissions  |
| Gateway won't start          | Check port 18789 is free: `lsof -i :18789`       |
| Node version too old         | Upgrade to Node >= 22.12: `nvm install 22`       |
| Docker build fails           | Ensure Docker >= 24.0 and sufficient disk space   |
| Channel connection drops     | Run `openclaw doctor` to diagnose                 |
| Permission denied (Linux)    | Check file ownership in ~/.openclaw               |

### Health Check

```bash
# Run the built-in diagnostics
openclaw doctor

# Check Gateway status
openclaw gateway status

# View logs
openclaw logs --tail 50
```

### Security

- The Gateway binds to localhost by default — never expose it directly to the internet
- Use Tailscale, WireGuard, or SSH tunnels for remote access
- DM pairing mode is enabled by default (unknown senders get a pairing code)
- Run `openclaw doctor` to surface risky configurations

---

*Generated: 2026-02-19 | Based on OpenCLAW v2026.2.x*
*Source: https://github.com/openclaw/openclaw*
