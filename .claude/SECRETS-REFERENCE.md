# GitHub Secrets Reference

**Purpose**: Quick reference for all GitHub Secrets required by Boring Businesses Platform
**Last Updated**: 2025-10-25
**Total Secrets Required**: 8

---

## All 8 Required Secrets

| # | Secret Name | Purpose | Where to Get | Format |
|---|-------------|---------|--------------|--------|
| 1 | `ANTHROPIC_API_KEY` | Claude Code execution | [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) | `sk-ant-api03-...` |
| 2 | `OPENAI_API_KEY` | GPT-4 for writing/reasoning | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) | `sk-proj-...` |
| 3 | `GOOGLE_GEMINI_API_KEY` | Cost-optimized AI | [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) | `AIza...` |
| 4 | `OPENROUTER_API_KEY` | Multi-model routing | [openrouter.ai/keys](https://openrouter.ai/keys) | `sk-or-...` |
| 5 | `NEON_CONNECTION_STRING` | PostgreSQL database | [console.neon.tech](https://console.neon.tech) | `postgres://...` |
| 6 | `APIFY_API_TOKEN` | Google Maps scraping | [console.apify.com](https://console.apify.com) | `apify_api_...` |
| 7 | `SLACK_BOT_TOKEN` | Notifications (modern) | Slack App → OAuth & Permissions | `xoxb-...` |
| 8 | `SLACK_CHANNEL_ID` | Target channel | Slack → Channel Details | `C07XXXXXXXX` |

---

## Quick Setup

Run this script to configure all 8 secrets:

```bash
/tmp/setup-secrets-complete.sh
```

Or configure manually:

```bash
gh secret set ANTHROPIC_API_KEY
gh secret set OPENAI_API_KEY
gh secret set GOOGLE_GEMINI_API_KEY
gh secret set OPENROUTER_API_KEY
gh secret set NEON_CONNECTION_STRING
gh secret set APIFY_API_TOKEN
gh secret set SLACK_BOT_TOKEN
gh secret set SLACK_CHANNEL_ID
```

---

## Verification

Check all secrets are configured:

```bash
gh secret list
```

**Expected output (at least 8 secrets):**

```
ANTHROPIC_API_KEY        Updated YYYY-MM-DD
APIFY_API_TOKEN          Updated YYYY-MM-DD
GOOGLE_GEMINI_API_KEY    Updated YYYY-MM-DD
NEON_CONNECTION_STRING   Updated YYYY-MM-DD
OPENAI_API_KEY           Updated YYYY-MM-DD
OPENROUTER_API_KEY       Updated YYYY-MM-DD
SLACK_BOT_TOKEN          Updated YYYY-MM-DD
SLACK_CHANNEL_ID         Updated YYYY-MM-DD
```

---

## What Each Secret Does

### AI Services (4 secrets)

**ANTHROPIC_API_KEY** (Required - Priority 1)
- Powers autonomous GitHub Actions execution
- Used by Claude Code to read issues, create PRs, modify code
- Cost: ~$3-5 per day during 5-day sprint

**OPENAI_API_KEY** (Required - Priority 1)
- Newsletter generation (GPT-4 for quality writing)
- Complex reasoning tasks (hypothesis analysis)
- RAG chat interface (high-quality responses)
- Cost: ~$50-150/month depending on hypothesis volume

**GOOGLE_GEMINI_API_KEY** (Required - Priority 1)
- Sentiment analysis (500 reviews for $0.05 vs $5 with GPT-4)
- Keyword extraction (bulk processing)
- Business classification (cost-optimized)
- Cost: ~$5-10/month (400x cheaper than GPT-4 for these tasks)

**OPENROUTER_API_KEY** (Recommended - Priority 2)
- Access to 100+ models (Claude, GPT-4, Gemini, DeepSeek, etc.)
- Automatic fallback if primary provider has outage
- Cost optimization via model routing
- Usage-based pricing (no monthly minimum)

### Data Infrastructure (2 secrets)

**NEON_CONNECTION_STRING** (Required - Priority 1)
- PostgreSQL database for all data storage
- Format: `postgres://user:password@host/database?sslmode=require`
- Used by: Migrations, workflows, RAG system, dashboards
- Cost: Free tier covers initial development

**APIFY_API_TOKEN** (Required - Priority 1)
- Scrapes Google Maps for business listings, reviews, contacts
- Used by: Data collection workflow (Day 2)
- Cost: ~$5-20 per hypothesis (100 businesses, 500 reviews)

### Notifications (2 secrets)

**SLACK_BOT_TOKEN** (Required - Priority 1)
- Modern Slack integration (OAuth token)
- Format: `xoxb-1234567890123-1234567890123-xxxxxxxx`
- Enables: Messages, file uploads, interactive buttons
- Security: Revocable, scoped permissions

**SLACK_CHANNEL_ID** (Required - Priority 1)
- Which channel receives notifications (#boring-ops)
- Format: `C07XXXXXXXX`
- Find: Slack → Channel Details → Channel ID

---

## Testing Secrets

### Test Anthropic API

```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: YOUR_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-3-5-sonnet-20241022","max_tokens":10,"messages":[{"role":"user","content":"Hi"}]}'
```

### Test OpenAI API

```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_KEY" | jq '.data[0].id'
```

### Test Google Gemini API

```bash
curl "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=YOUR_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"Hi"}]}]}'
```

### Test OpenRouter API

```bash
curl https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer YOUR_KEY" | jq '.data[0].id'
```

### Test Neon Database

```bash
psql "YOUR_CONNECTION_STRING" -c "SELECT version();"
```

### Test Apify API

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "https://api.apify.com/v2/actor-tasks" | jq '.data.total'
```

### Test Slack Bot Token

```bash
curl -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"channel":"YOUR_CHANNEL_ID","text":"Test"}'
```

---

## Security Best Practices

✅ **DO:**
- Use GitHub Secrets (encrypted at rest, masked in logs)
- Rotate credentials every 90 days
- Use separate credentials for dev/staging/production
- Revoke tokens immediately if compromised
- Test credentials after adding them

❌ **DON'T:**
- Commit credentials to git (even in private repos)
- Share credentials via email/Slack/text
- Use production credentials in development
- Reuse passwords across services
- Store credentials in plaintext files

---

## Troubleshooting

### Secret not found in workflow

**Problem:** Workflow fails with "secret not found"
**Solution:** Verify exact spelling in workflow matches secret name

```bash
# Check secret exists
gh secret list | grep ANTHROPIC
```

### Invalid API key error

**Problem:** API returns 401/403 authentication error
**Solution:** Re-create the secret with correct value

```bash
# Delete and re-add secret
gh secret delete OPENAI_API_KEY
gh secret set OPENAI_API_KEY
# Paste correct value
```

### Slack bot can't post to channel

**Problem:** Bot token valid but messages fail
**Solution:** Invite bot to channel

```slack
/invite @Boring Businesses Platform
```

---

## Cost Summary (Monthly Estimates)

| Service | Monthly Cost | Usage Pattern |
|---------|--------------|---------------|
| **Anthropic API** | $10-30 | GitHub Actions automation |
| **OpenAI API** | $50-150 | Newsletter generation, complex tasks |
| **Google Gemini** | $5-10 | Bulk sentiment/classification |
| **OpenRouter** | $0-50 | Fallback/routing (optional) |
| **Neon Postgres** | $0-19 | Free tier → $19/month if scaled |
| **Apify** | $25-100 | 5-20 hypotheses × $5-20 each |
| **Slack** | $0 | Free for basic notifications |
| **Total** | **$90-359/month** | Varies by hypothesis volume |

**Optimization:** With multi-model strategy (Gemini for simple tasks), save ~$80/month vs OpenAI-only.

---

## When Secrets Are Needed

| Day | Secrets Required |
|-----|------------------|
| **Day 1** | ANTHROPIC_API_KEY, NEON_CONNECTION_STRING, SLACK_BOT_TOKEN, SLACK_CHANNEL_ID |
| **Day 2** | + APIFY_API_TOKEN |
| **Day 3** | + OPENAI_API_KEY, GOOGLE_GEMINI_API_KEY |
| **Day 4** | + OPENROUTER_API_KEY (optional) |
| **Day 5** | All 8 secrets |

**Recommendation:** Configure all 8 secrets now, even if not immediately needed. Prevents sprint delays.

---

## Support Resources

| Issue | Resource |
|-------|----------|
| **Anthropic API** | [docs.anthropic.com](https://docs.anthropic.com) |
| **OpenAI API** | [platform.openai.com/docs](https://platform.openai.com/docs) |
| **Google Gemini** | [ai.google.dev/docs](https://ai.google.dev/docs) |
| **OpenRouter** | [openrouter.ai/docs](https://openrouter.ai/docs) |
| **Neon Postgres** | [neon.tech/docs](https://neon.tech/docs) |
| **Apify** | [docs.apify.com](https://docs.apify.com) |
| **Slack API** | [api.slack.com](https://api.slack.com) |
| **GitHub Secrets** | [docs.github.com/en/actions/security-guides/encrypted-secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) |

---

**Last Verified:** 2025-10-25
**Maintainer:** Alex Johnson
**Project:** Boring Businesses Marketing Platform
