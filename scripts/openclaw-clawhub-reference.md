# OpenCLAW & ClawHub Technical Reference

## Table of Contents

1. [Platform Overview](#platform-overview)
2. [Architecture](#architecture)
3. [ClawHub Skill Marketplace](#clawhub-skill-marketplace)
4. [Creating Custom Skills (SKILL.md)](#creating-custom-skills)
5. [Publishing Skills to ClawHub](#publishing-skills-to-clawhub)
6. [Installing Skills (clawhub install)](#installing-skills)
7. [Skills and the Gateway/Channels](#skills-and-the-gatewaychannels)
8. [Skill Development Best Practices](#skill-development-best-practices)
9. [SOUL.md Personality System (onlycrabs.ai)](#soulmd-personality-system)
10. [Browser Automation](#browser-automation)
11. [Canvas / A2UI Visual Workspace](#canvas--a2ui-visual-workspace)
12. [Docker Sandboxing](#docker-sandboxing)
13. [Voice Wake / Talk Mode](#voice-wake--talk-mode)
14. [Security Model](#security-model)
15. [Tailscale / SSH Remote Access](#tailscale--ssh-remote-access)

---

## Platform Overview

OpenCLAW (https://github.com/openclaw/openclaw) is a self-hosted, local-first,
multi-channel AI assistant platform. It runs a WebSocket-based Gateway on your
own hardware and coordinates messaging, tool execution, browser automation, and
agent sessions across multiple surfaces (WhatsApp, Telegram, Slack, Discord,
Signal, iMessage, Matrix, and more).

ClawHub (https://github.com/openclaw/clawhub) is the public skill registry and
marketplace for OpenCLAW. It provides versioned, searchable skill bundles that
extend the agent's capabilities. A companion registry at onlycrabs.ai hosts
SOUL.md personality files.

Runtime requirement: Node >= 22.

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
openclaw gateway --port 18789 --verbose
```

Minimal configuration (`~/.openclaw/openclaw.json`):

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

---

## Architecture

The system centers on a WebSocket Gateway running at `ws://127.0.0.1:18789`.
This control plane manages:

- Session state and routing
- Channel connections (messaging platforms)
- Tool execution and browser automation
- Device node coordination (macOS, iOS, Android)
- Configuration, webhooks, and cron automation

Clients connect to the Gateway: the CLI, web Control UI (Vite + Lit), macOS
menu bar app, iOS/Android nodes, and the Pi agent runtime.

```
 Telegram ─┐                          ┌─ macOS Node (camera, screen, system.run)
 WhatsApp ─┤                          ├─ iOS Node (camera, canvas)
 Discord  ─┤   ┌──────────────────┐   ├─ Android Node (camera, canvas)
 Slack    ─┼──>│  Gateway (WS)    │<──┤
 Signal   ─┤   │  ws://127.0.0.1  │   ├─ CLI (openclaw agent)
 Matrix   ─┤   │  :18789          │   ├─ WebChat / Control UI
 iMessage ─┘   └──────────────────┘   └─ Browser (CDP, managed profile)
                       │
              ┌────────┴────────┐
              │  Agent Runtime  │
              │  (RPC + tools)  │
              └────────┬────────┘
                       │
         ┌─────────────┼─────────────┐
         │             │             │
    Skills (SKILL.md)  SOUL.md    AGENTS.md
```

Workspace structure (`~/.openclaw/workspace`):

```
~/.openclaw/
├── openclaw.json          # Main configuration
├── credentials/           # Channel auth, pairing state
├── devices/               # Node pairing state
├── workspace/
│   ├── AGENTS.md          # Agent definitions
│   ├── SOUL.md            # Personality / behavioral guidelines
│   ├── TOOLS.md           # Available tool documentation
│   └── skills/            # Installed skill modules
│       ├── my-skill/
│       │   └── SKILL.md
│       └── another-skill/
│           └── SKILL.md
└── skills/                # Managed/local skills (~/.openclaw/skills)
```

---

## ClawHub Skill Marketplace

ClawHub (https://clawhub.ai) is the public registry where developers publish,
version, and discover agent skills. Each skill is a versioned bundle of a
`SKILL.md` file plus supporting text files.

### What kinds of skills exist

Skills on ClawHub cover a wide range of agent capabilities:

- **API integrations** -- skills that teach the agent to call external APIs
  (e.g., Gemini image generation, calendar services, database queries)
- **Tool wrappers** -- skills that wrap CLI tools (e.g., `summarize`, `uv`,
  `gemini-cli`) with agent-friendly instructions
- **Automation recipes** -- skills for cron jobs, webhook handling, Gmail
  monitoring, and multi-step workflows
- **Browser automation** -- skills that leverage the managed browser for web
  scraping, form filling, and verification
- **Device integration** -- skills that use node capabilities (camera, screen
  recording, location, notifications)
- **Coding assistants** -- skills for code generation, review, and refactoring
- **Nix plugin bundles** -- skills packaged with CLI binaries and config via Nix

### Technical stack

- Frontend: TanStack Start (React, Vite/Nitro)
- Backend: Convex (database, file storage, HTTP actions) + Convex Auth
- Search: OpenAI embeddings (`text-embedding-3-small`) with Convex vector search
- Auth: GitHub OAuth (accounts must be >= 1 week old to publish)

### Key features

- Vector search via embeddings (not keyword matching)
- Semver versioning with changelogs and tags (including `latest`)
- Stars and comments for community feedback
- Moderation hooks: skills with 3+ unique reports are auto-hidden
- Soft-delete/restore for owners, moderators, and admins
- Nix plugin support for bundling CLI binaries
- Install telemetry (disable with `CLAWHUB_DISABLE_TELEMETRY=1`)

---

## Creating Custom Skills

### Directory structure

Skills live in your workspace. Create a new folder:

```bash
mkdir -p ~/.openclaw/workspace/skills/hello-world
```

### The SKILL.md file

Every skill requires a `SKILL.md` with YAML frontmatter and Markdown
instructions:

```markdown
---
name: hello_world
description: A simple skill that says hello.
---

# Hello World Skill

When the user asks for a greeting, use the `echo` tool to say
"Hello from your custom skill!".
```

### Frontmatter schema

Required fields:

```yaml
---
name: my-skill-name          # Unique identifier (kebab-case or snake_case)
description: Short summary    # One-line description for discovery
---
```

Optional fields:

```yaml
---
name: nano-banana-pro
description: Generate or edit images via Gemini 3 Pro Image
homepage: https://example.com              # URL shown in macOS Skills UI
user-invocable: true                       # Expose as user slash command (default: true)
disable-model-invocation: false            # Exclude from model prompt (default: false)
command-dispatch: tool                     # Bypass model, dispatch directly to a tool
command-tool: my_tool_name                 # Tool to invoke when command-dispatch is set
command-arg-mode: raw                      # Forward raw args to tool (default: raw)
metadata:
  {
    "openclaw":
      {
        "always": false,
        "emoji": "🍌",
        "homepage": "https://example.com",
        "os": ["darwin", "linux"],
        "skillKey": "custom-key",
        "primaryEnv": "GEMINI_API_KEY",
        "requires":
          {
            "bins": ["uv"],
            "anyBins": ["curl", "wget"],
            "env": ["GEMINI_API_KEY"],
            "config": ["browser.enabled"],
          },
        "install":
          [
            {
              "id": "brew",
              "kind": "brew",
              "formula": "gemini-cli",
              "bins": ["gemini"],
              "label": "Install Gemini CLI (brew)",
              "os": ["darwin"],
            },
            {
              "id": "npm",
              "kind": "node",
              "package": "gemini-cli",
              "bins": ["gemini"],
              "label": "Install Gemini CLI (npm)",
            },
          ],
      },
  }
---
```

Important: the `metadata` field must be a single-line JSON object (the embedded
agent parser only supports single-line frontmatter keys).

### Gating (load-time filters)

OpenCLAW filters skills at load time using `metadata.openclaw.requires`:

| Field          | Behavior                                              |
|----------------|-------------------------------------------------------|
| `bins`         | Every listed binary must exist on `PATH`              |
| `anyBins`      | At least one listed binary must exist on `PATH`       |
| `env`          | Env var must exist or be provided in config           |
| `config`       | Listed `openclaw.json` paths must be truthy           |
| `os`           | Skill only eligible on listed platforms               |
| `always: true` | Skip all other gates, always include                  |

### Installer specs

Skills can declare how to install their dependencies:

```yaml
"install": [
  {
    "id": "brew",
    "kind": "brew",           # brew | node | go | uv | download
    "formula": "my-tool",
    "bins": ["my-tool"],
    "label": "Install via Homebrew",
    "os": ["darwin"]
  },
  {
    "id": "download",
    "kind": "download",
    "url": "https://example.com/tool.tar.gz",
    "archive": "tar.gz",
    "extract": true,
    "stripComponents": 1,
    "targetDir": "~/.openclaw/tools/my-tool"
  }
]
```

### Using `{baseDir}` in instructions

Reference the skill folder path in your Markdown body:

```markdown
---
name: my-templates
description: Generate documents from templates
---

# Template Skill

Templates are stored in `{baseDir}/templates/`.
Use `cat {baseDir}/templates/invoice.md` to read the invoice template.
```

### Tool dispatch (direct command routing)

Skills can bypass the model and dispatch directly to a tool:

```markdown
---
name: quick-search
description: Search the web instantly
command-dispatch: tool
command-tool: web_search
command-arg-mode: raw
---
```

When the user types `/quick-search query here`, the tool `web_search` is
invoked with `{ command: "query here", commandName: "quick-search",
skillName: "quick-search" }`.

---

## Publishing Skills to ClawHub

### Prerequisites

1. Install the CLI:

```bash
npm i -g clawhub
```

2. Authenticate (opens browser for GitHub OAuth):

```bash
clawhub login
clawhub whoami    # Verify authentication
```

### Publishing a single skill

```bash
clawhub publish ./my-skill \
  --slug my-skill \
  --name "My Skill" \
  --version 1.0.0 \
  --changelog "Initial release" \
  --tags latest
```

The publish request schema (from `clawhub-schema`):

```typescript
{
  slug: string,           // URL-safe identifier
  displayName: string,    // Human-readable name
  version: string,        // Semver (e.g., "1.0.0")
  changelog: string,      // Release notes
  tags?: string[],        // e.g., ["latest"]
  source?: {              // Optional GitHub provenance
    kind: "github",
    url: string,
    repo: string,
    ref: string,
    commit: string,
    path: string,
    importedAt: number,
  },
  forkOf?: {              // If forked from another skill
    slug: string,
    version?: string,
  },
  files: [{
    path: string,
    size: number,
    storageId: string,
    sha256: string,
    contentType?: string,
  }],
}
```

### Bulk sync (scan + publish)

```bash
clawhub sync --all                    # Upload everything without prompts
clawhub sync --dry-run                # Preview what would be uploaded
clawhub sync --bump minor             # Bump version (patch|minor|major)
clawhub sync --root ~/extra-skills    # Include additional scan roots
```

### Versioning and tags

- Each publish creates a new semver `SkillVersion`
- Tags (like `latest`) point to a version; moving tags enables rollback
- Changelogs are attached per version

### Deleting skills

```bash
clawhub delete my-skill --yes         # Soft-delete (owner/admin)
clawhub undelete my-skill --yes       # Restore
```

### Supported file types in skill bundles

Skills can include text files with these extensions: `.md`, `.mdx`, `.txt`,
`.json`, `.json5`, `.yaml`, `.yml`, `.toml`, `.js`, `.ts`, `.tsx`, `.jsx`,
`.py`, `.sh`, `.rb`, `.go`, `.rs`, `.swift`, `.kt`, `.java`, `.cs`, `.cpp`,
`.c`, `.h`, `.sql`, `.csv`, `.ini`, `.cfg`, `.env`, `.xml`, `.html`, `.css`,
`.scss`, `.svg`, and more.

---

## Installing Skills

### Quick start

```bash
clawhub search "calendar"             # Vector search (not keyword)
clawhub install my-skill              # Install to ./skills/
clawhub install my-skill --version 2.0.0  # Specific version
clawhub list                          # View installed skills
clawhub update --all                  # Update all installed skills
```

### How installation works

1. `clawhub install <slug>` downloads the skill bundle from the registry
2. Files are extracted to `./skills/<slug>/` (or the configured workspace)
3. A lockfile entry is created in `.clawhub/lock.json`:

```json
{
  "version": "1",
  "skills": {
    "my-skill": {
      "version": "1.0.0",
      "installedAt": 1708300000000
    }
  }
}
```

4. Start a new OpenCLAW session to pick up the skill (skills are snapshotted
   at session start)

### Installation directory resolution

1. `--workdir <dir>` flag (highest priority)
2. `CLAWHUB_WORKDIR` environment variable
3. Current working directory
4. Configured OpenCLAW workspace (fallback)

Skills install into `<workdir>/skills/` by default. Override the subdirectory
with `--dir <dir>`.

### Inspecting before installing

```bash
clawhub search "postgres backups"     # Find skills
# Review the skill on clawhub.ai before installing
```

### Update behavior

Updates compare local skill contents to registry versions using a content hash.
If local files don't match any published version, the CLI asks before
overwriting (or requires `--force` in non-interactive mode).

### Environment variables

| Variable                    | Purpose                              |
|-----------------------------|--------------------------------------|
| `CLAWHUB_SITE`              | Override site URL                    |
| `CLAWHUB_REGISTRY`          | Override registry API URL            |
| `CLAWHUB_CONFIG_PATH`       | Override CLI config/token location   |
| `CLAWHUB_WORKDIR`           | Override default workdir             |
| `CLAWHUB_DISABLE_TELEMETRY` | Set to `1` to disable telemetry      |

---

## Skills and the Gateway/Channels

### Skill loading precedence

Skills are loaded from three locations (highest to lowest precedence):

1. **Workspace skills**: `<workspace>/skills/` (user-owned, highest priority)
2. **Managed/local skills**: `~/.openclaw/skills/`
3. **Bundled skills**: shipped with the npm package or OpenClaw.app

Additional directories can be added (lowest precedence):

```json5
{
  skills: {
    load: {
      extraDirs: ["~/Projects/agent-scripts/skills"],
    },
  },
}
```

### How skills interact with channels

When a message arrives on any channel (Telegram, WhatsApp, Slack, etc.):

1. The Gateway routes it to the agent runtime
2. The agent loads the eligible skills snapshot for the session
3. Skills are injected into the system prompt as a compact XML list
4. The model decides which skills to invoke based on the user's request
5. Tool execution happens on the host (or in a Docker sandbox for non-main
   sessions)
6. Results flow back through the Gateway to the originating channel

### Per-agent skills (multi-agent setups)

```json5
{
  agents: {
    list: [
      {
        id: "coder",
        workspace: "~/.openclaw/workspaces/coder",
        // This agent only sees skills in its own workspace
      },
      {
        id: "assistant",
        workspace: "~/.openclaw/workspaces/assistant",
      },
    ],
  },
}
```

- Per-agent skills live in `<workspace>/skills/` for that agent only
- Shared skills in `~/.openclaw/skills/` are visible to all agents
- Workspace skills override managed/bundled on name conflicts

### Config overrides for skills

```json5
{
  skills: {
    entries: {
      "nano-banana-pro": {
        enabled: true,
        apiKey: "GEMINI_KEY_HERE",
        env: {
          GEMINI_API_KEY: "GEMINI_KEY_HERE",
        },
        config: {
          endpoint: "https://example.invalid",
          model: "nano-pro",
        },
      },
      peekaboo: { enabled: true },
      sag: { enabled: false },
    },
    allowBundled: ["gemini", "peekaboo"],  // Allowlist for bundled skills
  },
}
```

### Environment injection lifecycle

1. Agent run starts
2. OpenCLAW reads skill metadata
3. Applies `skills.entries.<key>.env` or `.apiKey` to `process.env`
4. Builds system prompt with eligible skills
5. Restores original environment after the run ends

This is scoped to the agent run, not a global shell environment.

### Skills watcher (hot reload)

```json5
{
  skills: {
    load: {
      watch: true,
      watchDebounceMs: 250,
    },
  },
}
```

Changes to `SKILL.md` files are picked up on the next agent turn without
restarting the Gateway.

### Token impact

When skills are eligible, OpenCLAW injects a compact XML list into the system
prompt:

- Base overhead (when >= 1 skill): 195 characters
- Per skill: 97 characters + length of XML-escaped name, description, location
- Rough estimate: ~24 tokens per skill plus field lengths

### Remote macOS nodes

If the Gateway runs on Linux but a macOS node is connected with `system.run`
allowed, macOS-only skills become eligible. The agent executes them via
`nodes.run` on the remote node.

---

## Skill Development Best Practices

1. **Be concise in SKILL.md instructions.** Tell the model what to do, not how
   to be an AI. The model already knows how to reason; your skill should provide
   domain-specific context and tool usage patterns.

2. **Declare all dependencies.** Use `metadata.openclaw.requires` to gate on
   binaries, env vars, and config. This prevents broken skills from loading.

3. **Use `primaryEnv` for API keys.** This enables the `apiKey` convenience
   field in `skills.entries` config:

   ```yaml
   metadata: {"openclaw": {"primaryEnv": "MY_API_KEY", "requires": {"env": ["MY_API_KEY"]}}}
   ```

4. **Safety first with bash/exec.** If your skill instructs the agent to use
   shell commands, ensure prompts don't allow arbitrary command injection from
   untrusted user input. Consider sandboxed execution for risky operations.

5. **Test locally before publishing.**

   ```bash
   # Place skill in workspace
   mkdir -p ~/.openclaw/workspace/skills/my-skill
   # Edit SKILL.md
   # Test with a direct message
   openclaw agent --message "use my new skill"
   ```

6. **Use `{baseDir}` for file references.** This resolves to the skill's
   directory at runtime, making paths portable.

7. **Keep metadata single-line.** The embedded agent parser only supports
   single-line frontmatter keys. Format `metadata` as a single-line JSON object.

8. **Version semantically.** Use semver when publishing to ClawHub. Attach
   meaningful changelogs so users can audit changes.

9. **Treat third-party skills as untrusted code.** Read them before enabling.
   Prefer sandboxed runs for untrusted inputs.

10. **Mind token costs.** Each eligible skill adds ~24+ tokens to the system
    prompt. Disable unused skills via `skills.entries.<name>.enabled: false`.

---

## SOUL.md Personality System

### What is SOUL.md?

`SOUL.md` is a workspace file (`~/.openclaw/workspace/SOUL.md`) that defines
the agent's personality, behavioral guidelines, and core values. It shapes how
the agent responds and interacts across all sessions and channels.

### Default SOUL.md template

```markdown
# SOUL.md - Who You Are

_You're not a chatbot. You're becoming someone._

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!"
and "I'd be happy to help!" -- just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing
or boring. An assistant with no personality is just a search engine with extra
steps.

**Be resourceful before asking.** Try to figure it out. Read the file. Check the
context. Search for it. _Then_ ask if you're stuck. The goal is to come back
with answers, not questions.

**Earn trust through competence.** Your human gave you access to their stuff.
Don't make them regret it. Be careful with external actions (emails, tweets,
anything public). Be bold with internal ones (reading, organizing, learning).

**Remember you're a guest.** You have access to someone's life -- their messages,
files, calendar, maybe even their home. That's intimacy. Treat it with respect.

## Boundaries

- Private things stay private. Period.
- When in doubt, ask before acting externally.
- Never send half-baked replies to messaging surfaces.
- You're not the user's voice -- be careful in group chats.

## Vibe

Be the assistant you'd actually want to talk to. Concise when needed, thorough
when it matters. Not a corporate drone. Not a sycophant. Just... good.

## Continuity

Each session, you wake up fresh. These files _are_ your memory. Read them.
Update them. They're how you persist.

If you change this file, tell the user -- it's your soul, and they should know.
```

### onlycrabs.ai (the SOUL.md registry)

onlycrabs.ai is the companion registry to ClawHub, focused exclusively on
SOUL.md personality files. It shares the same infrastructure (TanStack Start,
Convex, OpenAI embeddings) but defaults to soul content instead of skills.

- Browse souls at onlycrabs.ai
- On ClawHub, souls are accessible under `/souls`
- Soul bundles currently accept only SOUL.md files (no supporting files yet)
- Same versioning, search, and moderation as ClawHub skills

### How SOUL.md is loaded

The agent runtime reads `SOUL.md` from the workspace root at session start.
It is injected into the system prompt alongside `AGENTS.md` and `TOOLS.md`.
The agent can read and update its own `SOUL.md` -- changes persist across
sessions since the file is the agent's memory.

### Customizing personality

Edit `~/.openclaw/workspace/SOUL.md` directly. The file is yours to evolve.
Common customizations:

- Communication style (formal, casual, terse, verbose)
- Domain expertise emphasis
- Humor and tone preferences
- Boundaries and safety rules
- Language preferences

---

## Browser Automation

OpenCLAW manages a dedicated Chrome/Brave/Edge/Chromium instance via Chrome
DevTools Protocol (CDP). It is isolated from your personal browser.

### Quick start

```bash
openclaw browser --browser-profile openclaw start
openclaw browser --browser-profile openclaw open https://example.com
openclaw browser --browser-profile openclaw snapshot
openclaw browser --browser-profile openclaw status
```

### Profiles

- `openclaw`: managed, isolated browser (no extension required)
- `chrome`: extension relay to your system browser (requires OpenClaw extension)
- Custom profiles: `work`, `remote`, etc.

### Configuration

```json5
{
  browser: {
    enabled: true,
    defaultProfile: "openclaw",
    headless: false,
    color: "#FF4500",
    executablePath: "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    remoteCdpTimeoutMs: 1500,
    remoteCdpHandshakeTimeoutMs: 3000,
    profiles: {
      openclaw: { cdpPort: 18800, color: "#FF4500" },
      work: { cdpPort: 18801, color: "#0066CC" },
      remote: { cdpUrl: "http://10.0.0.42:9222", color: "#00AA00" },
    },
  },
}
```

### Capabilities

- Deterministic tab control (list/open/focus/close by `targetId`)
- Agent actions: click, type, drag, select
- Page snapshots and screenshots
- PDF generation
- Profile management (separate user data directories)
- Multi-profile support with color-coded UI

### Browser selection order

1. Chrome  2. Brave  3. Edge  4. Chromium  5. Chrome Canary

Override with `browser.executablePath`.

### Remote CDP (Browserless)

```json5
{
  browser: {
    enabled: true,
    defaultProfile: "browserless",
    profiles: {
      browserless: {
        cdpUrl: "https://production-sfo.browserless.io?token=<API_KEY>",
        color: "#00AA00",
      },
    },
  },
}
```

### Chrome extension relay

For controlling your existing Chrome tabs:

```bash
openclaw browser extension install
# Chrome -> chrome://extensions -> Developer mode -> Load unpacked
openclaw browser --browser-profile chrome tabs
```

### Sandboxed browser

When sessions are sandboxed, the browser tool defaults to `target="sandbox"`.
Configure sandbox browser behavior:

```json5
{
  agents: {
    defaults: {
      sandbox: {
        browser: {
          autoStart: true,
          autoStartTimeoutMs: 10000,
          allowHostControl: false,
          allowedControlUrls: [],
          allowedControlHosts: [],
          allowedControlPorts: [],
        },
      },
    },
  },
}
```

---

## Canvas / A2UI Visual Workspace

Canvas is an agent-driven visual workspace. A2UI (Agent-to-UI) is the framework
for agent-to-UI interaction that powers it.

### Capabilities

- Agents can push interactive UI state to connected clients
- Reset canvas state
- Evaluate expressions within the canvas context
- Capture snapshots of the current visual state
- Render interactive UIs on iOS/Android/WebChat surfaces

### How it works

The agent uses canvas tools to push HTML/component state to connected clients.
The canvas renders on device nodes (iOS, Android) and in WebChat. This enables
rich visual output beyond text -- charts, forms, interactive widgets, and
custom UIs that the agent can create and manipulate programmatically.

---

## Docker Sandboxing

OpenCLAW can run tools inside Docker containers to limit blast radius. This is
optional and controlled by configuration.

### Modes

```json5
{
  agents: {
    defaults: {
      sandbox: {
        mode: "non-main",    // "off" | "non-main" | "all"
        scope: "session",    // "session" | "agent" | "shared"
        workspaceAccess: "none",  // "none" | "ro" | "rw"
      },
    },
  },
}
```

| Mode       | Behavior                                          |
|------------|---------------------------------------------------|
| `off`      | No sandboxing; tools run on host                  |
| `non-main` | Sandbox only non-main sessions (groups, channels) |
| `all`      | Every session runs in a sandbox                   |

| Scope     | Behavior                                    |
|-----------|---------------------------------------------|
| `session` | One container per session (default)         |
| `agent`   | One container per agent                     |
| `shared`  | One container shared by all sandboxed sessions |

| Workspace Access | Behavior                                        |
|------------------|-------------------------------------------------|
| `none`           | Sandbox workspace under `~/.openclaw/sandboxes` |
| `ro`             | Agent workspace mounted read-only at `/agent`   |
| `rw`             | Agent workspace mounted read/write at `/workspace` |

### What gets sandboxed

- Tool execution: `exec`, `read`, `write`, `edit`, `apply_patch`, `process`
- Optional sandboxed browser

Not sandboxed:
- The Gateway process itself
- Tools explicitly allowed on host via `tools.elevated`

### Building sandbox images

```bash
scripts/sandbox-setup.sh              # Base sandbox image
scripts/sandbox-browser-setup.sh      # Browser sandbox image
```

Default image: `openclaw-sandbox:bookworm-slim`

### Custom bind mounts

```json5
{
  agents: {
    defaults: {
      sandbox: {
        docker: {
          binds: [
            "/home/user/source:/source:ro",
            "/var/data/myapp:/data:ro",
          ],
          network: "none",           // Default: no network
          setupCommand: "apt-get update && apt-get install -y curl",
          env: {
            MY_API_KEY: "secret",    // Sandbox doesn't inherit host env
          },
        },
      },
    },
  },
}
```

### setupCommand

Runs once after container creation (not on every run). Common pitfalls:

- Default network is `"none"` -- package installs need network egress
- `readOnlyRoot: true` prevents writes
- Must run as root for package installs
- Sandbox does not inherit host `process.env`

### Minimal enable example

```json5
{
  agents: {
    defaults: {
      sandbox: {
        mode: "non-main",
        scope: "session",
        workspaceAccess: "none",
      },
    },
  },
}
```

---

## Voice Wake / Talk Mode

OpenCLAW supports always-on speech via text-to-speech (TTS) and voice input.

### TTS providers

| Provider    | API Key Required | Notes                                    |
|-------------|------------------|------------------------------------------|
| ElevenLabs  | Yes              | Primary or fallback; high quality         |
| OpenAI      | Yes              | Primary or fallback; also used for summaries |
| Edge TTS    | No               | Default when no API keys; uses Microsoft endpoints |

### Configuration

TTS is off by default. Enable it:

```json5
{
  messages: {
    tts: {
      auto: "always",          // "always" | "inbound" | off (default)
      provider: "elevenlabs",  // "elevenlabs" | "openai" | "edge"
      maxTextLength: 4000,
      timeoutMs: 30000,
      openai: {
        model: "gpt-4o-mini-tts",
        voice: "alloy",
      },
      elevenlabs: {
        voiceId: "voice_id",
        modelId: "eleven_multilingual_v2",
        voiceSettings: {
          stability: 0.5,
          similarityBoost: 0.75,
          speed: 1.0,
        },
      },
      edge: {
        enabled: true,
        voice: "en-US-MichelleNeural",
        lang: "en-US",
        outputFormat: "audio-24khz-48kbitrate-mono-mp3",
        rate: "+10%",
        pitch: "-5%",
      },
    },
  },
}
```

### Voice Wake

Continuous listening on macOS, iOS, and Android. The device listens for a wake
word or activation, then streams audio to the Gateway for processing.

### Talk Mode

An overlay UI for push-to-talk and continuous conversation. Available on macOS
(menu bar app) and mobile nodes.

### Chat commands

```
/tts always          # Enable auto-TTS
/tts off             # Disable auto-TTS
/tts summary off     # Disable auto-summary for long replies
```

### Audio output

On Telegram, TTS replies appear as round voice-note bubbles. On other channels,
audio is sent as an attachment where supported.

---

## Security Model

### DM pairing (default: on)

By default, unknown senders receive a pairing code and their message is not
processed until approved. This prevents unauthorized access to your assistant.

```bash
openclaw pairing list telegram
openclaw pairing approve telegram <CODE>
```

Pairing codes:
- 8 characters, uppercase, no ambiguous chars (`0O1I`)
- Expire after 1 hour
- Pending requests capped at 3 per channel

### DM policies

| Policy    | Behavior                                              |
|-----------|-------------------------------------------------------|
| `pairing` | Default. Unknown senders get a code; must be approved |
| `open`    | Requires explicit `dmPolicy="open"` and `"*"` in allowlist |

### Node device pairing

Nodes (iOS, Android, macOS) must be explicitly approved:

```bash
openclaw devices list
openclaw devices approve <requestId>
openclaw devices reject <requestId>
```

Telegram-based pairing flow:
1. Message your bot: `/pair`
2. Bot replies with a setup code (base64 JSON with `url` + `token`)
3. Paste into the iOS/Android app
4. Approve: `/pair approve`

### openclaw doctor

Health checks and guided repairs:

```bash
openclaw doctor              # Run health checks
openclaw doctor --repair     # Auto-fix issues (backs up config first)
openclaw doctor --deep       # Deep inspection
```

Surfaces risky DM configurations, connectivity issues, auth problems, and
stale environment overrides.

### Gateway auth

```json5
{
  gateway: {
    auth: {
      mode: "token",                    // "token" | "password"
      token: "auto-generated-or-set",
      allowTailscale: true,             // Accept Tailscale identity headers
    },
  },
}
```

- Auth is required by default (even on loopback, the wizard generates a token)
- Non-loopback binds require explicit token/password
- The Control UI sends anti-clickjacking headers
- Only same-origin WebSocket connections accepted unless `allowedOrigins` is set

### Pairing state storage

```
~/.openclaw/credentials/
├── telegram-pairing.json       # Pending DM requests
├── telegram-allowFrom.json     # Approved senders
├── whatsapp-pairing.json
└── whatsapp-allowFrom.json

~/.openclaw/devices/
├── pending.json                # Pending node requests
└── paired.json                 # Paired devices + tokens
```

### Sandbox security

- Default sandbox network is `"none"` (no egress)
- Dangerous bind sources are blocked (`docker.sock`, `/etc`, `/proc`, `/sys`)
- `tools.elevated` is an explicit escape hatch that runs on host
- Tool allow/deny policies apply before sandbox rules

---

## Tailscale / SSH Remote Access

### Tailscale integration

OpenCLAW auto-configures Tailscale Serve (tailnet-only) or Funnel (public)
while keeping the Gateway bound to loopback.

#### Tailnet-only (Serve) -- recommended

```json5
{
  gateway: {
    bind: "loopback",
    tailscale: { mode: "serve" },
  },
}
```

Access: `https://<magicdns>/`

#### Public internet (Funnel)

```json5
{
  gateway: {
    bind: "loopback",
    tailscale: { mode: "funnel" },
    auth: { mode: "password", password: "replace-me" },
  },
}
```

Funnel requires `auth.mode: "password"` to prevent public exposure without
credentials.

#### Direct tailnet bind

```json5
{
  gateway: {
    bind: "tailnet",
    auth: { mode: "token", token: "your-token" },
  },
}
```

Access: `http://<tailscale-ip>:18789/`

### CLI shortcuts

```bash
openclaw gateway --tailscale serve
openclaw gateway --tailscale funnel --auth password
```

### Tailscale prerequisites

- `tailscale` CLI installed and logged in
- HTTPS enabled for your tailnet (Serve)
- Tailscale v1.38.3+, MagicDNS, HTTPS, funnel node attribute (Funnel)
- Funnel only supports ports 443, 8443, 10000 over TLS
- Funnel on macOS requires the open-source Tailscale app variant

### SSH tunnels

Create a local tunnel to the remote Gateway:

```bash
ssh -N -L 18789:127.0.0.1:18789 user@host
```

With the tunnel up, all CLI commands reach the remote Gateway:

```bash
openclaw health
openclaw status --deep
```

### Persisting remote defaults

```json5
{
  gateway: {
    mode: "remote",
    remote: {
      url: "ws://127.0.0.1:18789",
      token: "your-token",
      tlsFingerprint: "pin-sha256:...",  // Optional TLS cert pinning
    },
  },
}
```

### Common deployment patterns

#### 1. Always-on VPS Gateway + Tailscale

Run the Gateway on a persistent VPS. Reach it via Tailscale Serve or SSH.
Your laptop can sleep; the agent stays responsive 24/7.

#### 2. Home desktop Gateway + remote laptop

The laptop uses the macOS app's "Remote over SSH" mode. The app manages the
tunnel automatically (WebChat + health checks work transparently).

#### 3. Laptop Gateway + remote access

Keep the Gateway local. Expose via Tailscale Serve or SSH tunnel from other
machines.

### Security rules for remote access

- Keep the Gateway loopback-only unless you need a bind
- Loopback + SSH/Tailscale Serve is the safest default
- Non-loopback binds require auth tokens/passwords
- Treat browser control like operator access: tailnet-only + deliberate pairing
- Treat remote CDP URLs/tokens as secrets
- `gateway.remote.token` is only for remote CLI calls, not local auth

---

## Appendix: Chat Commands

Available in any connected channel:

| Command                    | Description                          |
|----------------------------|--------------------------------------|
| `/status`                  | Session info (model, tokens, cost)   |
| `/new` or `/reset`         | Clear session                        |
| `/compact`                 | Compact session history              |
| `/think <level>`           | Adjust reasoning depth               |
| `/verbose on\|off`         | Toggle verbosity                     |
| `/usage`                   | Token usage stats                    |
| `/restart`                 | Restart the Gateway                  |
| `/activation mention\|always` | Group activation mode (groups only) |
| `/tts always\|off`         | Toggle text-to-speech                |

## Appendix: ClawHub CLI Reference

```
clawhub login [--token <token>]       # Authenticate
clawhub logout                        # Sign out
clawhub whoami                        # Check identity
clawhub search "query" [--limit N]    # Vector search
clawhub install <slug> [--version V] [--force]
clawhub update <slug> [--version V] [--force]
clawhub update --all
clawhub list                          # Show installed skills
clawhub publish <path> --slug S --name N --version V [--changelog C] [--tags T]
clawhub delete <slug> --yes
clawhub undelete <slug> --yes
clawhub sync [--all] [--dry-run] [--bump patch|minor|major]
```

## Appendix: Release Channels

| Channel | Description                    | npm dist-tag |
|---------|--------------------------------|--------------|
| stable  | Tagged releases                | `latest`     |
| beta    | Prerelease tags                | `beta`       |
| dev     | Moving head of `main`          | `dev`        |

Switch: `openclaw update --channel stable|beta|dev`




