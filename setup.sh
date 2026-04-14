#!/bin/bash
# Nova Analysis — One-command VPS setup
# Run this on your VPS after installing ZeroClaw:
#   bash setup.sh

set -euo pipefail

WORKSPACE="/root/.zeroclaw/workspace"
SBT_DIR="$WORKSPACE/second-brain-t"
KB_DIR="$WORKSPACE/knowledge"

echo ""
echo "================================"
echo "  Nova Analysis Setup"
echo "================================"
echo ""

# 1. Copy Second Brain T
echo "[ 1/4 ] Setting up Second Brain T..."
mkdir -p "$SBT_DIR"
cp -r second-brain-t/* "$SBT_DIR/"
echo "  Done"

# 2. Install Python dependencies
echo ""
echo "[ 2/4 ] Installing Python dependencies..."
pip3 install pdfplumber python-docx python-pptx --quiet --break-system-packages 2>/dev/null \
    || pip3 install pdfplumber python-docx python-pptx --quiet
echo "  Done"

# 3. Create knowledge folder
echo ""
echo "[ 3/4 ] Creating knowledge folder..."
mkdir -p "$KB_DIR"
echo "  $KB_DIR"

# 4. Patch ZeroClaw config
echo ""
echo "[ 4/4 ] Configuring ZeroClaw agent..."
python3 zeroclaw_patch.py
echo "  Done"

# Create sbt command
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
echo "  1. Upload your files from your Mac:"
echo "     Run update-kb.sh on your Mac"
echo ""
echo "  2. Build your knowledge base:"
echo "     sbt build"
echo ""
echo "  3. Restart ZeroClaw:"
echo "     zeroclaw service restart"
echo ""
echo "  4. Message your Telegram bot:"
echo "     what's in my knowledge base?"
echo ""
