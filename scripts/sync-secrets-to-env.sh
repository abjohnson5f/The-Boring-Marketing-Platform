#!/usr/bin/env bash
# sync-secrets-to-env.sh
# Purpose: Pull GitHub Secrets down to local .env file (MUCH easier than re-entering!)
# Usage: ./scripts/sync-secrets-to-env.sh

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Syncing GitHub Secrets → Local .env                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if .env exists
if [ -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file already exists!${NC}"
    echo -e "${YELLOW}This script will ADD missing variables (won't overwrite existing)${NC}"
    read -p "Continue? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${BLUE}ℹ️  Cancelled${NC}"
        exit 0
    fi
    ENV_FILE=".env"
else
    echo -e "${BLUE}📋 Creating new .env file from GitHub Secrets...${NC}"
    cp .env.example .env
    ENV_FILE=".env"
fi

echo ""
echo -e "${BLUE}Fetching secrets from GitHub...${NC}"

# Get all secret names
SECRETS=$(gh secret list --json name -q '.[].name')

if [ -z "$SECRETS" ]; then
    echo -e "${RED}❌ No secrets found in GitHub${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found $(echo "$SECRETS" | wc -l | tr -d ' ') secrets${NC}"
echo ""

# Note: gh secret doesn't expose VALUES (security feature)
# So we'll create a template with placeholders

echo -e "${YELLOW}⚠️  IMPORTANT: GitHub CLI cannot read secret VALUES (security)${NC}"
echo -e "${YELLOW}But we can create a template with all the right variable names!${NC}"
echo ""

# Add secrets to .env with placeholder values
while IFS= read -r secret; do
    # Check if variable already exists in .env
    if grep -q "^${secret}=" "$ENV_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $secret (already in .env)"
    else
        # Add with placeholder
        echo "${secret}=<GET_FROM_GITHUB_SECRETS>" >> "$ENV_FILE"
        echo -e "${BLUE}+${NC} $secret (added placeholder)"
    fi
done <<< "$SECRETS"

echo ""
echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  NEXT: Replace placeholders with actual values                 ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Unfortunately, GitHub doesn't let us READ secret values (security)${NC}"
echo -e "${BLUE}But you can copy them from GitHub's web interface:${NC}"
echo ""
echo -e "1. Open: ${GREEN}https://github.com/abjohnson5f/The-Boring-Marketing-Platform/settings/secrets/actions${NC}"
echo -e "2. For each secret with ${YELLOW}<GET_FROM_GITHUB_SECRETS>${NC} placeholder:"
echo -e "   - Click ${GREEN}Update${NC} button in GitHub"
echo -e "   - Copy the value"
echo -e "   - Paste into ${GREEN}.env${NC} file"
echo ""
echo -e "${BLUE}OR: Use the n8n MCP server to auto-fill from your credential store!${NC}"
echo ""
read -p "Open .env now to review/edit? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if command -v cursor &> /dev/null; then
        cursor .env
    elif command -v code &> /dev/null; then
        code .env
    elif [ -n "${EDITOR:-}" ]; then
        $EDITOR .env
    else
        nano .env
    fi
fi

echo ""
echo -e "${GREEN}✅ .env file updated!${NC}"
echo -e "${BLUE}Variables added from GitHub Secrets. Replace placeholders with actual values.${NC}"
