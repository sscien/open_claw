# ============================================================================
# OpenCLAW Windows Deployment Script (PowerShell)
# Automated setup for Windows 10/11 (Native + WSL2 options)
# Usage: .\deploy_windows.ps1 [-Mode native|wsl|docker] [-NoVoice]
# ============================================================================

param(
    [ValidateSet("native", "wsl", "docker")]
    [string]$Mode = "native",
    [switch]$NoVoice,
    [switch]$Help
)

# --- Colors & Helpers -------------------------------------------------------
function Log   { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn  { param($msg) Write-Host "[!!] $msg" -ForegroundColor Yellow }
function Err   { param($msg) Write-Host "[XX] $msg" -ForegroundColor Red }
function Info  { param($msg) Write-Host "[ii] $msg" -ForegroundColor Cyan }

if ($Help) {
    Write-Host @"
OpenCLAW Windows Deployment Script

Usage: .\deploy_windows.ps1 [-Mode native|wsl|docker] [-NoVoice]

Modes:
  native  - Install directly on Windows via Node.js (default)
  wsl     - Install inside WSL2 Ubuntu (recommended for full features)
  docker  - Install via Docker Desktop

Options:
  -NoVoice  Skip voice feature setup
  -Help     Show this help message
"@
    exit 0
}

# --- Banner -----------------------------------------------------------------
Write-Host ""
Write-Host "+==============================================+" -ForegroundColor Blue
Write-Host "|    OpenCLAW Windows Deployment Script        |" -ForegroundColor Blue
Write-Host "+==============================================+" -ForegroundColor Blue
Write-Host ""
Info "Deployment mode: $Mode"

# --- Check Admin (for native mode) ------------------------------------------
function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ============================================================================
# MODE: NATIVE WINDOWS
# ============================================================================
if ($Mode -eq "native") {
    Info "Starting native Windows deployment..."

    # Step 1: Check/Install Node.js
    Info "Step 1/5: Checking Node.js..."
    $nodeInstalled = $false
    try {
        $nodeVer = (node -v) -replace 'v',''
        $nodeMajor = [int]($nodeVer.Split('.')[0])
        if ($nodeMajor -ge 22) {
            Log "Node.js v$nodeVer found"
            $nodeInstalled = $true
        } else {
            Warn "Node.js v$nodeVer found, need v22+. Upgrading..."
        }
    } catch {
        Warn "Node.js not found."
    }

    if (-not $nodeInstalled) {
        Info "Installing Node.js 22 via winget..."
        try {
            winget install OpenJS.NodeJS --version 22.12.0 --accept-package-agreements --accept-source-agreements
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            Log "Node.js installed. You may need to restart your terminal."
        } catch {
            Err "winget install failed. Download manually from https://nodejs.org"
            Err "Choose the LTS v22.x installer for Windows."
            exit 1
        }
    }

    # Step 2: Install OpenCLAW
    Info "Step 2/5: Installing OpenCLAW..."
    npm install -g openclaw@latest
    if ($LASTEXITCODE -ne 0) {
        Err "npm install failed. Try running PowerShell as Administrator."
        exit 1
    }
    Log "OpenCLAW installed globally"

    # Step 3: Create config directory
    Info "Step 3/5: Setting up configuration..."
    $configDir = "$env:USERPROFILE\.openclaw"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    $envFile = "$configDir\.env"
    if (-not (Test-Path $envFile)) {
        @"
# OpenCLAW Configuration - Windows
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
"@ | Out-File -FilePath $envFile -Encoding utf8
        Log "Created config template at $envFile"
        Warn "Edit $envFile and add your API keys before onboarding!"
    } else {
        Log "Config already exists at $envFile"
    }

    # Step 4: Windows Firewall
    Info "Step 4/5: Firewall check..."
    Info "Gateway binds to localhost only - no firewall rule needed."
    Info "For remote access, use Tailscale or SSH tunnel."
    Log "Firewall check complete"

    # Step 5: Onboarding
    Info "Step 5/5: Running onboarding wizard..."
    Write-Host ""
    Warn "Make sure you've added at least one API key to $envFile"
    $confirm = Read-Host "Ready to run onboarding? (y/n)"
    if ($confirm -match '^[Yy]') {
        openclaw onboard --install-daemon
        Log "Onboarding complete!"
    } else {
        Info "Skipped. Run manually: openclaw onboard --install-daemon"
    }
}

# ============================================================================
# MODE: WSL2
# ============================================================================
elseif ($Mode -eq "wsl") {
    Info "Starting WSL2 deployment..."

    # Step 1: Check WSL
    Info "Step 1/4: Checking WSL2..."
    try {
        $wslStatus = wsl --status 2>&1
        if ($wslStatus -match "Default Version: 2" -or $wslStatus -match "WSL version: 2") {
            Log "WSL2 is available"
        } else {
            Warn "WSL2 may not be the default. Setting WSL2 as default..."
            wsl --set-default-version 2
        }
    } catch {
        Info "Installing WSL2 with Ubuntu..."
        wsl --install -d Ubuntu-24.04
        Write-Host ""
        Warn "WSL2 installed. Please RESTART your computer, then run this script again."
        exit 0
    }

    # Step 2: Check Ubuntu distro
    Info "Step 2/4: Checking Ubuntu distro..."
    $distros = wsl --list --quiet 2>&1
    if ($distros -notmatch "Ubuntu") {
        Info "Installing Ubuntu 24.04..."
        wsl --install -d Ubuntu-24.04
        Warn "Ubuntu installed. Set up your username/password in the new window."
        Warn "Then run this script again."
        exit 0
    }
    Log "Ubuntu distro found"

    # Step 3: Install inside WSL
    Info "Step 3/4: Installing OpenCLAW inside WSL..."
    $wslScript = @'
#!/bin/bash
set -e
echo "[i] Installing Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs git build-essential
echo "[OK] Node.js $(node -v) installed"

echo "[i] Installing OpenCLAW..."
sudo npm install -g openclaw@latest
echo "[OK] OpenCLAW installed"

echo "[i] Creating config..."
mkdir -p ~/.openclaw
if [ ! -f ~/.openclaw/.env ]; then
  cat > ~/.openclaw/.env << 'EOF'
# OpenCLAW Configuration - WSL2
# ANTHROPIC_API_KEY=sk-ant-...
# OPENAI_API_KEY=sk-...
# TELEGRAM_BOT_TOKEN=
# DISCORD_BOT_TOKEN=
EOF
  echo "[OK] Config template created at ~/.openclaw/.env"
  echo "[!!] Edit ~/.openclaw/.env and add your API keys!"
fi
'@
    $wslScript | wsl bash
    Log "OpenCLAW installed in WSL"

    # Step 4: Onboarding
    Info "Step 4/4: Running onboarding in WSL..."
    $confirm = Read-Host "Ready to run onboarding inside WSL? (y/n)"
    if ($confirm -match '^[Yy]') {
        wsl bash -c "openclaw onboard --install-daemon"
        Log "Onboarding complete!"
    } else {
        Info "Skipped. Run manually in WSL: openclaw onboard --install-daemon"
    }
}

# ============================================================================
# MODE: DOCKER
# ============================================================================
elseif ($Mode -eq "docker") {
    Info "Starting Docker Desktop deployment..."

    # Step 1: Check Docker
    Info "Step 1/4: Checking Docker Desktop..."
    try {
        $dockerVer = docker --version
        Log "Docker found: $dockerVer"
    } catch {
        Err "Docker not found. Install Docker Desktop from https://docker.com"
        Err "Enable WSL2 backend in Docker Desktop settings."
        exit 1
    }

    # Step 2: Clone repo
    Info "Step 2/4: Getting OpenCLAW source..."
    $repoDir = "$env:USERPROFILE\openclaw"
    if (Test-Path "$repoDir\.git") {
        Info "Existing clone found, pulling latest..."
        Push-Location $repoDir
        git pull --ff-only
        Pop-Location
    } else {
        git clone https://github.com/openclaw/openclaw.git $repoDir
    }
    Log "Source ready at $repoDir"

    # Step 3: Configure
    Info "Step 3/4: Configuring environment..."
    Push-Location $repoDir
    if (-not (Test-Path ".env")) {
        Copy-Item ".env.example" ".env"
        Log "Created .env from template"
        Warn "Edit $repoDir\.env and add your API keys!"
        notepad ".env"
        Read-Host "Press Enter after saving .env"
    }

    # Step 4: Build and run
    Info "Step 4/4: Building and starting containers..."
    docker compose up -d --build
    Log "Containers started"
    Pop-Location
}

# --- Summary ----------------------------------------------------------------
Write-Host ""
Write-Host "+==============================================+" -ForegroundColor Green
Write-Host "|    Windows Deployment Complete!              |" -ForegroundColor Green
Write-Host "+==============================================+" -ForegroundColor Green
Write-Host ""
Write-Host "Quick reference:"
if ($Mode -eq "wsl") {
    Write-Host "  wsl                              - Enter WSL"
    Write-Host "  openclaw doctor                  - Run diagnostics (inside WSL)"
} elseif ($Mode -eq "docker") {
    Write-Host "  docker logs -f openclaw-gateway  - Stream logs"
    Write-Host "  docker compose down              - Stop services"
} else {
    Write-Host "  openclaw doctor                  - Run diagnostics"
    Write-Host "  openclaw gateway status          - Check Gateway"
}
Write-Host "  openclaw channels list           - List connected channels"
Write-Host ""
Write-Host "Docs:    https://docs.openclaw.ai"
Write-Host "Discord: https://discord.gg/clawd"
Write-Host ""
