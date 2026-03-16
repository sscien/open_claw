# Network Access Reference — Y. Song Infrastructure

> AI-readable reference document. Feed this to any Claude/AI session so it understands
> how to access servers from the M1 Max laptop regardless of physical network location.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        TAILSCALE MESH                           │
│                   (encrypted WireGuard tunnel)                  │
│                                                                 │
│  ┌──────────────┐         ┌──────────────────┐                  │
│  │   M1 Max     │◄───────►│   M1 Mac Mini    │                  │
│  │  (laptop)    │  Tailscale  (office server) │                  │
│  │ 100.96.28.69 │         │ 100.96.171.26    │                  │
│  └──────────────┘         └───────┬──────────┘                  │
│    Any network                    │ School network (10.x.x.x)   │
│    (home, travel, school)         │                              │
└───────────────────────────────────┼─────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
              ┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼──────┐
              │  ka        │  │ compute1  │  │  saturn    │
              │ 10.22.24.2 │  │ RIS HPC   │  │ biostat    │
              │ (gateway)  │  │           │  │            │
              └─────┬──────┘  └───────────┘  └────────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │  ... more cluster nodes
  ┌─────▼───┐ ┌────▼────┐ ┌───▼──────┐
  │ rainier │ │ sequoia │ │ yosemite │
  └─────────┘ └─────────┘ └──────────┘
```

## Machines

### M1 Max (Primary Workstation / Laptop)
- Role: Daily driver, development, Claude Code sessions
- Tailscale IP: 100.96.28.69
- SSH config: ~/.ssh/config (manages all connections)
- SSH key: ~/.ssh/id_rsa (used for all server auth)
- OS: macOS (Ventura)

### M1 Mac Mini (Office Bridge Server)
- Role: Always-on bridge to school network, OpenCLAW gateway host
- Tailscale IP: 100.96.171.26
- School LAN IP: 10.11.33.81 (DHCP, may change)
- User: y.song
- OS: macOS 13.0.1 (Ventura), 8GB RAM, 256GB SSD
- Homebrew: /opt/homebrew (PATH via ~/.zprofile)
- Node.js 22: /opt/homebrew/opt/node@22/bin (PATH via ~/.zshrc)
- OpenCLAW: installed globally via npm, config at ~/.openclaw/.env
- Power: sleep disabled (pmset sleep 0), display sleeps after 10min
- Tailscale: App Store version (not Homebrew CLI)
- Screen Sharing: enabled, accessible via vnc://100.96.171.26

### WashU Research Cluster (via ka gateway)
- Gateway: ka (katmai) at 10.22.24.2, user: ysong
- Cluster nodes (all ProxyJump through ka):
  - rainier, shenandoah, saguaro, sequoia, yosemite
  - yellowstone (alias: ye), congaree, zion, arches, acadia
- All nodes: user ysong, key ~/.ssh/id_rsa

### WashU RIS Compute (direct via macmini)
- compute1-client-1.ris.wustl.edu (alias: c1), user: y.song
- compute1-client-2.ris.wustl.edu (alias: c1.2), user: y.song
- c2-login-001.ris.wustl.edu (alias: c2), user: y.song
- **Duo MFA**: c2 requires Duo two-factor authentication on every SSH login.
  SSH ControlMaster multiplexing is configured on c2 only to avoid repeated Duo prompts.

### Other Servers
- saturn: Saturn.biostat.wusm.wustl.edu, user: y.song (via macmini)
- wrds: wrds-cloud.wharton.upenn.edu, user: yzsong (direct, no proxy)

## SSH Connection Chains

All connections work from ANY network (home, travel, etc.) as long as
Tailscale is running on both M1 Max and Mac Mini.

```
# Direct to Mac Mini (via Tailscale)
ssh macmini
  → Tailscale tunnel → 100.96.171.26

# To ka gateway (via Mac Mini bridge)
ssh ka
  → Tailscale → macmini → 10.22.24.2

# To any cluster node (via Mac Mini → ka)
ssh rainier
  → Tailscale → macmini → ka → rainier

ssh sequoia
  → Tailscale → macmini → ka → sequoia

# To RIS compute (via Mac Mini)
ssh c1
  → Tailscale → macmini → compute1-client-1.ris.wustl.edu

# To saturn (via Mac Mini)
ssh saturn
  → Tailscale → macmini → Saturn.biostat.wusm.wustl.edu

# To WRDS (direct, no proxy needed)
ssh wrds
  → direct → wrds-cloud.wharton.upenn.edu
