#!/bin/bash

echo "================================"
echo "  Nova Analysis — Update KB"
echo "================================"
echo ""

# Ask for VPS IP if not set
if [ -z "${VPS_IP:-}" ]; then
    read -p "Enter your VPS IP address: " VPS_IP
fi

VPS="root@$VPS_IP"
KB="/root/.zeroclaw/workspace/knowledge/"

# Ask for folder path
read -p "Drag your folder here (or paste path): " FOLDER

# Clean up the path
FOLDER="${FOLDER//\'/}"
FOLDER="${FOLDER//\"/}"
FOLDER="${FOLDER%"${FOLDER##*[![:space:]]}"}"

if [ ! -d "$FOLDER" ]; then
    echo "Folder not found: $FOLDER"
    exit 1
fi

echo ""
echo "Uploading to $VPS..."
scp -r "$FOLDER" "$VPS:$KB"

if [ $? -eq 0 ]; then
    echo ""
    echo "Upload complete. Rebuilding knowledge base..."
    ssh "$VPS" "sbt build"
    echo ""
    echo "Done! Ask your Telegram bot: what's in my knowledge base?"
else
    echo "Upload failed. Check your VPS IP and connection."
fi
