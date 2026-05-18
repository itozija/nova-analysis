# Nova Analysis

A personal AI intelligence system running on your VPS, accessible via Telegram. Send a YouTube URL and get a business intelligence breakdown. Ask questions about your personal knowledge base.

## What's Inside

| Agent | How to trigger | What it does |
|-------|---------------|--------------|
| Your main bot | Send any message | General assistant, reads your workspace files |
| `@Nova` | `@Nova <YouTube URL>` | Fetches real video data via Apify, returns HIGH/MEDIUM/LOW ROI analysis |
| `@SecondBrain` | `@SecondBrain <question>` | Searches your personal knowledge base |

---

## Prerequisites

You need:

1. **A VPS** running Linux (Ubuntu/Debian recommended) — [Hetzner](https://hetzner.com), [DigitalOcean](https://digitalocean.com), etc.
2. **ZeroClaw** installed on the VPS → [zeroclaw.dev/docs/install](https://zeroclaw.dev/docs/install)
3. **Node.js** on the VPS (for the Apify MCP bridge) → `apt install nodejs npm`
4. **Four API keys** — see below

### API Keys

| Key | Where to get it | Cost |
|-----|----------------|------|
| **OpenRouter** | [openrouter.ai/keys](https://openrouter.ai/keys) | ~$0.01 per YouTube analysis. Add $5-20 credit. |
| **Telegram bot token** | Message `@BotFather` on Telegram → `/newbot` | Free |
| **Telegram user ID** | Message `@userinfobot` on Telegram | Free |
| **Apify token** | [console.apify.com/settings/integrations](https://console.apify.com/settings/integrations) | Free tier available |

> **OpenRouter model**: This system uses `anthropic/claude-sonnet-4`. Make sure your OpenRouter account has access to Anthropic models.

---

## Installation

### 1. Clone the repo on your VPS

```bash
git clone https://github.com/itozija/nova-analysis
cd nova-analysis
```

### 2. Run the setup script

```bash
bash setup.sh
```

You'll be prompted for:
- Your bot's name (e.g. `Atlas`, `Max`, `Orion` — this is what the bot calls itself)
- Your OpenRouter API key
- Your Telegram bot token
- Your Telegram user ID
- Your Apify API token

The script will:
- Copy all agent files into the ZeroClaw workspace
- Inject your API keys into the config
- Install Python dependencies for the knowledge base builder
- Create the `sbt` helper command

### 3. Start the agent

```bash
systemctl --user start zeroclaw
systemctl --user enable zeroclaw   # auto-start on reboot
```

### 4. Test it

Open Telegram, find your bot, and send:

```
@Nova https://www.youtube.com/watch?v=dQw4w9WgXcQ
```

It should respond in 30-60 seconds with a business intelligence analysis.

---

## Knowledge Base (SecondBrain)

The SecondBrain agent lets you query your own documents — PDFs, Word files, PowerPoints, Markdown files.

### Upload your files

Run this on your **Mac/local machine** (not the VPS):

```bash
bash update-kb.sh
```

It will ask for your VPS IP and the folder path you want to upload. Drag the folder into the terminal to paste the path.

Supported file types: `.pdf`, `.docx`, `.pptx`, `.md`, `.txt`

### Build the knowledge base

After uploading, SSH into your VPS and run:

```bash
sbt build
```

This indexes your documents into a searchable knowledge base. It takes a few minutes depending on how many files you have.

### Query it

In Telegram:

```
@SecondBrain what does the knowledge base say about risk management?
@SecondBrain find papers by Flyvbjerg
@SecondBrain summarise the main themes in my notes
```

### Update after adding new files

```bash
bash update-kb.sh    # run on Mac to upload new files
sbt build            # run on VPS to rebuild the index
```

---

## Updating the Agent

After changing any config or skill files:

```bash
# On your VPS
systemctl --user restart zeroclaw
```

To clear conversation history (useful if the bot starts behaving strangely):

```bash
rm -f /root/.zeroclaw/workspace/sessions/telegram_*.jsonl
rm -f /root/.zeroclaw/workspace/sessions/sessions.db*
systemctl --user restart zeroclaw
```

---

## File Structure

```
nova-analysis/
├── setup.sh                     ← Run once on VPS to install everything
├── update-kb.sh                 ← Run on Mac to upload knowledge files
├── config/
│   └── config.template.toml    ← ZeroClaw config (keys injected by setup.sh)
├── agents/
│   ├── AGENTS.md               ← Bot's operating instructions
│   ├── SOUL.md                 ← Bot's personality (name injected by setup.sh)
│   ├── USER.md                 ← Fill in your name, background, preferences
│   ├── MEMORY.md               ← Starts empty — bot writes here over time
│   └── skills/
│       ├── nova/SKILL.toml     ← YouTube analysis skill
│       └── workspace/SKILL.toml ← File access skill
├── scripts/
│   └── nova_scrape.py          ← Apify YouTube fetcher (token injected by setup.sh)
└── second-brain-t/             ← Knowledge base builder
```

### Personalise your bot

Edit `agents/USER.md` and fill in your name, background, and what you're working on. The bot reads this file to understand who it's helping.

---

## Troubleshooting

**Bot doesn't respond**
```bash
journalctl --user -u zeroclaw -n 50 --no-pager
```
Look for errors. Common causes: wrong API key, ZeroClaw not running, Telegram token invalid.

**Bot hallucinating / giving wrong video info**
- Replies in under 10 seconds = no tool call = hallucination. Check the Apify token.
- Clear the session history and restart (see Updating the Agent above).

**SecondBrain says "rate limited" or "access denied"**
- This is a hallucination. Clear session history and restart.
- Make sure you've run `sbt build` after uploading files.

**Out of credits**
```
402 Payment Required
```
Add credits at [openrouter.ai/settings/credits](https://openrouter.ai/settings/credits).

**Check logs live**
```bash
journalctl --user -u zeroclaw -f
```

---

## How It Works

1. You message your Telegram bot
2. ZeroClaw routes the message to the right agent
3. For YouTube URLs: `@Nova` runs `nova_scrape.py` which calls the Apify YouTube scraper synchronously, then the model analyses the real data
4. For knowledge questions: `@SecondBrain` greps through your indexed documents
5. The response comes back to Telegram

The knowledge base is pre-built into a tiered index (topics → entities → wiki pages) so queries are fast without loading massive files into context.
