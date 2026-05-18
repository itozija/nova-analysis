#!/bin/bash
# Nova Analysis — One-command VPS setup
# Prerequisites: ZeroClaw installed, Node.js installed
# Run on your VPS: bash setup.sh

set -euo pipefail

WORKSPACE="/root/.zeroclaw/workspace"
CONFIG_FILE="/root/.zeroclaw/config.toml"

echo ""
echo "================================"
echo "  Nova Analysis Setup"
echo "================================"
echo ""

# --- Check ZeroClaw is installed ---
if ! command -v zeroclaw &>/dev/null; then
    echo "ERROR: ZeroClaw is not installed."
    echo "  Install it first: https://zeroclaw.dev/docs/install"
    exit 1
fi

# --- Collect API keys ---
echo "You'll need:"
echo "  1. OpenRouter API key  → https://openrouter.ai/keys"
echo "  2. Telegram bot token  → @BotFather on Telegram"
echo "  3. Telegram user ID    → @userinfobot on Telegram"
echo "  4. Apify API token     → https://console.apify.com/settings/integrations"
echo ""

read -p "Bot name (e.g. Atlas, Nova, Max): " BOT_NAME
read -p "OpenRouter API key: " OPENROUTER_KEY
read -p "Telegram bot token: " TELEGRAM_TOKEN
read -p "Telegram user ID:   " TELEGRAM_USER_ID
read -p "Apify API token:    " APIFY_TOKEN

echo ""

# --- 1. Copy workspace files ---
echo "[ 1/5 ] Setting up workspace files..."
mkdir -p "$WORKSPACE"
cp agents/AGENTS.md "$WORKSPACE/"
sed "s|YOUR_BOT_NAME|$BOT_NAME|g" agents/SOUL.md > "$WORKSPACE/SOUL.md"
cp agents/USER.md "$WORKSPACE/"
cp agents/MEMORY.md "$WORKSPACE/"
echo "  Done"

# --- 2. Copy skills ---
echo ""
echo "[ 2/5 ] Installing skills..."
mkdir -p "$WORKSPACE/skills/nova"
mkdir -p "$WORKSPACE/skills/workspace"
cp agents/skills/nova/SKILL.toml "$WORKSPACE/skills/nova/"
sed "s|YOUR_BOT_NAME|$BOT_NAME|g" agents/skills/workspace/SKILL.toml > "$WORKSPACE/skills/workspace/SKILL.toml"
echo "  Done"

# --- 3. Copy nova_scrape.py and inject Apify token ---
echo ""
echo "[ 3/5 ] Setting up Nova scraper..."
mkdir -p "$WORKSPACE"
sed "s|YOUR_APIFY_TOKEN|$APIFY_TOKEN|" scripts/nova_scrape.py > "$WORKSPACE/nova_scrape.py"
chmod +x "$WORKSPACE/nova_scrape.py"
echo "  Done"

# --- 4. Copy second-brain-t ---
echo ""
echo "[ 4/5 ] Setting up Second Brain..."
mkdir -p "$WORKSPACE/second-brain-t"
cp -r second-brain-t/* "$WORKSPACE/second-brain-t/"
mkdir -p "$WORKSPACE/knowledge"
pip3 install pdfplumber python-docx python-pptx --quiet --break-system-packages 2>/dev/null \
    || pip3 install pdfplumber python-docx python-pptx --quiet 2>/dev/null || true
echo "  Done"

# --- 5. Generate config ---
echo ""
echo "[ 5/5 ] Writing ZeroClaw config..."
mkdir -p "$(dirname $CONFIG_FILE)"
sed \
    -e "s|YOUR_OPENROUTER_API_KEY|$OPENROUTER_KEY|" \
    -e "s|YOUR_TELEGRAM_BOT_TOKEN|$TELEGRAM_TOKEN|" \
    -e "s|YOUR_TELEGRAM_USER_ID|$TELEGRAM_USER_ID|" \
    -e "s|YOUR_APIFY_TOKEN|$APIFY_TOKEN|g" \
    config/config.template.toml > "$CONFIG_FILE"
echo "  Done"

# --- Create sbt helper ---
cat > /usr/local/bin/sbt << 'SCRIPT'
#!/bin/bash
SBT="/root/.zeroclaw/workspace/second-brain-t"
KB="/root/.zeroclaw/workspace/knowledge"
case "${1:-}" in
  build)  python3 "$SBT/build.py" "$KB" --update ;;
  status) cat "$SBT/output/freshness.json" 2>/dev/null || echo "Not built yet. Run: sbt build" ;;
  search) grep -ri "${2:-}" "$SBT/output/tiers/" 2>/dev/null || echo "No results." ;;
  *)      echo "Usage: sbt build | sbt status | sbt search <keyword>" ;;
esac
SCRIPT
chmod +x /usr/local/bin/sbt

echo ""
echo "================================"
echo "  Setup complete!"
echo "================================"
echo ""
echo "Next steps:"
echo ""
echo "  1. Start the agent:"
echo "     systemctl --user start zeroclaw"
echo ""
echo "  2. Upload your knowledge files from your Mac:"
echo "     bash update-kb.sh"
echo ""
echo "  3. Build the knowledge base:"
echo "     sbt build"
echo ""
echo "  4. Message your Telegram bot:"
echo "     @Nova https://youtube.com/watch?v=..."
echo "     @SecondBrain what does the knowledge base say about X?"
echo ""
