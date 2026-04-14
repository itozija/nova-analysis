# Setup Guide

## What you need

- A VPS (Hetzner, 2 vCPU / 4GB RAM, Ubuntu 22.04+) — ~$6/month
- A Telegram bot token (free, via @BotFather)
- An OpenRouter API key (openrouter.ai, $5 minimum)

## Step 1 — Get ZeroClaw running

Follow the [ZeroClaw official setup guide](https://github.com/zeroclaw-labs/zeroclaw).

## Step 2 — Clone Nova Analysis

SSH into your VPS and run:

    git clone https://github.com/itozija/nova-analysis.git /root/nova-analysis
    bash /root/nova-analysis/setup.sh

## Step 3 — Add your files

Upload your documents to the knowledge folder:

    scp -r /your/folder root@YOUR_VPS_IP:/root/.zeroclaw/workspace/knowledge/

Then build:

    sbt build

## Step 4 — Connect Telegram

    zeroclaw channel configure telegram
    zeroclaw service restart

Done. Message your bot on Telegram.
