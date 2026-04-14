# Adding Your Files

This guide shows you how to upload documents to your knowledge base and rebuild it.

---

## Mac or Linux

### Option 1 — Use the update script (recommended)

The easiest way. Run this in your terminal:

    bash update-kb.sh

It will ask for your VPS IP address, then ask you to drag your folder in. It uploads everything and rebuilds automatically.

### Option 2 — Manual upload

Open your terminal and run:

    scp -r /path/to/your/folder root@YOUR_VPS_IP:/root/.zeroclaw/workspace/knowledge/

**Tip:** To get your folder path on Mac, right-click the folder, hold Option, then click "Copy as Pathname".

Then SSH into your VPS and rebuild:

    ssh root@YOUR_VPS_IP
    sbt build

---

## Windows

Use [WinSCP](https://winscp.net) (free):

1. Download and open WinSCP
2. Click **New Site**
3. Set protocol to **SFTP**
4. Enter your VPS IP address
5. Username: `root`
6. Enter your VPS password
7. Click **Login**
8. Navigate to `/root/.zeroclaw/workspace/knowledge/`
9. Drag your files or folders into that directory
10. Open PowerShell, SSH into your VPS and run:

        ssh root@YOUR_VPS_IP
        sbt build

---

## What files can I add?

| Format | Notes |
|---|---|
| PDF | Auto-converted to markdown |
| Word (.docx) | Auto-converted to markdown |
| PowerPoint (.pptx) | Auto-converted to markdown |
| Markdown (.md) | Used directly |
| Text (.txt) | Used directly |
| Code (.py, .js, .ts) | AST parsed for structure |

---

## After uploading

Once your files are uploaded and `sbt build` has run, ask your Telegram bot:

    what's in my knowledge base?

Your new documents will be included in the response.

---

## Rebuilding

Every time you add new files, run `sbt build` again. It uses caching so only new or changed files are processed — rebuilds are fast.

You can also trigger a rebuild from Telegram:

    rebuild my knowledge base
