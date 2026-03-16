# OpenCLAW: The Advanced Claude Code Tutorial

> The most comprehensive guide to Claude Code — from zero to production, including 12+ monetization scenarios.
> Updated: March 2026 | Claude Code v2.1.x | Models: Opus 4.6, Sonnet 4.6, Haiku 4.5

---

## Table of Contents

1. [What Is Claude Code?](#1-what-is-claude-code)
2. [Installation & Setup](#2-installation--setup)
3. [Authentication & Accounts](#3-authentication--accounts)
4. [Core Concepts & Workflows](#4-core-concepts--workflows)
5. [CLAUDE.md — Persistent Instructions](#5-claudemd--persistent-instructions)
6. [Skills — Reusable AI Workflows](#6-skills--reusable-ai-workflows)
7. [Hooks — Deterministic Automation](#7-hooks--deterministic-automation)
8. [MCP Servers — External Tool Integration](#8-mcp-servers--external-tool-integration)
9. [Sub-Agents — Specialized AI Workers](#9-sub-agents--specialized-ai-workers)
10. [Plugins — Package & Distribute](#10-plugins--package--distribute)
11. [GitHub Actions & CI/CD](#11-github-actions--cicd)
12. [Agent SDK — Programmatic Control](#12-agent-sdk--programmatic-control)
13. [Advanced Patterns](#13-advanced-patterns)
14. [Monetization Scenarios](#14-monetization-scenarios--making-money-with-claude-code)
15. [Best Practices Cheat Sheet](#15-best-practices-cheat-sheet)
16. [Sandboxing — OS-Level Security](#16-sandboxing--os-level-security)
17. [Agent Teams — Multi-Agent Coordination](#17-agent-teams--multi-agent-coordination-experimental)
18. [Creating & Distributing Plugins (Deep Dive)](#18-creating--distributing-plugins-deep-dive)
19. [Cross-Surface Workflows](#19-cross-surface-workflows)
20. [Cost Management & Optimization](#20-cost-management--optimization)
21. [Extended Thinking & Effort Levels](#21-extended-thinking--effort-levels)
22. [Common Workflow Recipes](#22-common-workflow-recipes)
23. [Model Configuration & Selection](#23-model-configuration--selection)
24. [Permissions & Security](#24-permissions--security)
25. [Scheduled Tasks & Automation](#25-scheduled-tasks--automation)
26. [Project Rules — Scoped Instructions](#26-project-rules--scoped-instructions)
27. [Auto Memory Deep Dive](#27-auto-memory-deep-dive)
28. [Troubleshooting Guide](#28-troubleshooting-guide)
29. [CLI Reference — Essential Flags](#29-cli-reference--essential-flags)
30. [Status Line — Custom Dashboard](#30-status-line--custom-dashboard)
31. [Checkpointing — Safe Experimentation](#31-checkpointing--safe-experimentation)
32. [Claude Code on the Web — Cloud Execution](#32-claude-code-on-the-web--cloud-execution)
33. [Remote Control — Work From Any Device](#33-remote-control--work-from-any-device)
34. [Chrome Extension — Browser Automation](#34-chrome-extension--browser-automation)
35. [Slack Integration — Team Workflows](#35-slack-integration--team-workflows)
36. [GitLab CI/CD Integration](#36-gitlab-cicd-integration)
37. [Automated Code Review (Teams/Enterprise)](#37-automated-code-review-teamsenterprise)
38. [Enterprise Deployment Guide](#38-enterprise-deployment-guide)
39. [Environment Variables Reference](#39-environment-variables-reference)
40. [Glossary](#40-glossary)
41. [Desktop App — Visual Interface](#41-desktop-app--visual-interface)
42. [VS Code Extension — IDE Integration](#42-vs-code-extension--ide-integration)
43. [JetBrains Integration](#43-jetbrains-integration)
44. [Getting Started Roadmap — By User Type](#44-getting-started-roadmap--by-user-type)
45. [Interactive Mode — Keyboard Mastery](#45-interactive-mode--keyboard-mastery)
46. [Feature Decision Guide — What to Use When](#46-feature-decision-guide--what-to-use-when)
47. [Copy-Paste Recipes — Ready-to-Use Configurations](#47-copy-paste-recipes--ready-to-use-configurations)
48. [Real-World Case Studies](#48-real-world-case-studies)
49. [Advanced Prompt Engineering for Claude Code](#49-advanced-prompt-engineering-for-claude-code)
50. [Security Best Practices](#50-security-best-practices)
51. [Building Custom MCP Servers](#51-building-custom-mcp-servers)
52. [Building with the Agent SDK (Python/TypeScript)](#52-building-with-the-agent-sdk-pythontypescript)
53. [Performance Optimization Guide](#53-performance-optimization-guide)

---

## 1. What Is Claude Code?

Claude Code is Anthropic's agentic coding tool. Unlike a chatbot, it **reads your codebase, edits files, runs commands, and autonomously works through problems**. It's available in:

| Surface | Best For |
|---------|----------|
| **Terminal CLI** | Full-featured development, scripting, CI/CD |
| **VS Code / Cursor** | Inline diffs, @-mentions, plan review |
| **JetBrains** | IntelliJ, PyCharm, WebStorm integration |
| **Desktop App** | Visual diff review, multiple sessions, scheduling |
| **Web (claude.ai/code)** | No local setup, long-running tasks, mobile |
| **Slack** | Route bug reports → pull requests |
| **Chrome Extension** | Debug live web applications |

**Key capabilities:**
- Explore and understand entire codebases
- Build features across multiple files
- Fix bugs by tracing through code
- Create commits, branches, and pull requests
- Connect to external tools via MCP (Jira, Slack, databases, etc.)
- Spawn sub-agent teams for parallel work
- Run in CI/CD for automated code review

---

## 2. Installation & Setup

### 2.1 System Requirements

- **macOS** 13.0+ | **Windows** 10 1809+ | **Ubuntu** 20.04+ | **Debian** 10+ | **Alpine** 3.19+
- 4 GB+ RAM
- Internet connection
- Shell: Bash, Zsh, PowerShell, or CMD

### 2.2 Installation Methods

**Method 1: Native Install (Recommended — auto-updates)**

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Windows CMD
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

**Method 2: Homebrew (macOS/Linux — manual updates)**

```bash
brew install --cask claude-code
# Update: brew upgrade claude-code
```

**Method 3: WinGet (Windows — manual updates)**

```powershell
winget install Anthropic.ClaudeCode
# Update: winget upgrade Anthropic.ClaudeCode
```

**Method 4: npm (Deprecated — use native install)**

```bash
npm install -g @anthropic-ai/claude-code
```

### 2.3 Verify Installation

```bash
claude --version
claude doctor    # Detailed check of installation and configuration
```

### 2.4 Install a Specific Version or Channel

```bash
# Stable channel (one week behind latest, skips regressions)
curl -fsSL https://claude.ai/install.sh | bash -s stable

# Pin a specific version
curl -fsSL https://claude.ai/install.sh | bash -s 1.0.58
```

Configure in `settings.json`:
```json
{ "autoUpdatesChannel": "stable" }
```

### 2.5 Windows-Specific Setup

- **Option A**: Install [Git for Windows](https://git-scm.com/downloads/win), then run the native installer from PowerShell/CMD.
- **Option B**: Use WSL (WSL 2 supports sandboxing for enhanced security).

If Claude can't find Git Bash:
```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

---

## 3. Authentication & Accounts

Claude Code requires a **Pro, Max, Teams, Enterprise, or Console** account. The free Claude.ai plan does not include access.

```bash
# Start Claude and follow browser prompts to log in
claude
```

**Third-party providers** are also supported:
- Amazon Bedrock
- Google Vertex AI
- Microsoft Foundry

---

## 4. Core Concepts & Workflows

### 4.1 The Agentic Loop

Claude Code isn't a chatbot — it's an **agent**. When you give it a task, it:

1. **Reads** relevant files to understand context
2. **Plans** an approach (optionally in Plan Mode)
3. **Implements** changes across multiple files
4. **Verifies** by running tests, linters, or commands
5. **Iterates** until the task is complete

### 4.2 Plan Mode — Explore Before You Code

Separate research from implementation to avoid solving the wrong problem.

```
Ctrl+Shift+P  →  Toggle Plan Mode (read-only exploration)
```

**Recommended 4-phase workflow:**

| Phase | Mode | Example Prompt |
|-------|------|----------------|
| **Explore** | Plan Mode | `read src/auth/ and understand how sessions work` |
| **Plan** | Plan Mode | `I want to add Google OAuth. Create a plan.` |
| **Implement** | Normal Mode | `implement the OAuth flow from your plan` |
| **Commit** | Normal Mode | `commit with a descriptive message and open a PR` |

Press `Ctrl+G` to open the plan in your text editor for direct editing.

### 4.3 Verification — The #1 Best Practice

> **Give Claude a way to verify its work.** This is the single highest-leverage thing you can do.

```
# Bad
"implement email validation"

# Good
"write a validateEmail function. Test cases: user@example.com → true,
invalid → false, user@.com → false. Run the tests after implementing."
```

### 4.4 Context Management

Claude's context window is your most important resource. It fills fast.

| Command | What It Does |
|---------|-------------|
| `/clear` | Reset context between unrelated tasks |
| `/compact` | Summarize conversation to free space |
| `/compact Focus on API changes` | Targeted compaction |
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc + Esc` or `/rewind` | Restore to any previous checkpoint |
| `/btw` | Quick question that doesn't enter history |

**Rules of thumb:**
- `/clear` between unrelated tasks
- After 2 failed corrections → `/clear` and write a better prompt
- Use sub-agents for investigation (keeps main context clean)
- Track context usage with a custom status line

### 4.5 Session Management

```bash
claude --continue       # Resume most recent conversation
claude --resume         # Select from recent sessions
/rename oauth-migration # Name sessions for easy retrieval
```

### 4.6 Providing Rich Context

- **`@filename`** — Reference files directly (Claude reads them)
- **Paste images** — Copy/paste or drag-and-drop screenshots
- **Give URLs** — Documentation and API references
- **Pipe data** — `cat error.log | claude`
- **Let Claude fetch** — "Use `gh issue view 123` to get the details"

---

## 5. CLAUDE.md — Persistent Instructions

CLAUDE.md is a markdown file Claude reads at the start of **every** conversation. It gives Claude persistent context it can't infer from code alone.

### 5.1 Generate a Starter File

```bash
claude
# Then inside Claude Code:
/init
```

This analyzes your codebase and generates a CLAUDE.md with detected build systems, test frameworks, and code patterns.

### 5.2 What to Include vs. Exclude

| ✅ Include | ❌ Exclude |
|-----------|-----------|
| Bash commands Claude can't guess | Anything Claude can figure out from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Branch naming, PR conventions | Information that changes frequently |
| Architectural decisions | File-by-file codebase descriptions |
| Required env vars, dev quirks | Self-evident practices |

### 5.3 Example CLAUDE.md

```markdown
# Code style
- Use ES modules (import/export), not CommonJS (require)
- Destructure imports when possible

# Workflow
- Typecheck after making code changes: `npm run typecheck`
- Run single tests, not the whole suite: `npm test -- --grep "test name"`
- Branch naming: feature/TICKET-description

# Architecture
- API routes in src/routes/, business logic in src/services/
- All DB access through src/db/repository.ts (never raw SQL in routes)
```

### 5.4 File Locations & Hierarchy

| Location | Scope |
|----------|-------|
| `~/.claude/CLAUDE.md` | All sessions (personal) |
| `./CLAUDE.md` | Project root (shared via git) |
| `./subdir/CLAUDE.md` | Loaded on-demand when working in subdir |
| Parent directories | Auto-loaded (great for monorepos) |

Import other files with `@path/to/file`:
```markdown
See @README.md for project overview.
Git workflow: @docs/git-instructions.md
```

### 5.5 Auto Memory

Claude also builds **auto memory** as it works — saving learnings like build commands and debugging insights across sessions without you writing anything. This is stored in `~/.claude/projects/<project>/memory/`.

---

## 6. Skills — Reusable AI Workflows

Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`.

### 6.1 Create Your First Skill

```bash
mkdir -p ~/.claude/skills/explain-code
```

Create `~/.claude/skills/explain-code/SKILL.md`:

```yaml
---
name: explain-code
description: Explains code with visual diagrams and analogies. Use when the user asks "how does this work?"
---

When explaining code, always include:
1. **Analogy**: Compare the code to something from everyday life
2. **Diagram**: Use ASCII art to show flow/structure
3. **Walkthrough**: Step-by-step what happens
4. **Gotcha**: Common mistake or misconception
```

Test it: `/explain-code src/auth/login.ts`

### 6.2 Skill Locations & Scope

| Location | Scope |
|----------|-------|
| `~/.claude/skills/<name>/SKILL.md` | All your projects (personal) |
| `.claude/skills/<name>/SKILL.md` | This project only (shared via git) |
| Plugin's `skills/` directory | Where plugin is enabled |
| Enterprise managed settings | All users in organization |

### 6.3 Skill Directory Structure

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── template.md        # Template for Claude to fill in
├── examples/
│   └── sample.md      # Example output
└── scripts/
    └── validate.sh    # Script Claude can execute
```

### 6.4 Frontmatter Reference

```yaml
---
name: deploy                        # Slash command name
description: Deploy to production   # When Claude should use it
disable-model-invocation: true      # Only manual /deploy (not auto)
user-invocable: false               # Only Claude can invoke (background knowledge)
allowed-tools: Read, Grep, Glob     # Restrict tool access
model: sonnet                       # Model override
context: fork                       # Run in isolated sub-agent
agent: Explore                      # Which sub-agent type
---
```

### 6.5 String Substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed to the skill |
| `$ARGUMENTS[0]`, `$0` | First argument |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing SKILL.md |

### 6.6 Dynamic Context Injection

Run shell commands before the skill content is sent to Claude:

```yaml
---
name: pr-summary
description: Summarize a pull request
context: fork
agent: Explore
---

## PR Context
- Diff: !`gh pr diff`
- Comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

Summarize this pull request.
```

### 6.7 Bundled Skills (Ship with Claude Code)

| Skill | Purpose |
|-------|---------|
| `/batch <instruction>` | Parallel changes across codebase (one agent per unit, each in a worktree) |
| `/claude-api` | Load Claude API reference for your language |
| `/debug [description]` | Troubleshoot current session |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval |
| `/simplify [focus]` | Review changed files for quality, then fix |

### 6.8 Extended Thinking in Skills

Include the word **"ultrathink"** anywhere in your skill content to enable extended thinking mode.

---

## 7. Hooks — Deterministic Automation

Unlike CLAUDE.md instructions (advisory), hooks are **deterministic** — they guarantee the action happens every time.

### 7.1 Hook Types

| Type | How It Works |
|------|-------------|
| **Command** (`type: "command"`) | Run shell scripts, receive JSON on stdin |
| **HTTP** (`type: "http"`) | Send JSON POST to endpoints |
| **Prompt** (`type: "prompt"`) | Send to Claude model for single-turn evaluation |
| **Agent** (`type: "agent"`) | Spawn a sub-agent with tool access to verify conditions |

### 7.2 Hook Events

| Event | When It Fires | Use Case |
|-------|--------------|----------|
| `PreToolUse` | Before a tool executes | Block dangerous commands, auto-approve safe ones |
| `PostToolUse` | After successful tool execution | Run linter after file edits |
| `Stop` | When Claude finishes responding | Force continuation if tasks incomplete |
| `PostToolUseFailure` | When a tool fails | Provide context about errors |
| `PermissionRequest` | When permission dialog appears | Auto-approve/deny on behalf of user |
| `SessionStart` | When session starts | Run setup scripts |
| `SubagentStart/Stop` | When sub-agents start/finish | Setup/cleanup for sub-agent tasks |

### 7.3 Configuration

Hooks live in settings JSON files:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/validate.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

**Settings file locations:**
- `~/.claude/settings.json` — All projects (personal)
- `.claude/settings.json` — This project (shareable)
- `.claude/settings.local.json` — This project (local only)

### 7.4 Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success — process JSON output for decisions |
| `2` | Blocking error — action is prevented, stderr fed to Claude |
| Other | Non-blocking error — execution continues |

### 7.5 Practical Examples

**Block destructive commands:**

```bash
#!/bin/bash
# .claude/hooks/block-destructive.sh
COMMAND=$(jq -r '.tool_input.command')
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive command blocked"
    }
  }'
else
  exit 0
fi
```

**Auto-format after every file edit:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$CLAUDE_PROJECT_DIR/src/**/*.ts\""
          }
        ]
      }
    ]
  }
}
```

**Agent-based verification before stopping:**

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify all tests pass before stopping.",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

### 7.6 Let Claude Write Hooks for You

```
"Write a hook that runs eslint after every file edit"
"Write a hook that blocks writes to the migrations folder"
```

Browse configured hooks: `/hooks`

---

## 8. MCP Servers — External Tool Integration

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open standard for connecting AI tools to external data sources. With MCP, Claude Code can read design docs, update Jira tickets, query databases, pull Slack messages, and more.

### 8.1 Adding MCP Servers

**Remote HTTP server (recommended):**
```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

**Remote SSE server (deprecated — use HTTP):**
```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

**Local stdio server:**
```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

**From JSON configuration:**
```bash
claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp"}'
```

**Import from Claude Desktop:**
```bash
claude mcp add-from-claude-desktop
```

### 8.2 Managing Servers

```bash
claude mcp list              # List all configured servers
claude mcp get github        # Get details for a server
claude mcp remove github     # Remove a server
/mcp                         # Check status inside Claude Code
```

### 8.3 Scopes

| Scope | Storage | Use Case |
|-------|---------|----------|
| **Local** (default) | `~/.claude.json` | Personal, this project only |
| **Project** | `.mcp.json` (git-tracked) | Team-shared |
| **User** | `~/.claude.json` | Personal, all projects |

```bash
claude mcp add --transport http stripe --scope project https://mcp.stripe.com
```

### 8.4 OAuth Authentication

Many cloud MCP servers require OAuth:
```bash
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
# Then inside Claude Code:
/mcp   # Follow browser login flow
```

### 8.5 Popular MCP Servers

| Server | What It Does |
|--------|-------------|
| **GitHub** | PRs, issues, code review |
| **Notion** | Read/write pages and databases |
| **Sentry** | Error monitoring and debugging |
| **Slack** | Read messages, post updates |
| **PostgreSQL** | Query databases naturally |
| **Figma** | Read designs, extract specs |
| **Jira** | Issue tracking, sprint management |
| **Google Drive** | Read docs, sheets, slides |
| **Playwright** | Browser testing and screenshots |

### 8.6 Example Workflows

```
# After connecting Sentry:
"What are the most common errors in the last 24 hours?"

# After connecting GitHub:
"Review PR #456 and suggest improvements"

# After connecting PostgreSQL:
"What's our total revenue this month?"
```

### 8.7 Use Claude Code AS an MCP Server

Other applications can connect to Claude Code:
```bash
claude mcp serve
```

Add to Claude Desktop's config:
```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"]
    }
  }
}
```

### 8.8 MCP Tool Search (Scaling)

When you have many MCP servers, tool definitions can overwhelm context. Claude Code auto-enables **Tool Search** when MCP tools exceed 10% of context — tools are loaded on-demand instead of upfront.

```bash
# Custom threshold
ENABLE_TOOL_SEARCH=auto:5 claude

# Disable entirely
ENABLE_TOOL_SEARCH=false claude
```

---

## 9. Sub-Agents — Specialized AI Workers

Sub-agents are specialized AI assistants that run in their own context window with custom system prompts, specific tool access, and independent permissions. They keep exploration out of your main conversation.

### 9.1 Built-in Sub-Agents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **Explore** | Haiku (fast) | Read-only | File discovery, code search |
| **Plan** | Inherits | Read-only | Codebase research for planning |
| **General-purpose** | Inherits | All | Complex multi-step tasks |

### 9.2 Create a Custom Sub-Agent

**Interactive method:**
```
/agents → Create new agent → User-level → Generate with Claude
```

**Manual method** — create `~/.claude/agents/code-reviewer.md`:

```yaml
---
name: code-reviewer
description: Reviews code for quality and best practices. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer. When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Review for: clarity, duplication, error handling, security, test coverage, performance

Provide feedback by priority:
- **Critical** (must fix)
- **Warnings** (should fix)
- **Suggestions** (consider improving)

Include specific examples of how to fix issues.
```

### 9.3 Sub-Agent Locations

| Location | Scope | Priority |
|----------|-------|----------|
| `--agents` CLI flag | Current session | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All projects | 3 |
| Plugin's `agents/` | Where plugin enabled | 4 (lowest) |

### 9.4 CLI-Defined Sub-Agents (Ephemeral)

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer",
    "prompt": "You are a senior code reviewer. Focus on quality and security.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  },
  "debugger": {
    "description": "Debugging specialist",
    "prompt": "You are an expert debugger. Analyze errors and provide fixes."
  }
}'
```

### 9.5 Advanced Configuration

**Persistent memory** — sub-agents that learn across sessions:
```yaml
---
name: code-reviewer
description: Reviews code for quality
memory: user    # user | project | local
---
```

**Scoped MCP servers** — give sub-agents tools the main conversation doesn't have:
```yaml
---
name: browser-tester
description: Tests features using Playwright
mcpServers:
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  - github    # Reference existing server
---
```

**Git worktree isolation:**
```yaml
---
name: feature-worker
description: Implements features in isolation
isolation: worktree    # Gets its own copy of the repo
---
```

**Permission modes:**

| Mode | Behavior |
|------|----------|
| `default` | Standard permission checking |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny prompts (allowed tools still work) |
| `bypassPermissions` | Skip all checks (use with caution) |
| `plan` | Read-only exploration |

### 9.6 Usage Patterns

```
# Explicit delegation
"Use the code-reviewer sub-agent to review my recent changes"

# Parallel research
"Research auth, database, and API modules in parallel using separate sub-agents"

# Chain sub-agents
"Use code-reviewer to find issues, then use debugger to fix them"

# Background execution
"Run this in the background"    # or press Ctrl+B
```

### 9.7 When to Use Sub-Agents vs. Main Conversation

| Use Main Conversation | Use Sub-Agents |
|----------------------|----------------|
| Frequent back-and-forth | Verbose output you don't need in context |
| Multiple phases sharing context | Enforce specific tool restrictions |
| Quick targeted changes | Self-contained work returning a summary |
| Latency matters | Parallel independent investigations |

---

## 10. Plugins — Package & Distribute

Plugins bundle skills, hooks, sub-agents, and MCP servers into a single installable unit. Browse the marketplace with `/plugin`.

### 10.1 Plugin Structure

```
my-plugin/
├── plugin.json          # Plugin manifest
├── skills/
│   └── my-skill/
│       └── SKILL.md
├── agents/
│   └── my-agent.md
├── hooks/
│   └── hooks.json
├── .mcp.json            # MCP server definitions
└── README.md
```

### 10.2 plugin.json Manifest

```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "version": "1.0.0",
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"]
    }
  }
}
```

### 10.3 Plugin MCP Servers

Plugins can bundle MCP servers that start automatically when the plugin is enabled:

```json
{
  "database-tools": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
    "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
    "env": { "DB_URL": "${DB_URL}" }
  }
}
```

### 10.4 Code Intelligence Plugins

If you work with typed languages, install a code intelligence plugin for precise symbol navigation and automatic error detection after edits.

---

## 11. GitHub Actions & CI/CD

Claude Code GitHub Actions brings AI-powered automation to your GitHub workflow. Mention `@claude` in any PR or issue, and Claude analyzes code, creates PRs, implements features, and fixes bugs.

### 11.1 Quick Setup

```bash
# Inside Claude Code:
/install-github-app
```

This guides you through installing the GitHub app and setting up secrets. You must be a repo admin.

### 11.2 Manual Setup

1. Install the Claude GitHub app: [github.com/apps/claude](https://github.com/apps/claude)
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy the workflow file into `.github/workflows/`

### 11.3 Basic Workflow

```yaml
# .github/workflows/claude.yml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          # Responds to @claude mentions in comments
```

### 11.4 Automated Code Review on Every PR

```yaml
name: Code Review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Review this PR for code quality, correctness, and security."
          claude_args: "--max-turns 5"
```

### 11.5 Scheduled Automation

```yaml
name: Daily Report
on:
  schedule:
    - cron: "0 9 * * *"
jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Generate a summary of yesterday's commits and open issues"
          claude_args: "--model claude-opus-4-6"
```

### 11.6 Using with AWS Bedrock / Google Vertex AI

For enterprise environments, use your own cloud infrastructure:

```yaml
# AWS Bedrock example
- uses: anthropics/claude-code-action@v1
  with:
    github_token: ${{ steps.app-token.outputs.token }}
    use_bedrock: "true"
    claude_args: '--model us.anthropic.claude-sonnet-4-6 --max-turns 10'
```

### 11.7 Common @claude Commands in PRs/Issues

```
@claude implement this feature based on the issue description
@claude fix the TypeError in the user dashboard component
@claude how should I implement user authentication for this endpoint?
```

---

## 12. Agent SDK — Programmatic Control

The Agent SDK gives you the same tools, agent loop, and context management that power Claude Code — available as a CLI, Python package, or TypeScript package.

### 12.1 CLI Usage (Non-Interactive Mode)

```bash
# One-off query
claude -p "Explain what this project does"

# Structured JSON output
claude -p "List all API endpoints" --output-format json

# Streaming for real-time processing
claude -p "Analyze this log file" --output-format stream-json

# Auto-approve specific tools
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"

# Custom system prompt
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

### 12.2 Structured Output with JSON Schema

```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

### 12.3 Continuing Conversations

```bash
# First request
claude -p "Review this codebase for performance issues"

# Continue the same conversation
claude -p "Now focus on database queries" --continue

# Resume a specific session
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### 12.4 Fan-Out Pattern (Parallel Processing)

```bash
# Generate a task list
claude -p "List all Python files needing migration" > files.txt

# Process each file in parallel
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)" &
done
wait
```

### 12.5 Pipeline Integration

```bash
# Pipe into other tools
claude -p "List security issues" --output-format json | jq '.result'

# Pipe data into Claude
cat error.log | claude -p "Summarize the errors and suggest fixes"
git diff main --name-only | claude -p "Review these changed files for security issues"

# Monitor logs
tail -f app.log | claude -p "Slack me if you see any anomalies"
```

### 12.6 Python & TypeScript SDKs

For full programmatic control with structured outputs, tool approval callbacks, and native message objects, see the [Agent SDK documentation](https://platform.claude.com/docs/en/agent-sdk/overview).

---

## 13. Advanced Patterns

### 13.1 Writer/Reviewer Pattern

Run two sessions — one writes code, the other reviews it with fresh context:

| Session A (Writer) | Session B (Reviewer) |
|---|---|
| `Implement a rate limiter for our API` | |
| | `Review the rate limiter in @src/middleware/rateLimiter.ts. Look for edge cases and race conditions.` |
| `Address this review feedback: [paste]` | |

### 13.2 Test-First Pattern

Have one Claude write tests, then another write code to pass them:

```bash
# Session 1: Write tests
claude -p "Write comprehensive tests for a URL shortener service"

# Session 2: Implement to pass tests
claude -p "Implement the URL shortener to pass all tests in tests/shortener.test.ts"
```

### 13.3 Interview-Driven Development

For larger features, have Claude interview you first:

```
I want to build [brief description]. Interview me in detail using the
AskUserQuestion tool.

Ask about technical implementation, UI/UX, edge cases, concerns, and
tradeoffs. Don't ask obvious questions — dig into the hard parts.

Keep interviewing until we've covered everything, then write a complete
spec to SPEC.md.
```

Then start a fresh session to execute the spec.

### 13.4 The /batch Skill — Massive Parallel Changes

```
/batch migrate all React class components in src/ to functional components with hooks
```

This skill:
1. Researches the codebase
2. Decomposes work into 5-30 independent units
3. Presents a plan for approval
4. Spawns one background agent per unit (each in an isolated git worktree)
5. Each agent implements, tests, and opens a PR

### 13.5 Remote Control & Cross-Device Workflows

- **Remote Control**: Step away from your desk, continue from your phone
- **Web → Terminal**: Start a task on claude.ai/code, pull it into terminal with `/teleport`
- **Terminal → Desktop**: Hand off with `/desktop` for visual diff review
- **Slack → PR**: Mention `@Claude` in Slack with a bug report, get a PR back

### 13.6 Git Worktrees for Isolation

Run parallel Claude sessions without conflicts:

```bash
# Claude creates isolated worktrees automatically when using /batch
# Or manually:
git worktree add .claude/worktrees/feature-auth -b feature/auth
cd .claude/worktrees/feature-auth && claude
```

### 13.7 Custom Status Line

Track context usage continuously:

```
/statusline
```

Configure to show token count, model, session name, and more.

---

## 14. Monetization Scenarios — Making Money with Claude Code

Claude Code isn't just a productivity tool — it's a force multiplier that enables entirely new business models. Here are 12+ proven scenarios for generating revenue.

### Scenario 1: Freelance Development Agency (10x Output)

**The play**: One developer + Claude Code = output of a small team.

```bash
# Accept a client project, use Claude to implement features rapidly
claude -p "Implement the user dashboard with charts, filters, and export to CSV.
Follow the design in @designs/dashboard.png. Write tests for all components."
```

**Revenue model**: Charge project-based rates. Deliver in days what used to take weeks.
**Realistic income**: $10K–$50K/month as a solo developer handling 3-5x more clients.

### Scenario 2: Automated Code Review Service

**The play**: Offer AI-powered code review as a service using GitHub Actions.

```yaml
# .github/workflows/review-service.yml
name: AI Code Review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Review this PR for:
            - Security vulnerabilities (OWASP Top 10)
            - Performance bottlenecks
            - Code quality and maintainability
            - Test coverage gaps
            Provide actionable feedback with code examples.
          claude_args: "--model claude-opus-4-6 --max-turns 10"
```

**Revenue model**: SaaS subscription — $49/month per repo (small), $199/month (enterprise).
**Target market**: Teams without dedicated security reviewers.

### Scenario 3: Legacy Code Migration Service

**The play**: Migrate legacy codebases using the `/batch` skill.

```
/batch migrate all jQuery code in src/ to modern vanilla JavaScript ES2024
/batch convert all Python 2 files to Python 3.12 with type hints
/batch migrate all class components to React hooks with TypeScript
```

**Revenue model**: Fixed-price migration contracts. $5K–$100K per project depending on codebase size.
**Why it works**: Migration is tedious, high-value work that most teams avoid. Claude handles the tedium.

### Scenario 4: Custom Plugin & Skill Marketplace

**The play**: Build and sell Claude Code plugins for specific industries.

```
my-plugin/
├── plugin.json
├── skills/
│   ├── hipaa-compliance/SKILL.md    # Healthcare compliance checks
│   ├── sox-audit/SKILL.md           # Financial audit automation
│   └── gdpr-review/SKILL.md        # GDPR compliance review
├── agents/
│   └── compliance-reviewer.md
└── hooks/
    └── hooks.json                    # Block non-compliant patterns
```

**Revenue model**: Plugin licenses — $99–$499/month per team.
**Target market**: Regulated industries (healthcare, finance, government).

### Scenario 5: AI-Powered Documentation Service

**The play**: Generate and maintain documentation automatically.

```bash
# Generate API docs from code
claude -p "Analyze all API endpoints in src/routes/ and generate
comprehensive OpenAPI 3.0 documentation with examples" \
  --allowedTools "Read,Grep,Glob,Write"

# Keep docs in sync with CI
claude -p "Compare the current API code with docs/api.yaml.
List any endpoints that are missing or outdated. Update the docs." \
  --allowedTools "Read,Grep,Edit"
```

**Revenue model**: Monthly retainer ($2K–$10K/month) for keeping docs current.
**Target market**: API-first companies, developer platforms.

### Scenario 6: Automated Bug Bounty Hunting

**The play**: Use Claude Code to scan open-source projects for security vulnerabilities.

```bash
claude -p "Analyze this codebase for security vulnerabilities:
- SQL injection
- XSS
- Authentication bypasses
- Insecure deserialization
- Path traversal
Report findings with severity, location, and proof of concept." \
  --allowedTools "Read,Grep,Glob,Bash"
```

**Revenue model**: Bug bounty payouts ($500–$50K per vulnerability).
**Platforms**: HackerOne, Bugcrowd, GitHub Security Advisories.

### Scenario 7: Rapid MVP Development Studio

**The play**: Build MVPs for startups in days instead of months.

```
# Day 1: Spec
"Interview me about my startup idea using AskUserQuestion. Cover
technical architecture, user flows, data model, and MVP scope.
Write the spec to SPEC.md."

# Day 2-3: Build
"Implement the MVP from SPEC.md. Use Next.js, Prisma, PostgreSQL.
Write tests. Deploy to Vercel."

# Day 4: Polish
"Review the entire codebase. Fix any issues. Add error handling,
loading states, and mobile responsiveness."
```

**Revenue model**: $5K–$25K per MVP. 2-4 MVPs per month.
**Target market**: Pre-seed and seed-stage startups.

### Scenario 8: DevOps & Infrastructure Automation

**The play**: Automate infrastructure management with Claude + MCP.

```bash
# Connect to cloud providers
claude mcp add --transport http aws-mcp https://mcp.aws.example.com
claude mcp add --transport http gcp-mcp https://mcp.gcp.example.com

# Automate infrastructure tasks
claude -p "Analyze our AWS infrastructure for cost optimization.
Identify unused resources, oversized instances, and savings opportunities.
Generate a Terraform plan to implement the changes."
```

**Revenue model**: Managed services ($3K–$15K/month per client).
**Value prop**: Reduce cloud bills by 30-60% with AI-driven optimization.

### Scenario 9: Test Suite Generation Service

**The play**: Add comprehensive test coverage to untested codebases.

```bash
# Analyze coverage gaps
claude -p "Analyze test coverage for src/. Identify untested functions,
edge cases, and critical paths. Generate a prioritized testing plan."

# Generate tests in parallel
for module in auth payments users notifications; do
  claude -p "Write comprehensive tests for src/$module/.
  Cover happy paths, edge cases, error handling, and integration.
  Run tests and fix any failures." \
    --allowedTools "Read,Write,Edit,Bash" &
done
wait
```

**Revenue model**: Per-project ($2K–$20K) or retainer for ongoing coverage.
**Target market**: Companies preparing for SOC 2, ISO 27001, or acquisition due diligence.

### Scenario 10: AI-Powered Technical Consulting

**The play**: Use Claude Code to analyze client codebases and deliver expert recommendations.

```bash
# Architecture review
claude -p "Analyze this codebase architecture. Evaluate:
- Scalability bottlenecks
- Security vulnerabilities
- Performance issues
- Code quality metrics
- Dependency health
Generate a detailed report with prioritized recommendations."

# Generate the report
claude -p "Create a professional PDF report from the analysis.
Include executive summary, findings, risk matrix, and action items."
```

**Revenue model**: $5K–$25K per audit. Ongoing advisory at $2K–$10K/month.
**Target market**: Series A+ startups, enterprises modernizing legacy systems.

### Scenario 11: Course & Training Content Creation

**The play**: Create and sell technical courses, using Claude Code to generate examples, exercises, and projects.

```bash
# Generate course content
claude -p "Create a complete course outline for 'Building Production
APIs with Node.js'. Include 12 modules, each with:
- Learning objectives
- Code examples (working, tested)
- Exercises with solutions
- Common mistakes to avoid"

# Generate working project templates
claude -p "Create a starter project for Module 3: Authentication.
Include JWT setup, middleware, tests, and a README with instructions."
```

**Revenue model**: Course sales ($49–$499), cohort-based ($999–$2999), corporate training ($5K–$25K/day).
**Platforms**: Udemy, Teachable, own website.

### Scenario 12: Internal Tooling & Workflow Automation

**The play**: Build custom internal tools for companies using Claude Code + MCP + Skills.

```yaml
# Custom skill for client's workflow
---
name: deploy-staging
description: Deploy to staging with all checks
disable-model-invocation: true
---

Deploy to staging:
1. Run full test suite: !`npm test`
2. Check for security vulnerabilities: !`npm audit`
3. Build the application: !`npm run build`
4. Deploy to staging: !`./scripts/deploy-staging.sh`
5. Run smoke tests against staging
6. Post results to Slack channel #deployments
```

**Revenue model**: Custom tool development ($10K–$50K), maintenance retainer ($2K–$5K/month).
**Target market**: Mid-size companies with repetitive workflows.

### Monetization Summary

| Scenario | Revenue Range | Effort to Start | Scalability |
|----------|--------------|-----------------|-------------|
| Freelance Agency | $10K–$50K/mo | Low | Medium |
| Code Review SaaS | $5K–$100K/mo | Medium | High |
| Legacy Migration | $5K–$100K/project | Low | Medium |
| Plugin Marketplace | $5K–$50K/mo | High | Very High |
| Documentation Service | $2K–$10K/mo | Low | Medium |
| Bug Bounty | $500–$50K/vuln | Low | Low |
| MVP Studio | $10K–$100K/mo | Low | Medium |
| DevOps Automation | $3K–$15K/mo/client | Medium | High |
| Test Generation | $2K–$20K/project | Low | Medium |
| Technical Consulting | $5K–$25K/audit | Low | Medium |
| Course Creation | $5K–$50K/course | Medium | Very High |
| Internal Tooling | $10K–$50K/project | Medium | High |

---

## 15. Best Practices Cheat Sheet

### Do This

| Practice | Why |
|----------|-----|
| **Give Claude verification** (tests, linters, screenshots) | Single highest-leverage thing you can do |
| **Explore → Plan → Implement → Commit** | Avoid solving the wrong problem |
| **`/clear` between unrelated tasks** | Prevent context pollution |
| **Use sub-agents for investigation** | Keep main context clean |
| **Reference specific files with `@`** | Reduce ambiguity |
| **Write a concise CLAUDE.md** | Persistent context Claude can't infer |
| **Use hooks for must-happen actions** | Deterministic, not advisory |
| **Use skills for reusable workflows** | Don't repeat yourself |
| **Connect MCP servers for external tools** | Let Claude access your full toolchain |
| **Course-correct early** (`Esc`, `/rewind`) | Tight feedback loops = better results |

### Don't Do This

| Anti-Pattern | Fix |
|-------------|-----|
| **Kitchen sink session** (mixing unrelated tasks) | `/clear` between tasks |
| **Correcting over and over** (>2 failed corrections) | `/clear` + better initial prompt |
| **Over-specified CLAUDE.md** (too long, rules get lost) | Prune ruthlessly — if Claude does it right without the rule, delete it |
| **Trust-then-verify gap** (no tests or checks) | Always provide verification criteria |
| **Infinite exploration** (unscoped investigation) | Scope narrowly or use sub-agents |
| **Vague prompts for specific tasks** | Include files, constraints, examples |

### Prompt Engineering Quick Reference

```
# Bad
"add tests for foo.py"

# Good
"write a test for foo.py covering the edge case where the user is logged out.
avoid mocks. run the tests after implementing."

# Bad
"fix the login bug"

# Good
"users report login fails after session timeout. check the auth flow in
src/auth/, especially token refresh. write a failing test that reproduces
the issue, then fix it."

# Bad
"add a calendar widget"

# Good
"look at how existing widgets are implemented on the home page.
HotDogWidget.php is a good example. follow the pattern to implement
a new calendar widget with month selection and year pagination.
build from scratch without extra libraries."
```

### Essential Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Esc` | Stop Claude mid-action |
| `Esc + Esc` | Open rewind menu |
| `Ctrl+Shift+P` | Toggle Plan Mode |
| `Ctrl+G` | Open plan in editor |
| `Ctrl+B` | Background a running task |
| `/clear` | Reset context |
| `/compact` | Summarize to free space |
| `/btw` | Quick question (doesn't enter history) |
| `/hooks` | Browse configured hooks |
| `/mcp` | Check MCP server status |
| `/agents` | Manage sub-agents |
| `/plugin` | Browse plugin marketplace |

---

## Appendix: Quick Reference Card

### Installation
```bash
curl -fsSL https://claude.ai/install.sh | bash
claude
```

### Essential CLI Flags
```bash
claude                          # Interactive mode
claude -p "prompt"              # Non-interactive (headless)
claude -p "prompt" --continue   # Continue last conversation
claude --resume                 # Pick a session to resume
claude -p "prompt" --output-format json  # JSON output
claude -p "prompt" --allowedTools "Read,Edit,Bash"  # Auto-approve tools
claude --model claude-opus-4-6  # Use Opus
claude --dangerously-skip-permissions  # Bypass all checks (sandbox only!)
```

### MCP Quick Setup
```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
claude mcp list
/mcp  # Authenticate inside Claude Code
```

### Skill Quick Setup
```bash
mkdir -p .claude/skills/my-skill
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What this skill does and when to use it
---
Your instructions here. Use $ARGUMENTS for passed arguments.
EOF
```

### Sub-Agent Quick Setup
```bash
cat > .claude/agents/reviewer.md << 'EOF'
---
name: reviewer
description: Reviews code for quality. Use proactively after changes.
tools: Read, Grep, Glob, Bash
model: sonnet
---
You are a senior code reviewer. Focus on quality, security, and best practices.
EOF
```

### Hook Quick Setup
```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{ "type": "command", "command": "npx prettier --write ." }]
    }]
  }
}
```

---

## 16. Sandboxing — OS-Level Security

Sandboxing creates defined boundaries where Claude Code can work freely with reduced risk, using OS-level primitives for filesystem and network isolation.

### 16.1 Why Sandboxing?

| Problem | Solution |
|---------|----------|
| Approval fatigue (clicking "approve" repeatedly) | Safe commands auto-approved inside sandbox |
| Prompt injection risk | OS-level enforcement blocks unauthorized access |
| Malicious dependencies | Child processes inherit sandbox restrictions |

### 16.2 Enable Sandboxing

```
/sandbox
```

**Two modes:**
- **Auto-allow**: Sandboxed commands run without permission prompts. Non-sandboxable commands fall back to normal flow.
- **Regular permissions**: All commands go through standard approval, but sandbox still enforces filesystem/network restrictions.

### 16.3 How It Works

**Filesystem isolation:**
- Read/write access to current working directory (default)
- Blocked from modifying files outside the project
- Configurable allowed/denied paths
- Enforced via Seatbelt (macOS) or bubblewrap (Linux/WSL2)

**Network isolation:**
- Only approved domains accessible
- New domain requests trigger permission prompts
- All subprocesses inherit restrictions

### 16.4 Configuration

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "//tmp/build"]
    }
  }
}
```

**Path prefixes:**
| Prefix | Meaning | Example |
|--------|---------|---------|
| `//` | Absolute from root | `//tmp/build` → `/tmp/build` |
| `~/` | Home directory | `~/.kube` → `$HOME/.kube` |
| `/` | Relative to settings file | `/build` → `$SETTINGS_DIR/build` |

### 16.5 Protection Against Prompt Injection

Even if an attacker manipulates Claude's behavior:
- Cannot modify `~/.bashrc`, `/bin/`, or system files
- Cannot exfiltrate data to unauthorized servers
- Cannot download malicious scripts
- All violations blocked at OS level with immediate notification

### 16.6 Open Source Sandbox Runtime

The sandbox is available as an npm package for your own agent projects:
```bash
npx @anthropic-ai/sandbox-runtime <command-to-sandbox>
```

---

## 17. Agent Teams — Multi-Agent Coordination (Experimental)

> ⚠️ Agent teams are experimental. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.

Agent teams let you coordinate multiple Claude Code instances working together. One session acts as team lead, coordinating work and synthesizing results. Teammates work independently, each in its own context window, and communicate directly with each other.

### 17.1 When to Use Agent Teams vs. Sub-Agents

| | Sub-Agents | Agent Teams |
|---|---|---|
| **Context** | Own window; results return to caller | Own window; fully independent |
| **Communication** | Report back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion |
| **Token cost** | Lower | Higher (each teammate = separate instance) |

### 17.2 Start a Team

```
I'm designing a CLI tool for tracking TODOs. Create an agent team:
- One teammate on UX
- One on technical architecture
- One playing devil's advocate
```

Claude creates the team, spawns teammates, and coordinates work.

### 17.3 Display Modes

- **In-process** (default): All teammates in your terminal. `Shift+Down` to cycle between them.
- **Split panes**: Each teammate gets its own pane (requires tmux or iTerm2).

```json
{ "teammateMode": "in-process" }
```

### 17.4 Team Architecture

| Component | Role |
|-----------|------|
| **Team lead** | Creates team, spawns teammates, coordinates |
| **Teammates** | Separate Claude instances working on tasks |
| **Task list** | Shared work items teammates claim and complete |
| **Mailbox** | Messaging system between agents |

### 17.5 Use Case: Parallel Code Review

```
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

### 17.6 Use Case: Competing Hypotheses Debugging

```
Users report the app exits after one message. Spawn 5 teammates to
investigate different hypotheses. Have them debate and try to disprove
each other's theories. Update findings with whatever consensus emerges.
```

### 17.7 Quality Gates with Hooks

```json
{
  "hooks": {
    "TaskCompleted": [{
      "hooks": [{
        "type": "command",
        "command": "./scripts/verify-task.sh"
      }]
    }]
  }
}
```

Exit code 2 prevents task completion and sends feedback.

### 17.8 Best Practices

- Start with 3-5 teammates (diminishing returns beyond that)
- 5-6 tasks per teammate keeps everyone productive
- Break work so each teammate owns different files (avoid conflicts)
- Start with research/review tasks before parallel implementation
- Monitor and steer — don't let teams run unattended too long

---

## 18. Creating & Distributing Plugins (Deep Dive)

Plugins bundle skills, hooks, sub-agents, MCP servers, and LSP servers into a single installable unit.

### 18.1 Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # Manifest (ONLY this goes here)
├── skills/                 # Agent Skills with SKILL.md
│   └── code-review/
│       └── SKILL.md
├── commands/               # Slash commands as Markdown
│   └── deploy.md
├── agents/                 # Custom sub-agent definitions
│   └── security-reviewer.md
├── hooks/
│   └── hooks.json          # Event handlers
├── .mcp.json               # MCP server configurations
├── .lsp.json               # LSP server configurations
├── settings.json           # Default settings when plugin enabled
└── README.md
```

### 18.2 Create a Plugin Step-by-Step

```bash
# 1. Create structure
mkdir -p my-plugin/.claude-plugin
mkdir -p my-plugin/skills/code-review

# 2. Create manifest
cat > my-plugin/.claude-plugin/plugin.json << 'EOF'
{
  "name": "my-plugin",
  "description": "Code quality tools for teams",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
EOF

# 3. Add a skill
cat > my-plugin/skills/code-review/SKILL.md << 'EOF'
---
name: code-review
description: Reviews code for best practices and security issues
---
When reviewing code, check for:
1. Code organization and structure
2. Error handling and edge cases
3. Security concerns (OWASP Top 10)
4. Test coverage gaps
EOF

# 4. Test locally
claude --plugin-dir ./my-plugin
# Then: /my-plugin:code-review
```

### 18.3 Add LSP Servers (Code Intelligence)

```json
// .lsp.json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

### 18.4 Ship Default Settings

```json
// settings.json — activates a custom agent as main thread
{ "agent": "security-reviewer" }
```

### 18.5 Standalone vs. Plugin

| Standalone (`.claude/`) | Plugin |
|---|---|
| `/hello` (short names) | `/plugin-name:hello` (namespaced) |
| One project only | Shareable via marketplaces |
| Quick experiments | Versioned releases |

### 18.6 Convert Standalone to Plugin

```bash
mkdir -p my-plugin/.claude-plugin
# Create plugin.json manifest
cp -r .claude/commands my-plugin/
cp -r .claude/agents my-plugin/
cp -r .claude/skills my-plugin/
# Test: claude --plugin-dir ./my-plugin
```

### 18.7 Distribute Your Plugin

1. Push to a GitHub repo
2. Create a marketplace or use the official one
3. Submit at [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
4. Users install with `/plugin install`

---

## 19. Cross-Surface Workflows

Claude Code works across every surface — and sessions aren't tied to one.

### 19.1 Surface Comparison

| Surface | Strengths | Best For |
|---------|-----------|----------|
| **Terminal CLI** | Full power, scripting, CI/CD | Daily development |
| **VS Code / Cursor** | Inline diffs, @-mentions | IDE-centric workflows |
| **JetBrains** | IntelliJ, PyCharm, WebStorm | Java/Python/Web dev |
| **Desktop App** | Visual diffs, multi-session, scheduling | Review & management |
| **Web** | No setup, long-running, mobile | Remote work, parallel tasks |
| **Slack** | Team integration | Bug reports → PRs |
| **Chrome** | Live web debugging | Frontend testing |

### 19.2 Handoff Patterns

```bash
# Terminal → Desktop (visual diff review)
/desktop

# Web → Terminal (pull cloud session locally)
/teleport

# Any device → Phone (continue from mobile)
# Use Remote Control feature

# Slack → PR (team workflow)
# @Claude in Slack: "Fix the login bug described in issue #42"
```

### 19.3 Multi-Session Strategies

| Strategy | How |
|----------|-----|
| **Writer/Reviewer** | Session A writes code, Session B reviews with fresh context |
| **Test-First** | Session A writes tests, Session B implements to pass them |
| **Parallel Research** | Multiple sessions investigate different aspects |
| **Desktop App** | Manage multiple local sessions visually |
| **Web Sessions** | Run on Anthropic's cloud in isolated VMs |
| **Agent Teams** | Automated coordination with shared tasks |

---

## 20. Cost Management & Optimization

Average cost: ~$6/developer/day (90th percentile under $12/day). ~$100-200/developer/month with Sonnet 4.6.

### 20.1 Track Costs

```
/cost     # API token usage for current session (API users)
/stats    # Usage patterns (Pro/Max subscribers)
```

### 20.2 Reduce Token Usage

| Strategy | How | Impact |
|----------|-----|--------|
| **Clear between tasks** | `/clear` when switching work | High |
| **Use the right model** | Sonnet for most tasks, Opus for complex reasoning | High |
| **Compact with focus** | `/compact Focus on API changes` | Medium |
| **Disable unused MCP servers** | `/mcp` → disable idle servers | Medium |
| **Install code intelligence plugins** | Precise navigation vs. grep+read | Medium |
| **Use sub-agents for verbose ops** | Tests, logs, docs stay in sub-agent context | Medium |
| **Move CLAUDE.md instructions to skills** | Skills load on-demand, not every session | Medium |
| **Write specific prompts** | "Fix auth.ts line 42" vs. "improve the codebase" | High |
| **Use plan mode first** | Prevents expensive re-work | High |
| **Adjust extended thinking** | `/effort` or `MAX_THINKING_TOKENS=8000` | Medium |

### 20.3 Team Rate Limits (TPM per user)

| Team Size | TPM/User | RPM/User |
|-----------|----------|----------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

### 20.4 Cost-Saving Hook Example

Filter test output to show only failures (saves thousands of tokens):

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/filter-test-output.sh"
      }]
    }]
  }
}
```

---

## 21. Extended Thinking & Effort Levels

Extended thinking gives Claude space to reason through complex problems step-by-step before responding.

### 21.1 Configure Thinking

| Method | How |
|--------|-----|
| **Effort level** | `/effort` or `/model` menu |
| **ultrathink keyword** | Include "ultrathink" in your prompt for one-off deep reasoning |
| **Toggle shortcut** | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| **Global default** | `/config` → toggle thinking mode |
| **Token budget** | `MAX_THINKING_TOKENS=10000` environment variable |

### 21.2 When to Use Extended Thinking

- Complex architectural decisions
- Challenging multi-step bugs
- Implementation planning across many files
- Evaluating tradeoffs between approaches

### 21.3 Adaptive Reasoning (Opus 4.6 / Sonnet 4.6)

These models dynamically allocate thinking tokens based on your effort level — no fixed budget needed. Set effort with `/effort` or `CLAUDE_CODE_EFFORT_LEVEL` env var.

---

## 22. Common Workflow Recipes

### 22.1 Explore a New Codebase

```
give me an overview of this codebase
explain the main architecture patterns
how is authentication handled?
trace the login process from front-end to database
```

### 22.2 Fix a Bug

```
I'm seeing this error when I run npm test: [paste error]
suggest a few ways to fix it
apply the null check fix and run the tests again
```

### 22.3 Refactor Legacy Code

```
find deprecated API usage in our codebase
suggest how to refactor utils.js to use ES2024 features
refactor utils.js while maintaining the same behavior
run tests for the refactored code
```

### 22.4 Add Tests

```
find functions in NotificationsService.swift not covered by tests
add tests for the notification service
add test cases for edge conditions
run the new tests and fix any failures
```

### 22.5 Create a Pull Request

```
summarize the changes I've made to the authentication module
create a pr
enhance the PR description with more context about security improvements
```

### 22.6 Use Claude as a Unix Utility

```bash
# Linter
claude -p 'look at changes vs. main and report typos with filename:line'

# Pipe data through
cat build-error.txt | claude -p 'explain the root cause' > output.txt

# Structured output
cat code.py | claude -p 'analyze for bugs' --output-format json > analysis.json

# Streaming
cat log.txt | claude -p 'parse for errors' --output-format stream-json
```

### 22.7 Desktop Notifications When Claude Needs You

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "osascript -e 'display notification \"Claude needs attention\" with title \"Claude Code\"'"
      }]
    }]
  }
}
```

### 22.8 Work with Images

- Drag and drop images into Claude Code
- Copy/paste with `Ctrl+V`
- Provide image paths: `Analyze this image: /path/to/screenshot.png`
- Use for: error screenshots, UI mockups, database diagrams, design specs

---

## 23. Model Configuration & Selection

### 23.1 Model Aliases

| Alias | Model | Best For |
|-------|-------|----------|
| `sonnet` | Sonnet 4.6 | Daily coding tasks |
| `opus` | Opus 4.6 | Complex reasoning |
| `haiku` | Haiku 4.5 | Simple/fast tasks |
| `sonnet[1m]` | Sonnet 4.6 (1M context) | Long sessions, large codebases |
| `opus[1m]` | Opus 4.6 (1M context) | Long sessions with complex reasoning |
| `opusplan` | Opus for planning, Sonnet for execution | Best of both worlds |

### 23.2 Setting Your Model

```bash
# At startup
claude --model opus

# During session
/model sonnet

# Environment variable
export ANTHROPIC_MODEL=opus

# In settings.json
{ "model": "opus" }
```

### 23.3 Effort Levels (Adaptive Reasoning)

Control how deeply Claude thinks before responding:

| Level | Speed | Cost | Use For |
|-------|-------|------|---------|
| `low` | Fastest | Cheapest | Simple tasks, quick edits |
| `medium` | Balanced | Moderate | Most coding tasks (Opus default) |
| `high` | Slower | Higher | Complex architecture, hard bugs |
| `max` | Slowest | Highest | Deepest reasoning (Opus only, session-only) |

```bash
/effort high          # Set during session
claude --effort high  # At startup
```

### 23.4 The opusplan Strategy

Uses Opus for planning (complex reasoning) and auto-switches to Sonnet for execution (efficient code generation):

```bash
claude --model opusplan
```

### 23.5 1M Context Window

For long sessions with large codebases:

```bash
/model opus[1m]
/model sonnet[1m]
```

Availability: included on Max/Team/Enterprise for Opus. Extra usage required for Sonnet on some plans.

### 23.6 Third-Party Providers

Pin model versions for Bedrock/Vertex/Foundry deployments:

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-6-v1'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6-v1'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-v1'
```

---

## 24. Permissions & Security

### 24.1 Permission Modes

| Mode | Description |
|------|-------------|
| `default` | Prompts for permission on first use |
| `acceptEdits` | Auto-accepts file edits |
| `plan` | Read-only analysis mode |
| `dontAsk` | Auto-denies unless pre-approved |
| `bypassPermissions` | Skips all checks (isolated environments only!) |

Switch modes: `Shift+Tab` during a session.

### 24.2 Permission Rules

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git commit *)",
      "Read(/src/**/*.ts)",
      "WebFetch(domain:github.com)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(rm -rf *)",
      "Edit(/migrations/**)"
    ]
  }
}
```

### 24.3 Rule Syntax

| Rule | Matches |
|------|---------|
| `Bash` | All bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Read(./.env)` | Reading the .env file |
| `Edit(/src/**/*.ts)` | Editing TypeScript files in src/ |
| `WebFetch(domain:example.com)` | Fetching from example.com |
| `mcp__github__*` | All GitHub MCP tools |
| `Agent(Explore)` | The Explore sub-agent |

### 24.4 Enterprise Managed Settings

Deploy organization-wide policies that users cannot override:

```json
// /Library/Application Support/ClaudeCode/managed-settings.json (macOS)
{
  "permissions": {
    "deny": ["Bash(rm -rf *)"],
    "defaultMode": "default"
  },
  "disableBypassPermissionsMode": "disable",
  "availableModels": ["sonnet", "haiku"]
}
```

### 24.5 Defense in Depth

Combine permissions + sandboxing + hooks:
- **Permissions**: Control which tools Claude can use
- **Sandboxing**: OS-level filesystem/network isolation for Bash
- **Hooks**: Runtime validation before tool execution

---

## 25. Scheduled Tasks & Automation

### 25.1 The /loop Skill

Run prompts repeatedly on an interval:

```
/loop 5m check if the deployment finished
/loop 20m /review-pr 1234
/loop check the build    # defaults to every 10 minutes
```

### 25.2 One-Time Reminders

```
remind me at 3pm to push the release branch
in 45 minutes, check whether the integration tests passed
```

### 25.3 Managing Scheduled Tasks

```
what scheduled tasks do I have?
cancel the deploy check job
```

### 25.4 Key Details

- **Session-scoped**: Tasks die when you exit Claude Code
- **3-day expiry**: Recurring tasks auto-expire after 3 days
- **Idle-only**: Tasks fire between your turns, not mid-response
- **Local timezone**: All times are in your local timezone
- **Max 50 tasks** per session

### 25.5 Durable Scheduling

For tasks that survive restarts:
- **Desktop App**: Schedule recurring tasks with a GUI
- **GitHub Actions**: Use `schedule` trigger with cron syntax
- **CI/CD**: Any cron-based system with `claude -p`

---

## 26. Project Rules — Scoped Instructions

Rules let you scope instructions to specific file types or subdirectories, keeping context lean.

### 26.1 Setup

Place markdown files in `.claude/rules/`:

```
.claude/
├── CLAUDE.md              # Main project instructions
└── rules/
    ├── code-style.md      # Always loaded
    ├── testing.md          # Always loaded
    ├── security.md         # Always loaded
    └── frontend/
        └── react.md       # Organize by topic
```

### 26.2 Path-Specific Rules

Rules can be scoped to specific files using YAML frontmatter:

```yaml
# .claude/rules/api-rules.md
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- All endpoints must include input validation
- Use the standard error response format
- Include OpenAPI documentation comments
```

These rules only load when Claude works with matching files — saving context.

### 26.3 Glob Patterns

| Pattern | Matches |
|---------|---------|
| `**/*.ts` | All TypeScript files |
| `src/**/*` | All files under src/ |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in specific dir |
| `src/**/*.{ts,tsx}` | Multiple extensions with brace expansion |

### 26.4 Shared Rules via Symlinks

```bash
ln -s ~/shared-claude-rules .claude/rules/shared
ln -s ~/company-standards/security.md .claude/rules/security.md
```

### 26.5 User-Level Rules

Personal rules in `~/.claude/rules/` apply to every project:

```
~/.claude/rules/
├── preferences.md    # Your coding preferences
└── workflows.md      # Your preferred workflows
```

---

## 27. Auto Memory Deep Dive

Auto memory lets Claude accumulate knowledge across sessions without you writing anything.

### 27.1 How It Works

- Claude saves notes as it works: build commands, debugging insights, architecture notes
- Stored in `~/.claude/projects/<project>/memory/`
- First 200 lines of `MEMORY.md` loaded every session
- Topic files (e.g., `debugging.md`) loaded on-demand

### 27.2 Memory Directory Structure

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index (loaded every session)
├── debugging.md       # Debugging patterns
├── api-conventions.md # API design decisions
└── build-notes.md     # Build system quirks
```

### 27.3 Enable/Disable

```
/memory              # Browse and toggle auto memory
```

Or in settings:
```json
{ "autoMemoryEnabled": false }
```

### 27.4 Custom Memory Location

```json
{ "autoMemoryDirectory": "~/my-custom-memory-dir" }
```

### 27.5 Tips

- Ask Claude to "remember that the API tests require Redis" → saved to auto memory
- Ask Claude to "add this to CLAUDE.md" → saved to CLAUDE.md instead
- Edit memory files directly — they're plain markdown
- All worktrees in the same git repo share one memory directory

---

## 28. Troubleshooting Guide

### 28.1 Claude Isn't Following CLAUDE.md

1. Run `/memory` to verify files are loaded
2. Check file is in a loaded location (project root, parent dirs, or `~/.claude/`)
3. Make instructions more specific ("Use 2-space indentation" not "format nicely")
4. Look for conflicting instructions across files
5. If file is too long (>200 lines), prune or split into rules/skills

### 28.2 MCP Server Not Connecting

```bash
claude mcp list          # Check configured servers
/mcp                     # Check status inside Claude Code
claude mcp get <name>    # Get details for specific server
```

Common fixes:
- Verify the server URL is correct
- Check authentication with `/mcp` → follow browser login
- For stdio servers, ensure the command is in PATH
- Set `MCP_TIMEOUT=10000` for slow-starting servers

### 28.3 Permission Errors

```
/permissions             # View and manage permission rules
```

- Check if a deny rule is blocking the action
- Verify settings precedence (managed > CLI > local > project > user)
- For sandboxing issues, check `sandbox.filesystem.allowWrite`

### 28.4 High Token Usage

```
/cost                    # Check current session costs
/context                 # See what's consuming context space
```

Fixes:
- `/clear` between unrelated tasks
- Use sub-agents for verbose operations
- Disable unused MCP servers
- Move CLAUDE.md instructions to on-demand skills
- Lower effort level: `/effort low`

### 28.5 Claude Keeps Making the Same Mistake

After 2 failed corrections:
1. `/clear` to reset context
2. Write a better initial prompt incorporating what you learned
3. Add the rule to CLAUDE.md if it's a recurring issue
4. Consider a hook for deterministic enforcement

### 28.6 Slow Performance

- Switch to Sonnet for routine tasks: `/model sonnet`
- Lower effort: `/effort low`
- Use Haiku for sub-agents: `model: haiku` in agent config
- Reduce MCP server count
- Install code intelligence plugins (fewer file reads)

### 28.7 Context Window Full

- `/compact` to summarize and free space
- `/compact Focus on the API changes` for targeted compaction
- Use `opus[1m]` or `sonnet[1m]` for 1M context window
- Delegate verbose operations to sub-agents
- `/clear` and start fresh with a focused prompt

### 28.8 Hooks Not Firing

1. `/hooks` to browse configured hooks
2. Check matcher regex matches the tool name
3. Verify script is executable: `chmod +x script.sh`
4. Check exit codes (0=success, 2=block, other=non-blocking error)
5. Test the script manually with sample JSON input

### 28.9 Skills Not Triggering

1. Check description includes keywords users would say
2. Verify skill appears: "What skills are available?"
3. Try invoking directly: `/skill-name`
4. If triggering too often, make description more specific
5. If too many skills, check `/context` for budget warnings

### 28.10 Installation Issues

```bash
claude doctor            # Detailed installation check
claude --version         # Verify installation
```

- macOS: Seatbelt sandbox works out of the box
- Linux: Install `bubblewrap socat` for sandboxing
- Windows: Requires Git for Windows or WSL
- WSL1: No sandbox support (use WSL2)

---

## 29. CLI Reference — Essential Flags

### 29.1 Core Commands

| Command | Description |
|---------|-------------|
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Non-interactive (headless) mode |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "name"` | Resume session by name or ID |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in |
| `claude auth status` | Check authentication |
| `claude agents` | List all configured sub-agents |
| `claude mcp` | Configure MCP servers |
| `claude doctor` | Diagnose installation issues |

### 29.2 Most Useful Flags

| Flag | Description |
|------|-------------|
| `--model opus` | Set model (alias or full name) |
| `--effort high` | Set effort level (low/medium/high/max) |
| `--allowedTools "Bash,Read,Edit"` | Auto-approve specific tools |
| `--disallowedTools "Agent(Explore)"` | Block specific tools |
| `--output-format json` | Structured output (text/json/stream-json) |
| `--json-schema '{...}'` | Validated JSON output matching schema |
| `--max-turns 10` | Limit agentic turns (headless only) |
| `--max-budget-usd 5.00` | Spending cap (headless only) |
| `--permission-mode plan` | Start in plan mode |
| `--append-system-prompt "..."` | Add to system prompt |
| `--worktree feature-auth` | Start in isolated git worktree |
| `--add-dir ../lib` | Add additional working directories |
| `--name "my-feature"` | Name the session |
| `--continue --fork-session` | Branch off from a conversation |
| `--from-pr 123` | Resume sessions linked to a PR |
| `--plugin-dir ./my-plugin` | Load plugin for testing |
| `--agents '{...}'` | Define ephemeral sub-agents via JSON |
| `--verbose` | Show full turn-by-turn output |
| `--debug "api,hooks"` | Debug mode with category filtering |
| `--dangerously-skip-permissions` | Bypass all checks (sandbox only!) |
| `--remote` | Create a web session on claude.ai |
| `--remote-control` | Enable Remote Control |
| `--fallback-model sonnet` | Auto-fallback when primary overloaded |

### 29.3 System Prompt Flags

| Flag | Behavior |
|------|----------|
| `--system-prompt "..."` | Replace entire system prompt |
| `--system-prompt-file ./prompt.txt` | Replace from file |
| `--append-system-prompt "..."` | Append to default prompt |
| `--append-system-prompt-file ./rules.txt` | Append from file |

---

## 30. Status Line — Custom Dashboard

The status line is a customizable bar at the bottom of Claude Code that displays context usage, costs, git status, or anything else.

### 30.1 Quick Setup

```
/statusline show model name and context percentage with a progress bar
```

Claude generates a script and configures it automatically.

### 30.2 Manual Setup

```json
// ~/.claude/settings.json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

### 30.3 Example: Context + Git + Cost

```bash
#!/bin/bash
# ~/.claude/statusline.sh
input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Color-coded progress bar
if [ "$PCT" -ge 90 ]; then COLOR='\033[31m'
elif [ "$PCT" -ge 70 ]; then COLOR='\033[33m'
else COLOR='\033[32m'; fi
RESET='\033[0m'

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '█')$(printf "%${EMPTY}s" | tr ' ' '░')

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && \
  BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"

COST_FMT=$(printf '$%.2f' "$COST")
echo -e "[$MODEL] 📁 ${DIR##*/}$BRANCH | ${COLOR}${BAR}${RESET} ${PCT}% | $COST_FMT"
```

### 30.4 Available Data Fields

| Field | Description |
|-------|-------------|
| `model.display_name` | Current model name |
| `workspace.current_dir` | Working directory |
| `context_window.used_percentage` | Context usage % |
| `cost.total_cost_usd` | Session cost |
| `cost.total_duration_ms` | Wall-clock time |
| `cost.total_lines_added/removed` | Code changes |
| `session_id` | Session identifier |
| `vim.mode` | Vim mode (if enabled) |
| `worktree.name` | Active worktree name |

---

## 31. Checkpointing — Safe Experimentation

Claude Code automatically tracks file edits, letting you rewind to any previous state.

### 31.1 How It Works

- Every user prompt creates a new checkpoint
- Checkpoints persist across sessions
- Auto-cleaned after 30 days

### 31.2 Rewind Menu

Press `Esc + Esc` or type `/rewind`:

| Action | What It Does |
|--------|-------------|
| **Restore code and conversation** | Revert both to that point |
| **Restore conversation** | Rewind messages, keep current code |
| **Restore code** | Revert files, keep conversation |
| **Summarize from here** | Compress messages from this point forward |

### 31.3 Use Cases

- **Exploring alternatives**: Try different approaches, rewind if wrong
- **Recovering from mistakes**: Undo changes that broke things
- **Freeing context**: Summarize verbose debugging from midpoint forward
- **Iterating on features**: Experiment knowing you can revert

### 31.4 Limitations

- Bash command changes (rm, mv, cp) are NOT tracked
- External changes outside Claude Code are not captured
- Not a replacement for git — use both together

### 31.5 Fork Sessions

Branch off from a conversation to try a different approach while preserving the original:

```bash
claude --continue --fork-session
```

---

## 32. Claude Code on the Web — Cloud Execution

Run Claude Code from your browser with no local setup. Tasks run on Anthropic's secure cloud infrastructure in isolated VMs.

### 32.1 Getting Started

1. Visit [claude.ai/code](https://claude.ai/code)
2. Connect your GitHub account
3. Install the Claude GitHub app in your repositories
4. Select your default environment
5. Submit your coding task

### 32.2 Best Use Cases

- **Bug fixes and routine tasks** — Well-defined work that doesn't need frequent steering
- **Parallel work** — Tackle multiple bug fixes simultaneously
- **Repos not on your machine** — Work on code you don't have locally
- **Mobile** — Kick off tasks from iOS/Android Claude app

### 32.3 Terminal ↔ Web Handoffs

```bash
# Start a web session from terminal
claude --remote "Fix the authentication bug in src/auth/login.ts"

# Pull a web session into your terminal
claude --teleport
# Or inside Claude Code:
/teleport
```

### 32.4 Parallel Remote Tasks

```bash
claude --remote "Fix the flaky test in auth.spec.ts"
claude --remote "Update the API documentation"
claude --remote "Refactor the logger to use structured output"
# Monitor all: /tasks
```

### 32.5 Plan Locally, Execute Remotely

```bash
# Plan with full context locally
claude --permission-mode plan
# "Create a migration plan for the auth system"

# Execute autonomously in the cloud
claude --remote "Execute the migration plan in docs/migration-plan.md"
```

### 32.6 Environment Configuration

- **Setup scripts**: Bash scripts that run before Claude Code launches (install deps, configure tools)
- **Network access**: Limited (default allowlist), Full, or No internet
- **Environment variables**: Key-value pairs in `.env` format
- **Default image**: Ubuntu with Python, Node.js, Ruby, Java, Go, Rust, C++, PostgreSQL, Redis

### 32.7 Diff View

Review changes before creating a PR — see exactly what Claude changed, comment on specific lines, and iterate until ready.

---

## 33. Remote Control — Work From Any Device

Continue a local Claude Code session from your phone, tablet, or any browser. Claude keeps running on your machine — the web/mobile interface is just a window into that local session.

### 33.1 Start Remote Control

```bash
# Server mode (dedicated, no local interaction)
claude remote-control --name "My Project"

# Interactive mode (local + remote simultaneously)
claude --remote-control "My Project"

# From an existing session
/remote-control
```

### 33.2 Connect From Another Device

- Open the session URL displayed in terminal
- Scan the QR code (press spacebar to show)
- Find the session in [claude.ai/code](https://claude.ai/code) session list
- Open in Claude iOS/Android app

### 33.3 Key Features

- **Full local environment**: Your filesystem, MCP servers, tools, and config stay available
- **Dual-surface**: Send messages from terminal, browser, and phone interchangeably
- **Auto-reconnect**: Survives laptop sleep and network drops
- **No cloud execution**: Everything runs on your machine

### 33.4 Server Mode Flags

| Flag | Description |
|------|-------------|
| `--name "Project"` | Custom session title |
| `--spawn worktree` | Each session gets its own git worktree |
| `--capacity 32` | Max concurrent sessions |
| `--sandbox` | Enable filesystem/network isolation |

### 33.5 Enable for All Sessions

```
/config → Enable Remote Control for all sessions → true
```

### 33.6 Remote Control vs. Web Sessions

| | Remote Control | Web Sessions |
|---|---|---|
| **Runs on** | Your machine | Anthropic cloud |
| **Local tools** | Full access (MCP, filesystem) | No (cloud environment) |
| **Setup needed** | Your machine must be on | None |
| **Best for** | Continuing local work remotely | Kicking off tasks without setup |

---

## 34. Chrome Extension — Browser Automation

Connect Claude Code to your Chrome browser to test web apps, debug with console logs, automate forms, and extract data — all from the CLI.

### 34.1 Setup

1. Install [Google Chrome](https://www.google.com/chrome/) or Microsoft Edge
2. Install [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) (v1.0.36+)
3. Start Claude Code with `claude --chrome` or run `/chrome` in a session

### 34.2 Capabilities

| Capability | Example |
|-----------|---------|
| **Live debugging** | Read console errors, fix the code that caused them |
| **Design verification** | Build UI from Figma mock, verify in browser |
| **Web app testing** | Test form validation, check visual regressions |
| **Authenticated apps** | Interact with Google Docs, Gmail, Notion (uses your login state) |
| **Data extraction** | Pull structured data from web pages → CSV |
| **Form automation** | Fill forms from CSV data across multiple pages |
| **GIF recording** | Record browser interactions as shareable GIFs |

### 34.3 Example Workflows

```
# Test local web app
"Open localhost:3000, try submitting the form with invalid data,
check if error messages appear correctly"

# Debug with console logs
"Open the dashboard page and check the console for errors on load"

# Extract data
"Go to the product listings page, extract name/price/availability
for each item, save as CSV"

# Draft in Google Docs
"Draft a project update based on recent commits and add it to my
Google Doc at docs.google.com/document/d/abc123"

# Record a demo
"Record a GIF showing the checkout flow from cart to confirmation"
```

### 34.4 Enable by Default

```
/chrome → "Enabled by default"
```

Note: Increases context usage since browser tools are always loaded.

---

## 35. Slack Integration — Team Workflows

Mention `@Claude` in Slack with a coding task, and Claude creates a web session, implements the fix, and posts results back to your thread.

### 35.1 Setup

1. Install Claude app from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. Connect your Claude account in the App Home tab
3. Connect GitHub repos at [claude.ai/code](https://claude.ai/code)
4. Choose routing mode: **Code only** or **Code + Chat**
5. Invite Claude to channels: `/invite @Claude`

### 35.2 How It Works

1. You `@Claude` with a coding request in a channel/thread
2. Claude detects coding intent and creates a web session
3. Progress updates posted to your Slack thread
4. On completion: summary + "View Session" + "Create PR" buttons

### 35.3 Example Requests

```
@Claude Fix the login bug reported in this thread — the session
timeout isn't being handled correctly in src/auth/

@Claude Implement the feature described in issue #42 and create a PR

@Claude Review the recent changes to the payment module for
security vulnerabilities
```

### 35.4 Context Gathering

- **In threads**: Claude reads all messages in the thread for context
- **In channels**: Claude reads recent channel messages
- Context informs repo selection, problem understanding, and approach

### 35.5 When to Use Slack vs. Web

| Use Slack When | Use Web When |
|---|---|
| Context already in a Slack discussion | Need to upload files |
| Kick off tasks asynchronously | Want real-time interaction |
| Team needs visibility | Complex, longer tasks |

---

## 36. GitLab CI/CD Integration

Claude Code works with GitLab just like GitHub Actions — run AI tasks in CI jobs, create MRs from issues, and automate code changes.

### 36.1 Quick Setup

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings → CI/CD → Variables)
2. Add a Claude job to `.gitlab-ci.yml`:

```yaml
stages:
  - ai

claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - apk update && apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - claude -p "${AI_FLOW_INPUT:-'Review this MR and implement changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write"
```

### 36.2 What Claude Can Do in GitLab

- Create and update MRs from issue descriptions
- Implement features in a branch and open an MR
- Fix bugs identified by tests or comments
- Respond to `@claude` mentions to iterate on changes
- Analyze performance regressions

### 36.3 Enterprise Providers

Works with AWS Bedrock and Google Vertex AI via OIDC — no static keys needed.

---

## 37. Automated Code Review (Teams/Enterprise)

A managed service that posts inline review comments on every PR — no CI setup required.

### 37.1 How It Works

1. Admin enables Code Review at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code)
2. Install the Claude GitHub App
3. Select repositories and review triggers
4. Claude analyzes PRs with multiple specialized agents in parallel
5. Findings posted as inline comments with severity tags

### 37.2 Severity Levels

| Marker | Severity | Meaning |
|--------|----------|---------|
| 🔴 | Normal | Bug that should be fixed before merging |
| 🟡 | Nit | Minor issue, worth fixing but not blocking |
| 🟣 | Pre-existing | Bug in codebase not introduced by this PR |

### 37.3 Review Triggers

| Trigger | When Reviews Run |
|---------|-----------------|
| **Once after PR creation** | When PR is opened or marked ready |
| **After every push** | On every push to the PR branch |
| **Manual** | Only when someone comments `@claude review` |

### 37.4 Customize with REVIEW.md

```markdown
# REVIEW.md — Review-only guidance

## Always check
- New API endpoints have integration tests
- Database migrations are backward-compatible
- Error messages don't leak internal details

## Style
- Prefer match statements over chained isinstance checks
- Use structured logging, not f-string interpolation

## Skip
- Generated files under src/gen/
- Formatting-only changes in *.lock files
```

### 37.5 Pricing

Reviews average $15-25, scaling with PR size and complexity. Billed separately through extra usage.

### 37.6 Manual Trigger

Comment `@claude review` on any PR to start a review and opt that PR into push-triggered reviews going forward.

---

## 38. Enterprise Deployment Guide

### 38.1 Authentication Options

| Method | Best For |
|--------|----------|
| **Claude.ai (OAuth)** | Pro, Max, Teams, Enterprise — browser login |
| **API Key (Console)** | Pay-as-you-go, CI/CD, automation |
| **Amazon Bedrock** | AWS-native, data residency, existing contracts |
| **Google Vertex AI** | GCP-native, Workload Identity Federation |
| **Microsoft Foundry** | Azure-native deployments |

### 38.2 Managed Settings (IT Admin)

Deploy organization-wide policies that users cannot override:

**File locations:**
- macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
- Linux/WSL: `/etc/claude-code/managed-settings.json`
- Windows: `C:\Program Files\ClaudeCode\managed-settings.json`

```json
{
  "permissions": {
    "deny": ["Bash(rm -rf *)", "Bash(git push --force *)"],
    "defaultMode": "default"
  },
  "disableBypassPermissionsMode": "disable",
  "allowManagedPermissionRulesOnly": true,
  "allowManagedHooksOnly": true,
  "availableModels": ["sonnet", "haiku"],
  "model": "sonnet"
}
```

### 38.3 Managed-Only Settings

| Setting | Description |
|---------|-------------|
| `disableBypassPermissionsMode` | Prevent `--dangerously-skip-permissions` |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed hooks are allowed |
| `allowManagedMcpServersOnly` | Only managed MCP servers allowed |
| `blockedMarketplaces` | Block specific plugin marketplaces |
| `allow_remote_sessions` | Control Remote Control access |

### 38.4 Managed CLAUDE.md

Organization-wide instructions all users must follow:

- macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`
- Linux/WSL: `/etc/claude-code/CLAUDE.md`
- Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`

Cannot be excluded by individual settings.

### 38.5 Managed MCP Configuration

Lock down MCP servers organization-wide:

```json
// managed-mcp.json (same system directories as managed-settings)
{
  "mcpServers": {
    "company-internal": {
      "type": "stdio",
      "command": "/usr/local/bin/company-mcp-server",
      "args": ["--config", "/etc/company/mcp-config.json"]
    }
  }
}
```

Users cannot add, modify, or use any MCP servers other than those defined here.

### 38.6 Model Pinning for Third-Party Providers

```bash
# Pin specific versions to prevent breakage on updates
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-6-v1'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6-v1'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-v1'
```

### 38.7 Restrict Model Selection

```json
{ "availableModels": ["sonnet", "haiku"] }
```

Users cannot switch to models not in this list.

---

## 39. Environment Variables Reference

### 39.1 Core Variables

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | API key for authentication |
| `ANTHROPIC_MODEL` | Default model (alias or full name) |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: low/medium/high/max/auto |
| `MAX_THINKING_TOKENS` | Limit thinking token budget (0 = disable) |

### 39.2 Model Override Variables

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for sub-agents |

### 39.3 Feature Flags

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams (set to `1`) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory (set to `1`) |
| `CLAUDE_CODE_DISABLE_CRON` | Disable scheduled tasks (set to `1`) |
| `CLAUDE_CODE_DISABLE_1M_CONTEXT` | Disable 1M context variants |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | Revert to fixed thinking budget |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background task functionality |
| `DISABLE_AUTOUPDATER` | Disable auto-updates (set to `1`) |

### 39.4 MCP & Tool Variables

| Variable | Description |
|----------|-------------|
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens for MCP tool output (default: 25000) |
| `ENABLE_TOOL_SEARCH` | Tool search: true/false/auto/auto:N |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable claude.ai MCP servers (true/false) |

### 39.5 Prompt Caching

| Variable | Description |
|----------|-------------|
| `DISABLE_PROMPT_CACHING` | Disable for all models (set to `1`) |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

### 39.6 Third-Party Provider Variables

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_BASE_URL` | Custom API base URL |
| `CLAUDE_CODE_USE_BEDROCK` | Use AWS Bedrock (set to `1`) |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI (set to `1`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID for Vertex |
| `CLOUD_ML_REGION` | Vertex AI region |

---

## 40. Glossary

| Term | Definition |
|------|-----------|
| **Agent SDK** | Python/TypeScript packages for programmatic Claude Code control |
| **Auto memory** | Notes Claude writes itself across sessions (~/.claude/projects/) |
| **CLAUDE.md** | Markdown file with persistent instructions loaded every session |
| **Checkpoint** | Automatic snapshot of code state before each edit |
| **Compaction** | Summarizing conversation history to free context space |
| **Context window** | Total token capacity for conversation (200K default, 1M extended) |
| **Effort level** | Controls adaptive reasoning depth (low/medium/high/max) |
| **Extended thinking** | Claude's internal reasoning before responding |
| **Hook** | Shell command/HTTP/prompt/agent that runs at lifecycle events |
| **MCP** | Model Context Protocol — open standard for AI-tool integrations |
| **MCP server** | External tool connected via MCP (GitHub, Notion, databases, etc.) |
| **opusplan** | Model alias: Opus for planning, Sonnet for execution |
| **Permission mode** | Controls how tool usage is approved (default/acceptEdits/plan/etc.) |
| **Plan Mode** | Read-only exploration mode for research before implementation |
| **Plugin** | Bundled package of skills, agents, hooks, MCP, and LSP servers |
| **Remote Control** | Continue local sessions from phone/browser via claude.ai |
| **REVIEW.md** | Review-only guidance for automated code review |
| **Sandboxing** | OS-level filesystem and network isolation for Bash commands |
| **Skill** | Reusable AI workflow defined in SKILL.md, invoked with /name |
| **Status line** | Customizable bar showing context usage, costs, git status |
| **Sub-agent** | Specialized AI assistant running in its own context window |
| **Agent team** | Multiple Claude instances coordinating via shared task list |
| **Teleport** | Pull a web session into your local terminal (/teleport) |
| **Tool search** | On-demand MCP tool loading when many servers are configured |
| **ultrathink** | Keyword to enable deep reasoning for a single turn |
| **Worktree** | Isolated git working directory for parallel sessions |

---

## 41. Desktop App — Visual Interface

The Desktop app provides a graphical interface for Claude Code with features beyond the CLI.

### 41.1 Desktop-Only Features

| Feature | Description |
|---------|-------------|
| **Visual diff review** | Side-by-side diffs with inline comments |
| **Live app preview** | Embedded browser for dev servers |
| **PR monitoring** | Auto-fix failing CI, auto-merge when green |
| **Parallel sessions** | Automatic git worktree isolation per session |
| **Scheduled tasks** | Recurring tasks with GUI setup |
| **Connectors** | GitHub, Slack, Linear, Notion integrations |
| **SSH sessions** | Run on remote machines via SSH |
| **Remote sessions** | Run on Anthropic cloud, continue if laptop closes |

### 41.2 Installation

- [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect) (Intel + Apple Silicon)
- [Windows](https://claude.ai/api/desktop/win32/x64/exe/latest/redirect) (x64)
- [Windows ARM64](https://claude.ai/api/desktop/win32/arm64/exe/latest/redirect) (remote sessions only)

### 41.3 Permission Modes

| Mode | Behavior |
|------|----------|
| **Ask permissions** | Claude asks before each action (recommended for new users) |
| **Auto accept edits** | Auto-accepts file edits, asks for commands |
| **Plan mode** | Analyze and plan without modifying files |
| **Bypass permissions** | No prompts (enable in Settings, sandbox only) |

### 41.4 Scheduled Tasks

Create recurring tasks that run automatically:

1. Click **Schedule** in sidebar → **+ New task**
2. Set name, prompt, frequency (manual/hourly/daily/weekdays/weekly)
3. Tasks run locally — app must be open and computer awake
4. Missed runs catch up with one run when computer wakes

### 41.5 PR Monitoring

After opening a PR, a CI status bar appears:
- **Auto-fix**: Claude automatically fixes failing CI checks
- **Auto-merge**: Claude merges when all checks pass (squash merge)

### 41.6 Preview Servers

Claude starts dev servers and opens an embedded browser. Configure in `.claude/launch.json`:

```json
{
  "version": "0.0.1",
  "autoVerify": true,
  "configurations": [{
    "name": "web",
    "runtimeExecutable": "npm",
    "runtimeArgs": ["run", "dev"],
    "port": 3000
  }]
}
```

### 41.7 CLI → Desktop Handoff

```
/desktop    # Move current CLI session to Desktop app
```

---

## 42. VS Code Extension — IDE Integration

The VS Code extension provides inline diffs, @-mentions, plan review, and conversation history directly in your editor.

### 42.1 Installation

- [Install for VS Code](vscode:extension/anthropic.claude-code)
- [Install for Cursor](cursor:extension/anthropic.claude-code)
- Or search "Claude Code" in Extensions view (`Cmd+Shift+X`)

### 42.2 Key Features

| Feature | How |
|---------|-----|
| **Open Claude** | Click Spark icon in editor toolbar, or `Cmd+Shift+P` → "Claude Code" |
| **@-mention files** | Type `@filename` in prompt for context |
| **Insert selection** | `Option+K` (Mac) / `Alt+K` to reference selected code |
| **Inline diffs** | Side-by-side comparison of proposed changes |
| **Plan review** | Plan opens as editable markdown document |
| **Multiple tabs** | Open in New Tab for parallel conversations |
| **Resume sessions** | Dropdown at top of panel shows history |
| **Browser automation** | `@browser` followed by instructions |
| **Plugin management** | Type `/plugins` in prompt box |

### 42.3 Essential Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation tab |
| `Option+K` / `Alt+K` | Insert @-mention for current selection |
| `Cmd+N` / `Ctrl+N` | New conversation (when Claude focused) |
| `Shift+Enter` | Multi-line input |

### 42.4 Extension Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default permission mode |
| `autosave` | `true` | Auto-save files before Claude reads/writes |

### 42.5 Third-Party Providers in VS Code

1. Disable login prompt in settings
2. Configure provider in `~/.claude/settings.json`
3. Supports Bedrock, Vertex AI, and Foundry

### 42.6 Checkpoints in VS Code

Hover over any message to reveal the rewind button:
- **Fork conversation from here**: New branch, keep code
- **Rewind code to here**: Revert files, keep conversation
- **Fork and rewind**: New branch + revert files

---

## 43. JetBrains Integration

The JetBrains plugin works with IntelliJ IDEA, PyCharm, WebStorm, and other JetBrains IDEs.

### 43.1 Installation

Install from [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) and restart your IDE.

### 43.2 Features

- Interactive diff viewing with accept/reject
- Selection context sharing (highlight code → ask Claude about it)
- Conversation history
- Plan mode support
- Works alongside the CLI (shared settings and memory)

---

## 44. Getting Started Roadmap — By User Type

### 44.1 Solo Developer (Day 1)

```bash
# Install
curl -fsSL https://claude.ai/install.sh | bash

# Start in your project
cd your-project && claude

# Generate CLAUDE.md
/init

# Try these prompts:
"give me an overview of this codebase"
"fix the bug in src/auth/login.ts"
"write tests for the user service"
"commit with a descriptive message"
```

### 44.2 Team Lead (Week 1)

1. **Set up CLAUDE.md** — coding standards, architecture, workflows
2. **Create project skills** — `/deploy`, `/review-pr`, `/fix-issue`
3. **Add hooks** — auto-format after edits, block dangerous commands
4. **Connect MCP servers** — GitHub, Jira, Slack
5. **Install GitHub Actions** — `/install-github-app`
6. **Share via git** — commit `.claude/` directory

### 44.3 Enterprise Admin (First Month)

1. **Choose auth method** — Claude API, Bedrock, Vertex, or Foundry
2. **Deploy managed settings** — permission rules, model restrictions
3. **Deploy managed CLAUDE.md** — organization-wide coding standards
4. **Configure managed MCP** — approved integrations only
5. **Enable sandboxing** — OS-level isolation for all users
6. **Set up Code Review** — automated PR review for all repos
7. **Pin model versions** — prevent breakage on updates
8. **Set rate limits** — per-user TPM based on team size

### 44.4 Freelancer / Agency (Revenue Focus)

1. **Master the basics** — Plan mode, verification, context management
2. **Create reusable skills** — `/deploy-client`, `/generate-tests`, `/migrate-code`
3. **Set up GitHub Actions** — automated code review for client repos
4. **Build plugin portfolio** — industry-specific plugins for sale
5. **Use /batch for migrations** — parallel changes across large codebases
6. **Leverage Agent SDK** — custom automation for client workflows

### 44.5 Open Source Maintainer

1. **Add CLAUDE.md** — contribution guidelines, architecture docs
2. **Create REVIEW.md** — what to flag in PRs
3. **Enable Code Review** — automated review on every PR
4. **Add project skills** — `/setup-dev`, `/run-tests`, `/release`
5. **Connect GitHub MCP** — issue triage, PR management
6. **Use @claude in issues** — let Claude implement feature requests

---

## 45. Interactive Mode — Keyboard Mastery

### 45.1 Essential Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+G` | Open prompt in your text editor |
| `Ctrl+L` | Clear terminal screen (keeps conversation) |
| `Ctrl+O` | Toggle verbose output (see thinking) |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Esc + Esc` | Rewind or summarize |
| `Shift+Tab` | Toggle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |

### 45.2 Quick Commands

| Prefix | Action |
|--------|--------|
| `/` | Slash command or skill |
| `!` | Bash mode (run commands directly, output added to context) |
| `@` | File path mention with autocomplete |

### 45.3 Multiline Input

| Method | Shortcut |
|--------|----------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |
| Paste mode | Paste directly (for code blocks) |

### 45.4 Vim Mode

Enable with `/vim` or permanently via `/config`.

Key bindings: `h/j/k/l` navigation, `i/a/o` insert modes, `dd/cc/yy` editing, `w/b/e` word movement, text objects (`iw`, `i"`, `i(`), and `.` to repeat.

### 45.5 Side Questions with /btw

Quick questions that don't enter conversation history:

```
/btw what was the name of that config file again?
```

- Works while Claude is processing (doesn't interrupt)
- No tool access (answers from current context only)
- Single response, no follow-ups
- Low cost (reuses prompt cache)

### 45.6 Bash Mode with ! Prefix

```
! npm test
! git status
! ls -la
```

Runs commands directly, adds output to conversation context. Supports `Ctrl+B` backgrounding and Tab autocomplete from history.

### 45.7 Prompt Suggestions

After Claude responds, a grayed-out suggestion appears based on conversation history. Press `Tab` to accept, `Enter` to accept and submit, or start typing to dismiss.

### 45.8 Task List

Claude creates task lists for complex multi-step work. Press `Ctrl+T` to toggle visibility. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID=my-project claude`.

### 45.9 PR Review Status

When working on a branch with an open PR, a clickable link appears in the footer with color-coded review state (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged).

---

## 46. Feature Decision Guide — What to Use When

### 46.1 Quick Decision Matrix

| I want to... | Use |
|---|---|
| Set coding standards for all sessions | **CLAUDE.md** |
| Scope rules to specific file types | **`.claude/rules/`** with `paths` frontmatter |
| Create a reusable workflow | **Skill** |
| Connect to an external service | **MCP server** |
| Automate something that must always happen | **Hook** |
| Isolate a task from my main context | **Sub-agent** |
| Run parallel workers that communicate | **Agent team** |
| Package and share extensions | **Plugin** |
| Run Claude in CI/CD | **GitHub Actions** or **GitLab CI/CD** |
| Get automated PR reviews | **Code Review** (managed) or **GitHub Actions** |
| Run Claude from scripts | **Agent SDK** (`claude -p`) |
| Schedule recurring tasks | **Desktop scheduled tasks** or `/loop` |

### 46.2 CLAUDE.md vs. Skills vs. Rules

| | CLAUDE.md | `.claude/rules/` | Skill |
|---|---|---|---|
| **Loads** | Every session | Every session (or on file match) | On demand |
| **Scope** | Whole project | Can be path-scoped | Task-specific |
| **Best for** | Core conventions | Language/directory-specific rules | Reference material, workflows |
| **Size target** | <200 lines | Any size | <500 lines per SKILL.md |

### 46.3 Sub-Agents vs. Agent Teams

| | Sub-Agents | Agent Teams |
|---|---|---|
| **Communication** | Report back to main only | Message each other directly |
| **Coordination** | Main agent manages | Shared task list, self-coordinating |
| **Token cost** | Lower | Higher (each = separate instance) |
| **Best for** | Focused tasks, quick workers | Complex work needing discussion |

### 46.4 Context Cost by Feature

| Feature | When Loaded | Context Cost |
|---------|-------------|-------------|
| **CLAUDE.md** | Session start | Every request |
| **Skills** | Descriptions at start, full on use | Low until invoked |
| **MCP servers** | Session start | Every request (tool search helps) |
| **Sub-agents** | When spawned | Isolated (zero on main) |
| **Hooks** | On trigger | Zero (runs externally) |

### 46.5 Rule of Thumb

1. Start with **CLAUDE.md** for project conventions
2. Add **skills** for reusable workflows
3. Connect **MCP servers** for external tools
4. Add **hooks** for must-happen automation
5. Use **sub-agents** when context gets full
6. Package into **plugins** when sharing with others

---

## 47. Copy-Paste Recipes — Ready-to-Use Configurations

### 47.1 Complete Project Setup (CLAUDE.md + Skills + Hooks)

```bash
# Initialize project
cd your-project && claude
/init

# Create skill directory
mkdir -p .claude/skills/fix-issue .claude/skills/deploy .claude/agents

# Create fix-issue skill
cat > .claude/skills/fix-issue/SKILL.md << 'EOF'
---
name: fix-issue
description: Fix a GitHub issue end-to-end
disable-model-invocation: true
---
Fix GitHub issue $ARGUMENTS:
1. Use `gh issue view $0` to get details
2. Understand the problem
3. Search codebase for relevant files
4. Implement the fix
5. Write and run tests
6. Ensure linting and type checking pass
7. Create a descriptive commit
8. Push and create a PR linking the issue
EOF

# Create deploy skill
cat > .claude/skills/deploy/SKILL.md << 'EOF'
---
name: deploy
description: Deploy to production
disable-model-invocation: true
allowed-tools: Bash
---
Deploy $ARGUMENTS to production:
1. Run full test suite: !`npm test`
2. Check for vulnerabilities: !`npm audit --production`
3. Build: !`npm run build`
4. Deploy: !`./scripts/deploy.sh $0`
5. Run smoke tests against production
6. Post deployment summary
EOF

# Create code reviewer agent
cat > .claude/agents/reviewer.md << 'EOF'
---
name: reviewer
description: Reviews code for quality, security, and best practices. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: sonnet
---
You are a senior code reviewer. When invoked:
1. Run `git diff` to see recent changes
2. Review for: clarity, duplication, error handling, security, test coverage
3. Provide feedback by priority: Critical → Warnings → Suggestions
4. Include specific code examples for fixes
EOF

# Create hooks
cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write . 2>/dev/null || true"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'cmd=$(cat | jq -r .tool_input.command); echo \"$cmd\" | grep -qE \"rm -rf|git push --force|drop table\" && echo \"{\\\"hookSpecificOutput\\\":{\\\"hookEventName\\\":\\\"PreToolUse\\\",\\\"permissionDecision\\\":\\\"deny\\\",\\\"permissionDecisionReason\\\":\\\"Destructive command blocked\\\"}}\" || exit 0'"
          }
        ]
      }
    ]
  }
}
EOF

echo "Project setup complete! Try: /fix-issue 42"
```

### 47.2 MCP Server Collection (One-Liner Setup)

```bash
# GitHub (PRs, issues, code review)
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# Notion (pages, databases)
claude mcp add --transport http notion https://mcp.notion.com/mcp

# Sentry (error monitoring)
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp

# PostgreSQL (database queries)
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://user:pass@host:5432/dbname"

# Playwright (browser testing)
claude mcp add --transport stdio playwright -- npx -y @playwright/mcp@latest

# Authenticate all OAuth servers
# Inside Claude Code:
/mcp
```

### 47.3 GitHub Actions — Complete PR Review Workflow

```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  # Auto-review every PR
  review:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Review this PR for:
            - Security vulnerabilities (OWASP Top 10)
            - Performance bottlenecks
            - Logic errors and edge cases
            - Test coverage gaps
            Post findings as review comments.
          claude_args: "--model claude-sonnet-4-6 --max-turns 5"

  # Respond to @claude mentions
  respond:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude'))
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 47.4 Status Line — Full Dashboard

```bash
#!/bin/bash
# ~/.claude/statusline.sh — Model + Git + Context + Cost
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

# Color-coded context bar
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '█')$(printf "%${EMPTY}s" | tr ' ' '░')

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && \
  BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"

COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}$BRANCH"
echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"
```

```bash
chmod +x ~/.claude/statusline.sh
```

```json
// ~/.claude/settings.json (add to existing)
{ "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }
```

### 47.5 Desktop Notification Hook

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "osascript -e 'display notification \"Claude needs attention\" with title \"Claude Code\"'"
      }]
    }]
  }
}
```

Linux: Replace `osascript` line with `notify-send 'Claude Code' 'Claude needs attention'`

### 47.6 Security-Hardened Enterprise Config

```json
// /Library/Application Support/ClaudeCode/managed-settings.json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Edit(//etc/**)",
      "Edit(~/.ssh/**)",
      "Edit(~/.bashrc)",
      "Edit(~/.zshrc)"
    ],
    "defaultMode": "default"
  },
  "disableBypassPermissionsMode": "disable",
  "allowManagedPermissionRulesOnly": true,
  "allowManagedHooksOnly": true,
  "availableModels": ["sonnet", "haiku"],
  "model": "sonnet",
  "sandbox": {
    "enabled": true,
    "network": {
      "allowManagedDomainsOnly": true
    }
  }
}
```

### 47.7 Fan-Out Migration Script

```bash
#!/bin/bash
# migrate-files.sh — Parallel file migration with Claude Code

# Generate file list
claude -p "List all Python 2 files that need migrating to Python 3" \
  --output-format json | jq -r '.result' > files.txt

# Process each file in parallel (max 5 concurrent)
cat files.txt | xargs -P 5 -I {} bash -c '
  claude -p "Migrate {} from Python 2 to Python 3.12 with type hints. \
    Run tests after. Return OK or FAIL." \
    --allowedTools "Read,Edit,Bash(python *),Bash(pytest *)" \
    --max-turns 10 \
    --output-format json | jq -r ".result" > "/tmp/migrate-$(basename {}).log" 2>&1
'

# Summarize results
echo "=== Migration Results ==="
for log in /tmp/migrate-*.log; do
  echo "$(basename $log .log): $(tail -1 $log)"
done
```

---

## 48. Real-World Case Studies

### 48.1 Case Study: Solo Developer → 5x Client Capacity

**Before**: Freelance developer handling 2 clients/month, billing $150/hr.

**Setup**:
- Claude Code with Opus for architecture, Sonnet for implementation
- Custom skills: `/client-setup`, `/deploy-vercel`, `/generate-tests`
- GitHub Actions for automated PR review on all client repos
- MCP servers: GitHub, Notion (project management), Stripe (billing)

**After**: Handling 8-10 clients/month. Claude handles boilerplate, tests, and routine bug fixes. Developer focuses on architecture decisions and client communication.

**Revenue impact**: $24K/month → $80K/month (same hours).

### 48.2 Case Study: Startup — MVP in 3 Days

**Challenge**: Pre-seed startup needed a working MVP for investor demo.

**Approach**:
1. Day 1: Interview-driven spec with Claude (`AskUserQuestion` tool)
2. Day 1: Plan mode to design architecture
3. Day 2: Implementation with `/batch` for parallel component development
4. Day 2: Agent team — 3 workers (frontend, backend, tests)
5. Day 3: Chrome extension for visual QA, fix issues, deploy

**Stack**: Next.js + Prisma + PostgreSQL + Vercel
**Result**: Fully functional MVP with auth, dashboard, payments, and tests.

### 48.3 Case Study: Enterprise — Legacy Migration

**Challenge**: 500K-line Java 8 codebase → Java 21 with modern patterns.

**Approach**:
1. Created migration skills: `/migrate-streams`, `/migrate-records`, `/migrate-sealed`
2. Used `/batch` to process 50 files at a time (each in isolated worktree)
3. GitHub Actions reviewed every migration PR automatically
4. Agent team of 5 for complex modules requiring cross-file coordination

**Timeline**: 3 months (estimated 18 months manually).
**Quality**: 94% of migrated code passed review on first attempt.

### 48.4 Case Study: Agency — Code Review SaaS

**Product**: Automated security-focused code review for fintech companies.

**Architecture**:
- GitHub Actions with Claude Code on every PR
- Custom REVIEW.md with OWASP Top 10, PCI-DSS, SOX compliance rules
- Plugin with industry-specific skills and hooks
- Dashboard built with Agent SDK for client reporting

**Pricing**: $199/month per repo (small), $499/month (enterprise).
**Revenue**: $45K MRR after 6 months with 150 repos.

---

## 49. Advanced Prompt Engineering for Claude Code

### 49.1 The Specificity Spectrum

| Vague (Explore) | Specific (Execute) |
|---|---|
| "What would you improve in this file?" | "Add input validation to the login function in auth.ts" |
| "How does this work?" | "Trace the login process from front-end to database" |
| "Fix the bug" | "Users report login fails after session timeout. Check src/auth/, especially token refresh. Write a failing test, then fix it." |

Use vague prompts for exploration, specific prompts for execution.

### 49.2 The Interview Pattern

```
I want to build [brief description]. Interview me in detail using
the AskUserQuestion tool.

Ask about:
- Technical implementation details
- UI/UX decisions
- Edge cases and error handling
- Security concerns
- Performance tradeoffs

Don't ask obvious questions — dig into the hard parts I might not
have considered. Keep interviewing until we've covered everything,
then write a complete spec to SPEC.md.
```

Then start a fresh session to execute the spec (clean context).

### 49.3 The Verification Pattern

Always give Claude a way to check its own work:

```
# With tests
"Write validateEmail. Test cases: user@example.com → true,
invalid → false, user@.com → false. Run tests after implementing."

# With screenshots
"[paste screenshot] Implement this design. Take a screenshot of
the result and compare. List differences and fix them."

# With linting
"Refactor utils.js to ES2024. Run eslint and fix any issues."

# With type checking
"Add TypeScript types to the API module. Run tsc and fix all errors."
```

### 49.4 The Scoping Pattern

```
# Bad — infinite exploration
"Investigate the codebase"

# Good — scoped investigation
"Look at src/auth/ and explain how token refresh works.
Don't read other directories."

# Better — scoped with sub-agent
"Use a sub-agent to investigate how token refresh works in src/auth/.
Report back only the key findings."
```

### 49.5 The Correction Pattern

After 2 failed corrections:
1. `/clear` to reset context
2. Write a better prompt incorporating what you learned
3. Include the specific constraint Claude kept violating

```
# Instead of correcting again:
"I said don't use mocks!"

# Start fresh with explicit constraints:
"Write tests for the user service. Requirements:
- NO mocks — use real database with test fixtures
- Use the existing test helper in tests/helpers/db.ts
- Follow the pattern in tests/auth.test.ts
- Run tests after writing them"
```

### 49.6 The Context-Efficient Pattern

```
# Bad — Claude reads everything
"Review the entire codebase for security issues"

# Good — targeted with sub-agents
"Use sub-agents to review these areas in parallel:
1. src/auth/ for authentication vulnerabilities
2. src/api/ for injection risks
3. src/middleware/ for authorization bypasses
Report findings only."
```

### 49.7 Trigger Words

| Word | Effect |
|------|--------|
| `ultrathink` | Enables deep extended thinking for one turn |
| `plan` | Encourages Claude to plan before acting |
| `verify` | Encourages Claude to check its work |
| `step by step` | More methodical approach |
| `don't` / `never` | Strong constraints (use sparingly) |

---

## 50. Security Best Practices

### 50.1 Defense in Depth Layers

```
Layer 1: Permissions     → Control which tools Claude can use
Layer 2: Sandboxing      → OS-level filesystem/network isolation
Layer 3: Hooks           → Runtime validation before tool execution
Layer 4: CLAUDE.md       → Advisory rules (not enforced)
Layer 5: Code Review     → Automated review of Claude's changes
Layer 6: Git             → Version control as safety net
```

### 50.2 Minimum Security Setup

```json
// .claude/settings.json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Edit(~/.ssh/**)",
      "Edit(~/.bashrc)",
      "Edit(~/.zshrc)"
    ]
  },
  "sandbox": { "enabled": true }
}
```

### 50.3 Prompt Injection Protection

- **Sandboxing** prevents exfiltration even if Claude is manipulated
- **Network isolation** blocks unauthorized outbound connections
- **File restrictions** prevent modification of system files
- **Hook validation** catches dangerous commands before execution

### 50.4 Secret Management

- Never put secrets in CLAUDE.md or skills
- Use environment variables for API keys
- Use `.env` files (gitignored) for local secrets
- For CI/CD, use GitHub Secrets or GitLab CI/CD Variables
- MCP OAuth tokens are stored securely and refreshed automatically

### 50.5 Audit Trail

- All Claude actions are logged in session transcripts
- `~/.claude/projects/{project}/{sessionId}/` contains full history
- Git commits provide permanent record of all changes
- Hooks can log to external systems (Slack, Sentry, etc.)

---

## 51. Building Custom MCP Servers

You can build your own MCP servers to give Claude access to proprietary tools, internal APIs, or custom data sources.

### 51.1 Python (FastMCP)

```python
# my_server.py
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("my-company-tools")

@mcp.tool()
def get_customer(customer_id: str) -> dict:
    """Look up a customer by ID from our internal CRM."""
    # Your internal API call here
    return {"id": customer_id, "name": "Acme Corp", "plan": "enterprise"}

@mcp.tool()
def create_ticket(title: str, description: str, priority: str = "medium") -> dict:
    """Create a support ticket in our internal system."""
    # Your ticket system API call here
    return {"ticket_id": "TKT-1234", "status": "created"}

if __name__ == "__main__":
    mcp.run()
```

```bash
# Add to Claude Code
claude mcp add --transport stdio my-tools -- python my_server.py
```

### 51.2 TypeScript (MCP SDK)

```typescript
// server.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({ name: "my-tools", version: "1.0.0" });

server.tool("deploy_service", { service: "string", env: "string" },
  async ({ service, env }) => {
    // Your deployment logic here
    return { content: [{ type: "text", text: `Deployed ${service} to ${env}` }] };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

```bash
claude mcp add --transport stdio my-tools -- npx tsx server.ts
```

### 51.3 Monetization: Sell Custom MCP Servers

Build MCP servers for specific industries and sell as SaaS:
- **Healthcare**: FHIR/HL7 integration, EHR access
- **Finance**: Bloomberg/Reuters data, trading APIs
- **Legal**: Case management, document review
- **Real Estate**: MLS data, property records

Price: $49-$299/month per connection.

---

## 52. Building with the Agent SDK (Python/TypeScript)

### 52.1 Python Quick Start

```python
from claude_agent_sdk import AgentClient

client = AgentClient()

# Simple query
result = client.run("Explain the auth module in this project")
print(result.text)

# With tool approval callback
def approve_tool(tool_name, tool_input):
    if tool_name == "Edit":
        return True  # Auto-approve edits
    return input(f"Allow {tool_name}? (y/n): ") == "y"

result = client.run(
    "Fix the login bug",
    tool_approval=approve_tool,
    allowed_tools=["Read", "Edit", "Bash"],
    max_turns=10
)

# Structured output
from pydantic import BaseModel

class CodeReview(BaseModel):
    issues: list[str]
    severity: str
    suggestions: list[str]

result = client.run(
    "Review auth.py for security issues",
    output_schema=CodeReview
)
print(result.structured_output.issues)
```

### 52.2 TypeScript Quick Start

```typescript
import { AgentClient } from "@anthropic-ai/claude-agent-sdk";

const client = new AgentClient();

// Simple query
const result = await client.run("Explain the auth module");
console.log(result.text);

// Streaming
for await (const event of client.stream("Analyze this codebase")) {
  if (event.type === "text_delta") {
    process.stdout.write(event.text);
  }
}
```

### 52.3 Use Cases for the Agent SDK

| Use Case | Implementation |
|----------|---------------|
| **Custom code review bot** | Agent SDK + GitHub webhooks |
| **Automated testing service** | Agent SDK + CI/CD triggers |
| **Documentation generator** | Agent SDK + scheduled cron |
| **Migration automation** | Agent SDK + file processing pipeline |
| **Internal dev tools** | Agent SDK + company API integrations |

---

## 53. Performance Optimization Guide

### 53.1 Speed Optimization

| Strategy | Impact | How |
|----------|--------|-----|
| Use Sonnet for routine tasks | High | `/model sonnet` |
| Lower effort level | High | `/effort low` for simple tasks |
| Use Haiku for sub-agents | Medium | `model: haiku` in agent config |
| Disable extended thinking | Medium | `Option+T` or `MAX_THINKING_TOKENS=0` |
| Use prompt caching | Auto | Enabled by default |
| Install code intelligence plugins | Medium | Precise navigation vs. grep |

### 53.2 Context Optimization

| Strategy | Impact | How |
|----------|--------|-----|
| `/clear` between tasks | High | Prevents context pollution |
| Use sub-agents for research | High | Keeps main context clean |
| Move CLAUDE.md to skills | Medium | On-demand loading |
| Disable unused MCP servers | Medium | `/mcp` → disable |
| Use path-scoped rules | Medium | `.claude/rules/` with `paths` |
| Targeted compaction | Medium | `/compact Focus on X` |

### 53.3 Cost Optimization

| Strategy | Savings | How |
|----------|---------|-----|
| Sonnet instead of Opus | ~5x cheaper | `/model sonnet` for most tasks |
| Haiku for sub-agents | ~25x cheaper than Opus | `model: haiku` |
| Lower effort level | 2-3x on thinking tokens | `/effort low` |
| Filter verbose output with hooks | 10-100x on context | PreToolUse hook to grep test output |
| Specific prompts | 2-5x fewer file reads | "Fix auth.ts line 42" vs. "improve codebase" |
| Plan mode first | Prevents re-work | `Shift+Tab` before implementing |

### 53.4 Token Budget by Task Type

| Task | Typical Tokens | Recommended Model |
|------|---------------|-------------------|
| Quick question | 5K-15K | Haiku or Sonnet |
| Bug fix | 20K-50K | Sonnet |
| Feature implementation | 50K-150K | Sonnet or opusplan |
| Architecture planning | 30K-80K | Opus |
| Large refactor | 100K-500K | Sonnet with sub-agents |
| Full codebase review | 200K-1M | Opus[1m] or agent team |

---

> **This tutorial covers every feature of Claude Code as of March 2026.**
> Star the repo and check back — new features are added as Claude Code evolves.
>
> Built with Claude Code (Opus 4.6). Continuously updated.
> Repository: [github.com/sscien/open_claw](https://github.com/sscien/open_claw)






























