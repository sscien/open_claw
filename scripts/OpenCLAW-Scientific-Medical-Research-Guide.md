# OpenCLAW for Scientific and Medical Research

## A Comprehensive Guide to Enhancing Research Workflows with a Self-Hosted AI Assistant

OpenCLAW ([github.com/openclaw/openclaw](https://github.com/openclaw/openclaw)) is a self-hosted personal AI assistant that runs on your own infrastructure and connects across 12+ messaging platforms. Its combination of multi-channel messaging, voice interaction, browser automation, scheduled tasks, webhooks, and an extensible skills system via ClawHub makes it a powerful backbone for scientific and medical research operations.

This document details ten high-impact use cases, each with concrete setup steps, feature mappings, and estimated time savings.

---

## Platform Quick Reference

| Capability | Implementation |
|---|---|
| Gateway | WebSocket control plane at `ws://127.0.0.1:18789` |
| Messaging | WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, MS Teams, Matrix, WebChat |
| Voice | Voice Wake + Talk Mode (macOS, iOS, Android) with ElevenLabs TTS |
| Browser | Dedicated Chromium instance via Chrome DevTools Protocol (CDP) |
| Visual Workspace | Canvas with A2UI (agent-driven UI) |
| Scheduling | Built-in cron jobs and wakeups |
| Events | Webhooks, Gmail Pub/Sub |
| Skills | `~/.openclaw/workspace/skills/<name>/SKILL.md` + ClawHub registry |
| Model | Anthropic Claude Opus 4.6 recommended (long-context, prompt-injection resistant) |

---

## 1. Literature Monitoring and Alerts via Messaging Channels

### What It Does

Continuously monitors PubMed, arXiv, bioRxiv, and other preprint servers for new publications matching your research keywords, MeSH terms, or author lists. Delivers structured alerts with title, abstract summary, relevance score, and direct links to your preferred messaging channel.

### Which OpenCLAW Features Enable It

- **Cron jobs**: Schedule scans at defined intervals (e.g., daily at 7 AM, every 6 hours)
- **Browser automation (CDP)**: Navigate PubMed, arXiv, and bioRxiv search pages; scrape RSS feeds or API endpoints
- **Multi-channel routing**: Deliver alerts to Slack (for the lab team), Telegram (for personal mobile alerts), or Discord (for a broader research community)
- **Webhooks**: Trigger scans on-demand from external systems (e.g., when a collaborator flags a new topic)

### Step-by-Step Setup

1. **Install OpenCLAW and configure your gateway:**
   ```bash
   npm install -g openclaw@latest
   openclaw onboard --install-daemon
   ```

2. **Create a literature-monitor workspace skill:**
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/lit-monitor
   ```

3. **Write the skill definition** in `~/.openclaw/workspace/skills/lit-monitor/SKILL.md`:
   ```markdown
   # Literature Monitor

   ## Purpose
   Monitor scientific databases for new publications matching configured search terms.

   ## Triggers
   - Cron: `0 7 * * *` (daily at 7 AM)
   - Webhook: POST /hooks/lit-monitor with JSON body `{"query": "..."}`

   ## Behavior
   1. For each configured search query, use the browser tool to fetch results from:
      - PubMed E-utilities API: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi`
      - arXiv API: `http://export.arxiv.org/api/query`
   2. Parse results, deduplicate against previously seen PMIDs/arXiv IDs
      (stored in `~/.openclaw/workspace/data/lit-monitor/seen.json`)
   3. For each new paper, generate a 2-3 sentence summary of the abstract
   4. Format as a structured message with: title, authors, journal, summary, link
   5. Send to configured channels via session messaging

   ## Configuration
   Search terms and target channels are defined in
   `~/.openclaw/workspace/data/lit-monitor/config.json`
   ```

4. **Configure search terms and channels** in `~/.openclaw/workspace/data/lit-monitor/config.json`:
   ```json
   {
     "queries": [
       {"source": "pubmed", "term": "CRISPR AND gene therapy AND 2026[pdat]", "mesh": ["Gene Editing"]},
       {"source": "arxiv", "term": "cat:q-bio.GN+AND+single+cell+sequencing", "category": "genomics"}
     ],
     "channels": {
       "slack": "#literature-alerts",
       "telegram": "personal"
     },
     "max_results_per_query": 20,
     "summary_length": "brief"
   }
   ```

5. **Connect your Slack and Telegram channels** via `openclaw onboard` or by editing `~/.openclaw/openclaw.json` to include channel credentials.

6. **Test the skill** by messaging OpenCLAW: "Run the literature monitor now."

### Estimated Time Savings

Manual literature review typically consumes 3-5 hours/week for an active researcher. Automated monitoring with pre-summarized alerts reduces this to 30-45 minutes of reviewing curated results. **Savings: ~3-4 hours/week per researcher.**

### Relevant ClawHub Skills

- `blogwatcher` -- monitors web pages for changes; adaptable for preprint server watch pages
- `summarize` -- built-in summarization skill for condensing long abstracts
- `coding-agent` -- can help write custom API parsing scripts for niche databases

---

## 2. Automated PubMed/arXiv Scanning and Summarization

### What It Does

Goes beyond simple alerts by performing deep analysis of new publications: extracting methods, key findings, statistical significance, comparing results against your existing knowledge base, and generating structured literature review entries ready for citation managers.

### Which OpenCLAW Features Enable It

- **Browser automation (CDP)**: Full-page rendering of papers, PDF download and parsing
- **Claude Opus 4.6 long-context**: Process entire papers (up to full-text when available via PMC) in a single context window
- **Canvas (A2UI)**: Visual dashboard showing paper summaries, trend graphs, citation networks
- **Cron + webhooks**: Scheduled deep-dives and on-demand analysis

### Step-by-Step Setup

1. **Create the scanning skill:**
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/paper-scanner
   ```

2. **Define `SKILL.md`** with instructions for the agent to:
   - Accept a PubMed query or arXiv category
   - Use browser automation to fetch search results from PubMed E-utilities or arXiv API
   - For each result, attempt to retrieve full text from PubMed Central (PMC)
   - If full text is unavailable, work with the abstract
   - Extract structured data: hypothesis, methods, sample size, key findings, limitations, statistical tests used
   - Generate a citation in your preferred format (APA, Vancouver, BibTeX)
   - Store results in `~/.openclaw/workspace/data/paper-scanner/reviews/`
   - Push a summary to Canvas for visual browsing

3. **Configure the PDF handling pipeline.** OpenCLAW's browser can download PDFs. Add to your skill instructions:
   ```markdown
   ## PDF Processing
   When full text is available as PDF:
   1. Download via browser to workspace temp directory
   2. Use the nano-pdf skill to extract text content
   3. Process extracted text through the summarization pipeline
   ```

4. **Set up Canvas visualization.** The agent can push structured data to Canvas:
   ```markdown
   ## Canvas Output
   Push a card to Canvas for each analyzed paper containing:
   - Title and authors
   - Relevance score (1-10) based on keyword match density
   - Methods summary
   - Key findings (bullet points)
   - Link to full review in workspace
   ```

5. **Schedule weekly deep scans** via cron: `0 2 * * 0` (Sunday at 2 AM)

6. **Trigger ad-hoc scans** via any channel: "Scan PubMed for papers on mRNA vaccine stability published this week and summarize the top 10."

### Estimated Time Savings

A systematic literature scan for a review paper takes 15-25 hours. Automated scanning with structured extraction reduces the initial pass to 2-3 hours of reviewing pre-analyzed summaries. **Savings: ~12-20 hours per literature review cycle.**

### Relevant ClawHub Skills

- `nano-pdf` -- PDF text extraction for processing downloaded papers
- `summarize` -- core summarization capability
- `canvas` -- visual workspace for paper dashboards
- `coding-agent` -- custom scripts for BibTeX export, citation formatting

---

## 3. Clinical Trial Data Management

### What It Does

Tracks clinical trial registrations (ClinicalTrials.gov), monitors status changes, manages enrollment data, generates status reports, and alerts the team to protocol amendments, safety signals, or milestone deadlines.

### Which OpenCLAW Features Enable It

- **Browser automation**: Navigate ClinicalTrials.gov API (`https://clinicaltrials.gov/api/v2/studies`), scrape trial status pages
- **Cron scheduling**: Daily checks for trial status updates
- **Multi-channel alerts**: Critical safety alerts via WhatsApp/Signal (immediate), routine updates via Slack/Teams (async)
- **Canvas**: Visual trial dashboard with enrollment progress, timeline, and milestone tracking
- **Webhooks**: Receive notifications from EDC (Electronic Data Capture) systems

### Step-by-Step Setup

1. **Create the clinical-trials skill:**
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/clinical-trials
   ```

2. **Define monitoring targets** in a configuration file:
   ```json
   {
     "trials": [
       {
         "nct_id": "NCT05XXXXXX",
         "name": "Phase II mRNA Vaccine Trial",
         "milestones": [
           {"event": "enrollment_complete", "target_date": "2026-06-01"},
           {"event": "interim_analysis", "target_date": "2026-09-15"}
         ],
         "alert_channels": {
           "safety": ["whatsapp:PI_phone", "signal:safety_officer"],
           "routine": ["slack:#trial-updates", "teams:clinical-ops"]
         }
       }
     ],
     "check_interval_cron": "0 8 * * *"
   }
   ```

3. **Configure the SKILL.md** to instruct the agent to:
   - Query the ClinicalTrials.gov API daily for each monitored NCT ID
   - Compare current status against last known status (stored locally)
   - Detect changes in: overall status, enrollment count, protocol amendments, results postings
   - Route alerts based on severity: safety signals go to WhatsApp/Signal immediately; routine updates go to Slack/Teams
   - Generate weekly summary reports pushed to Canvas
   - Track milestone deadlines and send reminders 30, 14, and 7 days before each

4. **Set up a webhook endpoint** for your EDC system to push enrollment events:
   ```markdown
   ## Webhook: EDC Integration
   Accept POST to /hooks/clinical-trials/enrollment with payload:
   {"nct_id": "...", "event": "new_enrollment", "count": N, "site": "..."}
   Update local tracking data and notify the team if enrollment milestones are hit.
   ```

5. **Build a Canvas dashboard** that the agent maintains with:
   - Enrollment progress bars per trial
   - Timeline with upcoming milestones
   - Recent status changes log
   - Safety event tracker

### Estimated Time Savings

Clinical trial coordinators spend 5-8 hours/week on status monitoring and reporting. Automated tracking with intelligent alerting reduces this to 1-2 hours of reviewing dashboards and responding to flagged items. **Savings: ~4-6 hours/week per trial coordinator.**

### Relevant ClawHub Skills

- `canvas` -- visual dashboard for trial status
- `summarize` -- condensing trial status reports
- `coding-agent` -- custom API integration scripts for EDC systems

---

## 4. Lab Notebook Integration

### What It Does

Provides a conversational interface for logging experiments, observations, and results into a structured digital lab notebook. Researchers can dictate entries via voice during experiments, attach photos from lab devices, and have the agent auto-format entries with timestamps, protocol references, and metadata.

### Which OpenCLAW Features Enable It

- **Voice Wake + Talk Mode**: Hands-free dictation during wet lab work (macOS, iOS, Android)
- **Device nodes (iOS/Android)**: Camera capture for gel images, plate photos, equipment readings
- **Canvas**: Visual experiment timeline and notebook viewer
- **Multi-channel input**: Log entries from any channel -- quick notes via Telegram, detailed entries via WebChat, photos via WhatsApp
- **Workspace file system**: Persistent storage in `~/.openclaw/workspace/data/lab-notebook/`

### Step-by-Step Setup

1. **Create the lab-notebook skill:**
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/lab-notebook
   mkdir -p ~/.openclaw/workspace/data/lab-notebook/entries
   mkdir -p ~/.openclaw/workspace/data/lab-notebook/protocols
   mkdir -p ~/.openclaw/workspace/data/lab-notebook/media
   ```

2. **Define the SKILL.md** with structured entry format:
   ```markdown
   # Lab Notebook

   ## Entry Format
   Each entry is stored as a JSON file with:
   - `id`: UUID
   - `timestamp`: ISO 8601
   - `researcher`: name from session identity
   - `project`: project tag
   - `protocol_ref`: link to protocol document
   - `type`: observation | result | procedure | note
   - `content`: free-text entry (cleaned from voice transcription)
   - `media`: array of attached file paths
   - `tags`: auto-extracted keywords
   - `channel_source`: which messaging channel the entry came from

   ## Voice Entry Processing
   When receiving voice input:
   1. Transcribe using Talk Mode
   2. Clean transcription: fix scientific terminology, chemical formulas, gene names
   3. Extract structured fields (project, protocol, type) from context
   4. Confirm entry with the researcher before saving
   5. Store in workspace and push summary to Canvas timeline

   ## Photo Attachment
   When receiving images from device nodes:
   1. Save to media directory with timestamp filename
   2. Auto-describe the image content (gel bands, plate colonies, readings)
   3. Link to the current or most recent notebook entry
   ```

3. **Configure voice interaction** on your lab device (iPad or phone):
   - Install the OpenCLAW companion app (iOS or Android)
   - Pair the device node with your gateway
   - Enable Voice Wake with a custom wake word (e.g., "Hey Lab")
   - Configure ElevenLabs for natural TTS confirmation responses

4. **Set up protocol templates** in `~/.openclaw/workspace/data/lab-notebook/protocols/`:
   ```json
   {
     "protocol_id": "PCR-001",
     "name": "Standard PCR Protocol",
     "steps": ["Prepare master mix", "Add template DNA", "Run thermocycler", "Gel electrophoresis"],
     "expected_outputs": ["Gel image", "Band size confirmation"]
   }
   ```

5. **Use from any channel:**
   - Voice in lab: "Hey Lab, log observation for project CRISPR-KO: transfection efficiency looks about 60% based on GFP fluorescence. Plate 3 shows higher expression than plates 1 and 2."
   - Telegram quick note: "Lab note: PCR-001 cycle complete, running gel now"
   - WhatsApp photo: Send gel image with caption "Gel for PCR-001 run 7"

### Estimated Time Savings

Manual lab notebook entry takes 20-40 minutes per experiment session. Voice-driven logging with auto-formatting reduces this to 5-10 minutes of dictation plus a quick review. **Savings: ~15-30 minutes per experiment session, or 2-5 hours/week for active bench researchers.**

### Relevant ClawHub Skills

- `camsnap` -- camera capture from device nodes for lab photos
- `apple-notes` / `bear-notes` / `obsidian` / `notion` -- sync notebook entries to your preferred note-taking app
- `canvas` -- visual experiment timeline
- `openai-whisper` or `openai-whisper-api` -- enhanced voice transcription for scientific terminology
- `sherpa-onnx-tts` -- local TTS for voice confirmations without cloud dependency

---

## 5. Research Collaboration Across Teams via Slack/Discord/Teams

### What It Does

Acts as an intelligent research coordinator across distributed teams. Manages shared literature libraries, coordinates experiment schedules, translates between disciplines (e.g., explaining bioinformatics results to clinicians), maintains a shared knowledge base, and ensures no critical updates are missed across time zones.

### Which OpenCLAW Features Enable It

- **Slack (Bolt), Discord (discord.js), MS Teams channels**: Native integration with team communication platforms
- **Session isolation**: Separate contexts for different projects/teams while sharing a single gateway
- **Multi-channel routing**: Route specific topics to specific channels automatically
- **Canvas**: Shared visual workspace for cross-team dashboards
- **Cron**: Scheduled standup summaries, weekly digests

### Step-by-Step Setup

1. **Configure multi-channel access** in `~/.openclaw/openclaw.json`:
   ```json
   {
     "channels": {
       "slack": {
         "enabled": true,
         "workspaces": {
           "lab-team": {
             "channels": ["#general", "#experiments", "#literature", "#data-analysis"]
           }
         }
       },
       "discord": {
         "enabled": true,
         "servers": {
           "research-consortium": {
             "channels": ["#cross-team", "#bioinformatics", "#clinical"]
           }
         }
       },
       "teams": {
         "enabled": true,
         "channels": ["Clinical Operations", "Data Science"]
       }
     }
   }
   ```

2. **Create a collaboration-hub skill** with these behaviors:
   ```markdown
   # Research Collaboration Hub

   ## Cross-Team Digest
   - Cron: `0 9 * * 1-5` (weekdays at 9 AM)
   - Scan all monitored channels for messages from the past 24 hours
   - Generate a digest grouped by topic: literature, experiments, data, admin
   - Post digest to each team's primary channel

   ## Knowledge Translation
   When a message in a specialized channel is flagged with a reaction (e.g., :question:):
   - Detect the source discipline context
   - Rewrite the content for a general scientific audience
   - Post the translation as a thread reply

   ## Shared Literature Library
   When a paper link is shared in any channel:
   - Extract metadata (title, authors, DOI)
   - Add to shared library in workspace
   - Cross-post a summary to #literature channel
   - Check for duplicates against existing library

   ## Experiment Coordination
   Maintain a shared experiment calendar in workspace data.
   When someone posts about scheduling an experiment:
   - Check for equipment/resource conflicts
   - Suggest available time slots
   - Notify affected team members
   ```

3. **Set up access control** so the assistant responds appropriately in group channels:
   ```json
   {
     "security": {
       "group_channels": {
         "mode": "allowlist",
         "respond_to_mentions": true,
         "respond_to_threads": true,
         "silent_monitoring": ["#literature"]
       }
     }
   }
   ```

4. **Deploy the shared Canvas dashboard** accessible to all team members via WebChat, showing:
   - Active experiments across all teams
   - Shared literature pipeline
   - Cross-team meeting schedule
   - Resource utilization

### Estimated Time Savings

Research teams lose 5-10 hours/week to fragmented communication, missed updates, and context-switching between platforms. A centralized AI coordinator reduces this to 2-3 hours of focused collaboration. **Savings: ~3-7 hours/week per team.**

### Relevant ClawHub Skills

- `slack` -- native Slack integration and action handling
- `discord` -- Discord-specific features and bot commands
- `summarize` -- digest generation
- `gh-issues` / `github` / `trello` -- project tracking integration
- `notion` / `obsidian` -- shared knowledge base sync

---

## 6. Voice-Activated Lab Assistant (Hands-Free During Experiments)

### What It Does

Provides a completely hands-free AI assistant for researchers working at the bench. Answers questions about protocols, performs unit conversions, sets timers, logs observations, looks up reagent information, and guides through multi-step procedures -- all via voice while the researcher's hands are occupied with samples, pipettes, or sterile equipment.

### Which OpenCLAW Features Enable It

- **Voice Wake**: Always-on listening with custom wake word on macOS, iOS, Android
- **Talk Mode**: Continuous conversational voice interaction with ElevenLabs TTS
- **Device nodes**: iOS/Android devices positioned in the lab as dedicated voice terminals
- **Canvas**: Display protocol steps, timers, and reference data on a nearby screen
- **Session persistence**: Maintains context across a full experiment session

### Step-by-Step Setup

1. **Set up a dedicated lab voice terminal:**
   - Use an iPad or Android tablet mounted near the bench
   - Install the OpenCLAW companion app
   - Pair with your gateway: the device node connects via WebSocket
   - Enable Voice Wake with a lab-specific wake word

2. **Configure ElevenLabs for clear lab audio:**
   ```json
   {
     "voice": {
       "provider": "elevenlabs",
       "voice_id": "clear-scientific",
       "speed": 1.0,
       "stability": 0.7,
       "wake_word": "Hey Lab",
       "always_on": true,
       "noise_cancellation": true
     }
   }
   ```

3. **Create a lab-assistant skill** optimized for voice interaction:
   ```markdown
   # Voice Lab Assistant

   ## Core Capabilities
   - **Protocol guidance**: Read out protocol steps one at a time, wait for "next step"
   - **Unit conversions**: Instant molarity, dilution, volume calculations
   - **Timer management**: "Set a 5-minute incubation timer" with audio alerts
   - **Reagent lookup**: Query stored reagent database for concentrations, storage conditions, hazards
   - **Observation logging**: Dictate observations directly into the lab notebook skill
   - **Safety queries**: Immediate access to SDS information for chemicals in use

   ## Voice Response Rules
   - Keep responses under 30 seconds of speech
   - Use clear, unambiguous language
   - Spell out numbers and units explicitly
   - Confirm critical values by repeating them
   - For calculations, state the result and the formula used

   ## Context Persistence
   Maintain awareness of:
   - Current protocol being followed
   - Step number within the protocol
   - Active timers
   - Reagents mentioned in the current session
   ```

4. **Pre-load protocol and reagent data** into the workspace:
   ```bash
   # Store protocols
   cp lab-protocols/*.json ~/.openclaw/workspace/data/lab-assistant/protocols/

   # Store reagent database
   cp reagent-db.json ~/.openclaw/workspace/data/lab-assistant/reagents.json
   ```

5. **Example voice interactions:**
   - "Hey Lab, start PCR protocol 001."
   - "Hey Lab, what's the annealing temperature for primer set Alpha-7?"
   - "Hey Lab, convert 500 micrograms per milliliter to molarity for BSA."
   - "Hey Lab, set a timer for 37 degrees incubation, 30 minutes."
   - "Hey Lab, log observation: colonies on plate 4 appear blue, indicating successful transformation."

### Estimated Time Savings

Stopping to look up information, write notes, or use a calculator during experiments adds 30-60 minutes per session. Voice interaction eliminates these interruptions entirely. **Savings: ~30-60 minutes per experiment session, plus reduced contamination risk from not touching devices.**

### Relevant ClawHub Skills

- `openai-whisper` / `openai-whisper-api` -- enhanced speech recognition for scientific terms
- `sherpa-onnx-tts` -- local text-to-speech without cloud latency
- `apple-reminders` / `things-mac` -- timer and reminder integration
- `camsnap` -- voice-triggered photo capture ("Hey Lab, take a photo of the gel")

---

## 7. Automated Data Analysis Pipelines Triggered via Chat

### What It Does

Allows researchers to trigger complex data analysis workflows by sending a simple message or uploading a data file to any connected channel. The agent orchestrates the pipeline: validates input data, runs analysis scripts, generates visualizations, and returns results -- all without the researcher needing to SSH into a server or open a Jupyter notebook.

### Which OpenCLAW Features Enable It

- **Multi-channel input**: Upload CSV/FASTQ/FASTA files via Slack, Telegram, WhatsApp, or WebChat
- **Browser automation (CDP)**: Interact with web-based analysis tools (Galaxy, BLAST, etc.)
- **Coding agent capability**: Write and execute analysis scripts on the fly
- **Canvas**: Display results, charts, and interactive visualizations
- **Cron**: Schedule recurring analyses (e.g., nightly sequencing QC)
- **Webhooks**: Trigger pipelines from instrument software or LIMS

### Step-by-Step Setup

1. **Create the data-pipeline skill:**
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/data-pipeline
   mkdir -p ~/.openclaw/workspace/data/pipelines/{input,output,scripts,logs}
   ```

2. **Define analysis templates** in the SKILL.md:
   ```markdown
   # Data Analysis Pipeline

   ## Supported Analyses
   1. **RNA-seq differential expression**: Input FASTQ or count matrix -> DESeq2 -> volcano plot + gene list
   2. **Statistical summary**: Input CSV -> descriptive stats, normality tests, group comparisons
   3. **Plate reader analysis**: Input raw plate data -> standard curve fitting, concentration calculation
   4. **Sequence alignment**: Input FASTA -> BLAST search -> alignment summary
   5. **Image quantification**: Input microscopy images -> cell counting, fluorescence intensity

   ## Workflow
   1. User uploads file or provides file path via any channel
   2. Agent detects file type and suggests appropriate analysis
   3. User confirms or specifies desired analysis
   4. Agent executes pipeline:
      a. Validate input data format and quality
      b. Run analysis using coding-agent to write/execute scripts
      c. Generate output files (tables, plots, reports)
      d. Push results to Canvas for interactive viewing
      e. Send summary to the originating channel
   5. Store all inputs, outputs, and logs for reproducibility

   ## Execution Environment
   Scripts execute in the host environment. Ensure R, Python (with scipy, pandas,
   matplotlib, seaborn), and bioinformatics tools are installed.
   ```

3. **Pre-install analysis dependencies** on the gateway host:
   ```bash
   # Python scientific stack
   pip install pandas numpy scipy matplotlib seaborn scikit-learn biopython

   # R packages (if using R-based pipelines)
   Rscript -e 'install.packages(c("DESeq2", "ggplot2", "pheatmap"), repos="https://cloud.r-project.org")'
   ```

4. **Configure webhook triggers** for instrument integration:
   ```markdown
   ## Webhook: Instrument Data
   Accept POST to /hooks/data-pipeline/new-data with payload:
   {"instrument": "plate_reader", "file_path": "/data/exports/run_2026-02-19.csv", "analysis": "plate_reader"}
   Automatically start the appropriate pipeline and notify the researcher when complete.
   ```

5. **Example chat interactions:**
   - Upload a CSV to Slack: "Analyze this -- compare treatment vs control groups, column C is the grouping variable"
   - Telegram message: "Run DESeq2 on the latest RNA-seq counts in /data/rnaseq/experiment_42/"
   - Discord: "BLAST this sequence against nr: ATGCGATCGATCGATCG..."

### Estimated Time Savings

Setting up and running analysis scripts manually takes 1-4 hours per dataset depending on complexity. Chat-triggered pipelines with pre-configured templates reduce this to 5-15 minutes of interaction. **Savings: ~1-3 hours per analysis run, more for recurring analyses.**

### Relevant ClawHub Skills

- `coding-agent` -- writes and executes analysis scripts dynamically
- `canvas` -- displays results and interactive visualizations
- `nano-pdf` -- generates PDF reports from analysis outputs
- `summarize` -- creates plain-language summaries of statistical results

---

## 8. Patient Data Anonymization Workflows

### What It Does

Provides a structured, auditable workflow for de-identifying patient data before it enters research pipelines. Detects and removes or replaces Protected Health Information (PHI) in datasets, documents, and images. Maintains an audit trail and ensures compliance with HIPAA, GDPR, and institutional IRB requirements.

### Which OpenCLAW Features Enable It

- **Session isolation**: Anonymization runs in a sandboxed session with strict access controls
- **Workspace file system**: Secure local storage -- data never leaves your infrastructure (self-hosted)
- **Multi-channel workflow**: Receive anonymization requests via secure channels (Signal, encrypted Slack)
- **Canvas**: Visual review interface for verifying anonymization completeness
- **Coding agent**: Custom de-identification scripts tailored to your data formats
- **Audit logging**: All operations logged in workspace for compliance

### Step-by-Step Setup

1. **Create the anonymization skill with strict security:**
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/phi-anonymizer
   mkdir -p ~/.openclaw/workspace/data/phi-anonymizer/{input,output,audit,mappings}
   ```

2. **Define the SKILL.md** with HIPAA-aligned rules:
   ```markdown
   # PHI Anonymization Workflow

   ## HIPAA Safe Harbor De-identification
   Remove or replace all 18 HIPAA identifiers:
   1. Names -> [PATIENT_NAME_001]
   2. Geographic data smaller than state -> [LOCATION]
   3. Dates (except year) for ages >89 -> [DATE]
   4. Phone numbers -> [PHONE]
   5. Fax numbers -> [FAX]
   6. Email addresses -> [EMAIL]
   7. SSN -> [SSN]
   8. MRN -> [MRN]
   9. Health plan numbers -> [PLAN_ID]
   10. Account numbers -> [ACCOUNT]
   11. Certificate/license numbers -> [LICENSE]
   12. Vehicle identifiers -> [VEHICLE]
   13. Device identifiers -> [DEVICE_ID]
   14. URLs -> [URL]
   15. IP addresses -> [IP]
   16. Biometric identifiers -> [BIOMETRIC]
   17. Full-face photos -> [IMAGE_REDACTED]
   18. Any other unique identifier -> [UNIQUE_ID]

   ## Workflow
   1. Receive dataset via secure channel (Signal or encrypted Slack only)
   2. Validate file format (CSV, JSON, FHIR, free-text clinical notes)
   3. Scan all fields for PHI using pattern matching and NER
   4. Generate anonymization report showing all detected PHI
   5. Push report to Canvas for human review BEFORE applying changes
   6. Wait for explicit approval from authorized user
   7. Apply de-identification transformations
   8. Generate consistent pseudonyms (same patient -> same pseudonym across datasets)
   9. Store mapping table in encrypted workspace (for re-identification if authorized)
   10. Log all actions to audit trail

   ## Security Rules
   - NEVER send raw PHI to any external API or channel
   - All processing happens locally on the gateway host
   - Mapping tables require separate authentication to access
   - Audit logs are append-only
   ```

3. **Configure channel restrictions** so PHI workflows only accept input from secure channels:
   ```json
   {
     "skills": {
       "phi-anonymizer": {
         "allowed_channels": ["signal", "webchat"],
         "require_confirmation": true,
         "audit_log": true
       }
     }
   }
   ```

4. **Set up the Canvas review interface:**
   - The agent pushes a side-by-side view: original (with PHI highlighted) vs. anonymized
   - Reviewer approves, requests changes, or flags items for manual review
   - Only after approval does the agent write the anonymized output

5. **Example workflow:**
   - Signal message: "Anonymize the clinical notes dataset at /data/clinical/notes_batch_47.csv"
   - Agent scans, finds 342 PHI instances across 89 records
   - Canvas shows: highlighted PHI in original, proposed replacements
   - Researcher reviews on Canvas, approves
   - Agent produces anonymized dataset at `/data/clinical/notes_batch_47_anon.csv`
   - Audit log records: who requested, when, what was changed, who approved

### Estimated Time Savings

Manual PHI de-identification takes 2-5 minutes per record for clinical notes. For a 500-record dataset, that is 16-40 hours. Automated detection with human-in-the-loop review reduces this to 2-4 hours (mostly review time). **Savings: ~14-36 hours per dataset.**

### Relevant ClawHub Skills

- `coding-agent` -- custom NER and regex patterns for PHI detection
- `canvas` -- visual review interface for anonymization verification
- `nano-pdf` -- process PDF clinical documents

---

## 9. Grant Writing Assistance

### What It Does

Assists researchers throughout the grant writing process: generating first drafts of specific sections, ensuring compliance with funder formatting requirements, checking for internal consistency, managing references, calculating budgets, and providing iterative feedback on drafts. Works as a collaborative writing partner accessible from any device or channel.

### Which OpenCLAW Features Enable It

- **Long-context Claude Opus 4.6**: Process entire grant applications (often 50-100 pages with appendices) in a single context
- **Multi-channel access**: Draft on desktop via WebChat, review on mobile via Telegram, discuss with co-PIs via Slack
- **Browser automation**: Look up funder requirements, check formatting guidelines, search for preliminary data references
- **Canvas**: Visual outline builder, budget calculator, timeline generator
- **Workspace persistence**: Maintain grant drafts across sessions with full version history
- **Cron**: Deadline reminders and progress check-ins

### Step-by-Step Setup

1. **Create the grant-writer skill:**
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/grant-writer
   mkdir -p ~/.openclaw/workspace/data/grants/{active,templates,references}
   ```

2. **Define the SKILL.md:**
   ```markdown
   # Grant Writing Assistant

   ## Capabilities
   - **Section drafting**: Generate first drafts of Specific Aims, Significance,
     Innovation, Approach, Budget Justification, Biosketches
   - **Funder compliance**: Check formatting against NIH, NSF, ERC, Wellcome Trust guidelines
   - **Consistency checking**: Verify aims align with methods, timeline matches scope,
     budget matches proposed activities
   - **Reference management**: Suggest relevant citations, format reference lists
   - **Budget calculation**: Compute personnel costs, equipment, supplies, indirect costs
   - **Deadline tracking**: Cron-based reminders for submission deadlines

   ## Workflow for New Grant
   1. User provides: funder, mechanism (e.g., NIH R01), topic, key aims
   2. Agent creates project folder in workspace
   3. Agent generates outline and pushes to Canvas for review
   4. Iterative drafting: user requests sections, agent drafts, user revises
   5. Agent maintains master document with all sections
   6. Pre-submission checklist: formatting, page limits, required sections, budget totals

   ## Funder Templates
   Pre-loaded templates for:
   - NIH (R01, R21, R03, K08, K23, F31, F32, T32)
   - NSF (CAREER, Standard, Collaborative)
   - ERC (Starting, Consolidator, Advanced)
   - DOD (CDMRP mechanisms)
   Each template includes section requirements, page limits, and formatting rules.
   ```

3. **Load funder templates** by instructing the agent to use browser automation to fetch current guidelines:
   - NIH: `https://grants.nih.gov/grants/how-to-apply-application-guide.html`
   - NSF: `https://www.nsf.gov/bfa/dias/policy/papp/pappg24_1/`

4. **Set up deadline tracking:**
   ```json
   {
     "grants": {
       "active": [
         {
           "title": "mRNA Stability Mechanisms in Neurodegeneration",
           "funder": "NIH",
           "mechanism": "R01",
           "deadline": "2026-06-05",
           "reminders": ["30d", "14d", "7d", "3d", "1d"]
         }
       ]
     }
   }
   ```

5. **Example interactions across channels:**
   - WebChat (desktop, deep work): "Draft the Significance section for my R01. Focus on the gap in understanding mRNA stability in ALS motor neurons. Reference the preliminary data from our 2025 Nature Neuroscience paper."
   - Telegram (mobile, quick check): "What's the page limit for the Approach section in an NIH R01?"
   - Slack (team coordination): "@openclaw Can you check if the budget in Section G matches the personnel effort described in the Approach?"

### Estimated Time Savings

Grant writing typically takes 80-200 hours over 2-3 months. AI-assisted drafting with iterative refinement can reduce first-draft generation by 40-50%, saving 30-80 hours. Compliance checking and formatting save an additional 5-10 hours. **Savings: ~35-90 hours per grant application.**

### Relevant ClawHub Skills

- `coding-agent` -- budget calculation scripts, formatting automation
- `canvas` -- visual outline and timeline builder
- `nano-pdf` -- process PDF guidelines and generate final PDF drafts
- `summarize` -- condense preliminary data and literature for background sections
- `notion` / `obsidian` -- sync grant drafts with knowledge management tools

---

## 10. Regulatory Document Preparation

### What It Does

Assists with preparing regulatory submissions for clinical research: IRB/ethics applications, IND (Investigational New Drug) applications, FDA 510(k) submissions, CE marking documentation, and annual progress reports. Maintains templates, tracks regulatory timelines, ensures cross-document consistency, and generates submission-ready documents.

### Which OpenCLAW Features Enable It

- **Long-context processing**: Handle large regulatory documents (IND applications can exceed 1000 pages across modules)
- **Browser automation**: Access FDA databases, check guidance documents, verify regulatory requirements
- **Canvas**: Visual document assembly workspace, checklist tracking
- **Multi-channel coordination**: Regulatory affairs team on Slack/Teams, PI notifications via Telegram/WhatsApp
- **Cron**: Regulatory deadline tracking, annual report reminders
- **Workspace persistence**: Version-controlled document drafts with full history

### Step-by-Step Setup

1. **Create the regulatory-docs skill:**
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/regulatory-docs
   mkdir -p ~/.openclaw/workspace/data/regulatory/{templates,submissions,checklists}
   ```

2. **Define the SKILL.md:**
   ```markdown
   # Regulatory Document Assistant

   ## Supported Submission Types
   1. **IRB/Ethics Applications**: Initial review, amendments, continuing review, adverse event reports
   2. **FDA IND Applications**: Module 1 (Admin), Module 2 (Summaries), Module 3 (Quality),
      Module 4 (Nonclinical), Module 5 (Clinical)
   3. **FDA 510(k)**: Predicate device comparison, substantial equivalence arguments
   4. **Annual Progress Reports**: Enrollment updates, safety summaries, protocol deviations
   5. **DSMB Reports**: Data safety monitoring board packages

   ## Workflow
   1. User specifies submission type and provides source materials
   2. Agent loads appropriate template and regulatory requirements
   3. Agent drafts sections using provided materials and regulatory language
   4. Cross-reference check: ensure consistency across all sections
   5. Generate submission checklist on Canvas
   6. Iterative review with regulatory affairs team via Slack/Teams
   7. Final formatting and assembly

   ## Regulatory Intelligence
   - Use browser automation to check FDA guidance documents at fda.gov
   - Monitor Federal Register for relevant regulatory changes
   - Track ICH guidelines for international submissions
   - Maintain a local database of regulatory precedents and templates

   ## Compliance Checks
   - Verify all required sections are present and complete
   - Check cross-references between documents
   - Validate that cited studies match the reference list
   - Ensure adverse event reporting follows current FDA/EMA requirements
   - Flag any inconsistencies between protocol and submission documents
   ```

3. **Load institutional templates:**
   ```bash
   # Copy your institution's IRB templates
   cp /path/to/irb-templates/* ~/.openclaw/workspace/data/regulatory/templates/irb/

   # Copy FDA submission templates
   cp /path/to/fda-templates/* ~/.openclaw/workspace/data/regulatory/templates/fda/
   ```

4. **Set up regulatory deadline tracking:**
   ```json
   {
     "regulatory": {
       "submissions": [
         {
           "type": "IRB_continuing_review",
           "protocol": "IRB-2025-0042",
           "deadline": "2026-04-15",
           "reminders": ["60d", "30d", "14d", "7d"],
           "notify": ["slack:#regulatory", "telegram:PI"]
         },
         {
           "type": "IND_annual_report",
           "ind_number": "IND-XXXXX",
           "deadline": "2026-08-01",
           "reminders": ["90d", "60d", "30d", "14d"],
           "notify": ["teams:regulatory-affairs", "whatsapp:sponsor"]
         }
       ]
     }
   }
   ```

5. **Configure team coordination channels:**
   - Slack `#regulatory`: Day-to-day document preparation discussion
   - Teams `regulatory-affairs`: Formal review and approval workflow
   - Telegram/WhatsApp: Urgent deadline alerts to PI and regulatory officer

6. **Example interactions:**
   - Slack: "@openclaw Start preparing the continuing review for IRB-2025-0042. Pull enrollment numbers from the clinical trials skill and adverse events from the safety database."
   - Teams: "@openclaw Review the Module 2.5 Clinical Overview draft for consistency with the Module 5 clinical study reports."
   - WebChat: "Generate a substantial equivalence table comparing our device against predicate K201234. Use the 510(k) summary database."

### Estimated Time Savings

Regulatory document preparation is notoriously time-intensive: an IND application takes 200-500 hours, an IRB application 10-40 hours, annual reports 20-40 hours. AI-assisted drafting, template management, and consistency checking can reduce effort by 30-50%. **Savings: ~60-250 hours for an IND, 3-20 hours for an IRB application, 6-20 hours for annual reports.**

### Relevant ClawHub Skills

- `coding-agent` -- document assembly scripts, cross-reference validation
- `canvas` -- submission checklist and document assembly workspace
- `nano-pdf` -- process and generate PDF regulatory documents
- `summarize` -- condense clinical study reports for regulatory summaries
- `blogwatcher` -- monitor FDA guidance pages and Federal Register for regulatory updates

---

## Architecture Overview for Research Deployment

```
                          +---------------------------+
                          |    OpenCLAW Gateway        |
                          |  ws://127.0.0.1:18789     |
                          |  Claude Opus 4.6 Agent     |
                          +---------------------------+
                                     |
              +----------------------+----------------------+
              |                      |                      |
     +--------+--------+   +--------+--------+   +---------+--------+
     | Messaging Layer  |   |  Automation      |   |  Device Nodes    |
     |                  |   |                  |   |                  |
     | Slack  (lab team)|   | Cron (scheduled  |   | iPad (lab voice  |
     | Discord (collab) |   |   scans, alerts) |   |   terminal)      |
     | Telegram (mobile)|   | Webhooks (LIMS,  |   | iPhone (camera,  |
     | Teams (clinical) |   |   instruments)   |   |   mobile notes)  |
     | Signal (PHI)     |   | Gmail Pub/Sub    |   | Mac (desktop,    |
     | WhatsApp (alerts)|   |   (notifications)|   |   Voice Wake)    |
     | WebChat (desktop)|   |                  |   |                  |
     +--------+---------+   +--------+---------+   +---------+--------+
              |                      |                      |
              +----------------------+----------------------+
                                     |
                          +----------+----------+
                          |    Workspace         |
                          | ~/.openclaw/workspace|
                          |                      |
                          | /skills/             |
                          |   lit-monitor/       |
                          |   paper-scanner/     |
                          |   clinical-trials/   |
                          |   lab-notebook/      |
                          |   data-pipeline/     |
                          |   phi-anonymizer/    |
                          |   grant-writer/      |
                          |   regulatory-docs/   |
                          |                      |
                          | /data/               |
                          |   (persistent state) |
                          +---------------------+
```

---

## Security Considerations for Research Use

| Concern | OpenCLAW Mitigation |
|---|---|
| Patient data (PHI/PII) | Self-hosted: data never leaves your infrastructure. No cloud API receives raw PHI. |
| Access control | DM pairing codes for unknown senders. Group channel allowlists. Per-skill channel restrictions. |
| Audit trail | All operations logged in workspace. Append-only audit logs for compliance. |
| Data sovereignty | Gateway runs on your hardware. Tailscale for secure remote access (no public exposure). |
| Model selection | Use Anthropic Claude via OAuth (Pro/Max subscription). Data not used for training. |
| Channel encryption | Signal for highest-sensitivity communications. Slack Enterprise Grid for institutional compliance. |
| Sandboxing | Configure tool execution sandboxing for group/channel sessions. |

Run `openclaw doctor` regularly to identify risky configurations.

---

## Quick-Start Checklist for Research Labs

1. **Install**: `npm install -g openclaw@latest && openclaw onboard --install-daemon`
2. **Configure model**: Set `anthropic/claude-opus-4-6` in `~/.openclaw/openclaw.json`
3. **Connect channels**: Run through onboarding wizard for Slack, Telegram, and your preferred channels
4. **Pair devices**: Install companion app on lab iPad/phone, pair with gateway
5. **Create workspace skills**: Start with `lit-monitor` and `lab-notebook` for immediate value
6. **Enable ClawHub**: Allow the agent to discover and install community skills as needed
7. **Set up cron jobs**: Daily literature scans, weekly digests, deadline reminders
8. **Configure security**: Set channel allowlists, enable audit logging, restrict PHI channels
9. **Test voice**: Configure Voice Wake on lab device, test with simple queries
10. **Iterate**: Add skills incrementally as your team identifies new automation opportunities

---

## Summary of Time Savings

| Use Case | Estimated Savings | Frequency |
|---|---|---|
| Literature monitoring | 3-4 hrs/week | Ongoing |
| Paper scanning and summarization | 12-20 hrs/review cycle | Per literature review |
| Clinical trial management | 4-6 hrs/week | Ongoing per trial |
| Lab notebook integration | 2-5 hrs/week | Ongoing |
| Team collaboration | 3-7 hrs/week | Ongoing per team |
| Voice lab assistant | 2.5-5 hrs/week | Ongoing |
| Data analysis pipelines | 1-3 hrs/analysis | Per dataset |
| Patient data anonymization | 14-36 hrs/dataset | Per dataset |
| Grant writing | 35-90 hrs/grant | Per application |
| Regulatory documents | 60-250 hrs/IND | Per submission |

**Conservative aggregate for an active research group: 80-150 hours saved per month.**