```

## SSH Config File

Location: ~/.ssh/config on M1 Max
Backup: ~/.ssh/config.backup.2026-02-20

Key routing rules:
- macmini: routes via Tailscale IP (100.96.171.26)
- macmini-local: routes via school LAN IP (10.11.33.81), only works on school network
- ka: ProxyJump through macmini (school-internal IP 10.22.24.2)
- Cluster nodes: ProxyJump through ka
- c1, c1.2, c2, saturn: ProxyJump through macmini (school DNS resolves hostnames)
- wrds: direct connection (external server, no proxy needed)

## Duo MFA + SSH ControlMaster (c2 only)

### The Problem
WashU RIS compute2 (c2) requires Duo two-factor authentication
on every SSH connection. This means:
- Every `ssh c2` triggers a Duo push notification to your phone
- AI tools (Claude Code) that run multiple SSH commands will trigger Duo repeatedly
- Automated scripts become impractical without a workaround
- Note: c1 and c1.2 do NOT require Duo — only c2 does

### The Solution: SSH ControlMaster Multiplexing
The SSH config for c2 includes ControlMaster settings that reuse
a single authenticated connection for all subsequent SSH sessions.

```
Host c2
    HostName c2-login-001.ris.wustl.edu
    User y.song
    IdentityFile ~/.ssh/id_rsa
    ProxyJump macmini
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 4h
```

### How to Use (IMPORTANT for AI sessions)

**Step 1: User opens a persistent connection manually (one-time Duo auth)**
```bash
# Open a connection in the background — approve the Duo push on your phone
ssh -fN c2
```
This authenticates once with Duo and keeps the socket open for 4 hours.

**Step 2: AI/Claude Code can now SSH freely without Duo prompts**
```bash
# All subsequent connections reuse the socket — no Duo prompt
ssh c2 'ls /path/to/data'
ssh c2 'sbatch job.sh'
ssh c2 'squeue -u y.song'
```

**Step 3: Check or close the socket**
```bash
# Check if socket is active
ssh -O check c2

# Close the socket when done
ssh -O exit c2
```

### Socket Details
- Socket directory: ~/.ssh/sockets/
- Socket naming: %r@%h-%p (e.g., y.song@c2-login-001.ris.wustl.edu-22)
- Persist time: 4 hours (ControlPersist 4h) — socket stays open even after
  the foreground session disconnects
- Applies to: c2 only (c1 and c1.2 do not require Duo)

### For AI Sessions: Pre-flight Checklist
Before asking Claude Code or any AI tool to run commands on c2:
1. Run `ssh -fN c2` in a separate terminal
2. Approve the Duo push on your phone
3. Verify with `ssh -O check c2`
4. Now the AI can execute SSH commands to c2 without interruption

## Troubleshooting

### Can't connect to macmini
1. Check Tailscale is running on M1 Max: `tailscale status`
2. Check Mac Mini is online: `tailscale ping 100.96.171.26`
3. Mac Mini may have lost power or Tailscale disconnected
4. Fallback if on school network: `ssh macmini-local`

### Can't connect to cluster nodes
1. Verify macmini bridge works: `ssh macmini`
2. Then verify ka works: `ssh ka`
3. If ka fails, the school network may be blocking internal routing
4. Password prompts mean SSH key isn't set up on that hop

### Tailscale IPs (stable, never change)
- M1 Max: 100.96.28.69
- Mac Mini: 100.96.171.26

### School LAN IPs (DHCP, may change)
- Mac Mini was: 10.11.33.81 (as of 2026-02-20)
- ka gateway: 10.22.24.2 (static)

## OpenCLAW on Mac Mini

- Binary: /opt/homebrew/opt/node@22/bin/openclaw
- Version: 2026.2.19-2
- Config: ~/.openclaw/.env
- Auth: supports ANTHROPIC_OAUTH_TOKEN (checked first) or ANTHROPIC_API_KEY
- Node heap: 2GB (--max-old-space-size=2048, conservative for 8GB RAM)
- Gateway port: 18789 (ws://100.96.171.26:18789 via Tailscale)
- Status: installed, not yet onboarded (needs API key + `openclaw onboard`)

## Future: HP ProDesk 600 G6 SFF

Planned addition to office alongside Mac Mini:
- i5-10500, 32GB RAM, 1TB NVMe
- Will run Ubuntu Server 24.04 LTS (format Windows 11 Pro)
- Primary OpenCLAW host (Mac Mini becomes lightweight bridge)
- Setup script ready at: /Volumes/CrucialX10A/Apps/open_claw/scripts/linux/setup_prodesk_600_g6.sh
- Will also get Tailscale for mesh access

---
*Generated: 2026-02-20 | For AI session context injection*
