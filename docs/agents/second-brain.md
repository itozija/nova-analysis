# Second Brain T — Knowledge Base Builder

Second Brain T turns any folder of documents into a searchable knowledge base that your ZeroClaw agent can query from Telegram.

## What it does

Point it at any folder and it automatically builds:

- **Knowledge graph** — visual map of how your files connect to each other
- **Wiki** — one page per file, organised by topic with cross-links
- **Tiers** — compressed summaries optimised for AI queries

## Supported file formats

- PDF — auto-converted
- Word documents (.docx) — auto-converted
- PowerPoint (.pptx) — auto-converted
- Markdown notes
- Plain text
- Code files (Python, JavaScript, TypeScript)

---

## How to build your knowledge base

### Step 1 — Prepare your files

Gather the documents you want to include. Examples:

- Research papers
- Course readings
- Meeting notes
- Project documentation
- Personal notes

### Step 2 — Upload to your VPS

Open your local terminal and run:

    scp -r /path/to/your/folder root@YOUR_VPS_IP:/root/.zeroclaw/workspace/knowledge/

Replace `/path/to/your/folder` with your actual folder path.

**Mac tip:** Right-click your folder, hold Option, click "Copy as Pathname" to get the path.

### Step 3 — Build the knowledge base

SSH into your VPS and run:

    sbt build

This scans all your files, extracts topics and connections, and builds the output. Takes 1-2 minutes depending on folder size.

### Step 4 — Query from Telegram

Once built, message your ZeroClaw bot on Telegram:

**Read full inventory:**

    use shell to run: cat /root/.zeroclaw/workspace/second-brain-t/output/tiers/index.md

**Search for a keyword:**

    use shell to run: grep -ri "your topic" /root/.zeroclaw/workspace/second-brain-t/output/tiers/

**Read a specific topic:**

    use shell to run: ls /root/.zeroclaw/workspace/second-brain-t/output/tiers/topic/

**Rebuild after adding new files:**

    sbt build

---

## What you get after building

    output/
      tiers/
        index.md          Full inventory of everything
        topic/            One file per topic cluster
        entity/           Deep context per document
      wiki/               Browse in Obsidian
      graph/
        report.md         Hub documents, gaps, connections
        graph.html        Interactive visual map

---

## Privacy

Your files never leave your VPS. Second Brain T runs entirely locally — no cloud, no API calls, no data sharing.
