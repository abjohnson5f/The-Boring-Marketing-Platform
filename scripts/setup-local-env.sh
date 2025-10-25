#!/usr/bin/env bash
# setup-local-env.sh
# Purpose: One-command setup for local development environment
# Usage: ./scripts/setup-local-env.sh

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Boring Businesses Marketing Platform - Environment Setup      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if .env already exists
if [ -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file already exists!${NC}"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}ℹ️  Keeping existing .env file${NC}"
        exit 0
    fi
fi

# Copy .env.example to .env
echo -e "${BLUE}📋 Copying .env.example to .env...${NC}"
cp .env.example .env
echo -e "${GREEN}✅ Created .env file${NC}"
echo ""

# Provide instructions for filling in credentials
echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  NEXT STEPS: Fill in your credentials                          ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}1. Neon Database Connection (REQUIRED)${NC}"
echo -e "   → Go to: ${GREEN}https://console.neon.tech/app/projects${NC}"
echo -e "   → Select: Branch=${GREEN}development${NC}, Compute=${GREEN}Primary${NC}, Database=${GREEN}neondb${NC}"
echo -e "   → Click: ${GREEN}Connection string${NC} tab (NOT passwordless auth)"
echo -e "   → Copy the full connection string"
echo -e "   → Paste into ${GREEN}NEON_CONNECTION_STRING${NC} in .env"
echo ""

echo -e "${BLUE}2. Apify API Token (For web scraping)${NC}"
echo -e "   → Go to: ${GREEN}https://console.apify.com/account/integrations${NC}"
echo -e "   → Copy your API token"
echo -e "   → Paste into ${GREEN}APIFY_API_TOKEN${NC} in .env"
echo ""

echo -e "${BLUE}3. Optional: AI Provider Keys${NC}"
echo -e "   ${YELLOW}ANTHROPIC_API_KEY${NC} - https://console.anthropic.com/settings/keys"
echo -e "   ${YELLOW}OPENAI_API_KEY${NC}    - https://platform.openai.com/api-keys"
echo -e "   ${YELLOW}OPENROUTER_API_KEY${NC} - https://openrouter.ai/keys"
echo -e "   ${YELLOW}GOOGLE_GEMINI_API_KEY${NC} - https://aistudio.google.com/app/apikey"
echo ""

echo -e "${BLUE}4. Optional: Slack Integration${NC}"
echo -e "   ${YELLOW}SLACK_WEBHOOK_URL${NC}   - https://api.slack.com/messaging/webhooks"
echo -e "   ${YELLOW}SLACK_BOT_TOKEN${NC}     - From your Slack app settings"
echo -e "   ${YELLOW}SLACK_CHANNEL_ID${NC}    - Channel ID (e.g., C01234567)"
echo ""

# Offer to open .env in editor
echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  Open .env in editor?                                          ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

read -p "Open .env now to add credentials? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Try editors in order of preference
    if command -v cursor &> /dev/null; then
        echo -e "${GREEN}Opening in Cursor...${NC}"
        cursor .env
    elif command -v code &> /dev/null; then
        echo -e "${GREEN}Opening in VS Code...${NC}"
        code .env
    elif [ -n "${EDITOR:-}" ]; then
        echo -e "${GREEN}Opening in \$EDITOR ($EDITOR)...${NC}"
        $EDITOR .env
    else
        echo -e "${GREEN}Opening in nano...${NC}"
        nano .env
    fi
fi

echo ""
echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  After adding credentials, test your connection:               ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}1. Load environment:${NC}"
echo -e "   ${GREEN}source scripts/load-env.sh${NC}"
echo ""
echo -e "${BLUE}2. Test Neon connection:${NC}"
echo -e "   ${GREEN}psql \"\$NEON_CONNECTION_STRING\" -c 'SELECT version();'${NC}"
echo ""
echo -e "${BLUE}3. Run Day 1 migrations:${NC}"
echo -e "   ${GREEN}./scripts/run-migrations.sh${NC}"
echo ""
echo -e "${GREEN}✅ Setup complete!${NC} See ${BLUE}docs/NEON_SETUP.md${NC} for detailed instructions."
echo ""
