# Boring Businesses Platform - Credentials Setup Guide

**For**: Alex Johnson (CMO) - Non-Technical Credential Management
**Purpose**: Secure credential storage BEFORE 5-day implementation sprint
**Critical**: Complete this setup to prevent agent delays, placeholders, and workarounds

---

## 🎯 Why This Matters (Business Context)

**Problem We're Preventing**:
- Agents encounter missing credentials → Create placeholder "TODO-CONFIGURE-X" → Sprint delays
- Insecure credential storage → Data breach → $100k+ liability + reputation damage
- Manual credential entry during sprint → 20+ interruptions → 5-day becomes 10-day

**Solution**:
- One-time secure setup (30 minutes now)
- Zero agent delays (credentials pre-loaded)
- Zero security risk (vault-based storage)
- Zero interruptions (automated access)

---

## 📋 Credentials You'll Need to Provide

### Category 1: Data Sources (Required for Hypothesis Processing)

#### **1. Apify API Token**
**Purpose**: Scrapes Google Maps for business listings, reviews, contacts

**Where to Get**:
1. Go to https://console.apify.com
2. Log in with your account
3. Click your avatar → Settings → Integrations
4. Copy "API token" (starts with `apify_api_...`)

**Where It's Used**:
- Workflow: `Boring Business - Postgres Ingestion.json`
- Frequency: Manual runs + weekly schedule
- Cost: ~$5-20/run depending on business count

**Required By**: Day 1 (Foundation sprint)

---

#### **2. Neon Postgres Credentials**
**Purpose**: Stores business data, opportunity metrics, lead tracking

**Where to Get**:
1. Go to https://console.neon.tech
2. Select project: "Boring Businesses"
3. Click "Connection Details"
4. Copy all values:
   - **Host**: `ep-cool-meadow-12345.us-east-2.aws.neon.tech`
   - **Database**: `boring_businesses`
   - **User**: `postgres`
   - **Password**: Click "Show" and copy
   - **Connection String**: Full postgres://... URL

**Where It's Used**:
- All workflows (data storage backbone)
- Migrations (schema changes)
- Testing (validation queries)
- Dashboards (Looker/Metabase)

**Required By**: Day 1 (Foundation sprint)

---

#### **3. Neo4j / Graphiti Credentials**
**Purpose**: Knowledge graph for relationship queries (competitor analysis, entity connections)

**Where to Get**:
1. If using Neo4j Aura:
   - Go to https://console.neo4j.io
   - Select instance
   - Copy connection URI, username, password

2. If self-hosted (Hostinger VPS):
   - SSH into VPS: `ssh root@your-vps-ip`
   - Docker: `docker exec -it neo4j cat /var/lib/neo4j/conf/neo4j.conf`
   - Or check deployment docs

**Where It's Used**:
- Hybrid RAG workflow (relationship queries)
- Optional: Can use PGVector-only mode initially

**Required By**: Day 2 (KG/RAG enhancements) - **Can defer if needed**

---

### Category 2: AI/LLM Services (Required for Analysis)

#### **4. OpenAI API Key**
**Purpose**: Powers RAG analysis, newsletter generation, sentiment scoring

**Where to Get**:
1. Go to https://platform.openai.com/api-keys
2. Click "+ Create new secret key"
3. Name: "Boring Businesses Platform"
4. Copy key (starts with `sk-proj-...`)
5. **SAVE IMMEDIATELY** - Can't view again!

**Where It's Used**:
- LangChain agent (RAG chat)
- Newsletter generation
- High-ticket confidence scoring
- Graphiti knowledge graph extraction

**Cost Estimate**: $50-150/month (varies by hypothesis volume)

**Required By**: Day 2 (KG/RAG enhancements)

---

#### **5. OpenRouter API Key** (Optional)
**Purpose**: Cost optimization via model routing, fallback for OpenAI

**Where to Get**:
1. Go to https://openrouter.ai/keys
2. Create account if needed
3. Click "Create API Key"
4. Copy key

**Where It's Used**:
- Alternative to OpenAI (cost savings)
- Model diversity (DeepSeek, Claude via OpenRouter)

**Required By**: Optional (use OpenAI initially)

---

### Category 3: Notifications & Monitoring (Highly Recommended)

#### **6. Slack Webhook URL**
**Purpose**: Real-time alerts for workflow failures, hypothesis validations, agent completions

**Where to Get**:
1. Go to https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Name: "Boring Businesses Alerts"
4. Choose workspace
5. Click "Incoming Webhooks" → "Activate Incoming Webhooks"
6. Click "Add New Webhook to Workspace"
7. Select channel: `#boring-ops` (create if doesn't exist)
8. Copy webhook URL (starts with `https://hooks.slack.com/services/...`)

**Where It's Used**:
- Orchestrator failures → Immediate alert
- Hypothesis validation → Success notification
- Agent completion → `.claude/hooks/agent-finish.sh`

**Why Critical**: PRD requires <1hr response to `blocked` status. Slack ensures you see alerts immediately.

**Required By**: Day 1 (Foundation sprint)

---

### Category 4: Optional Integrations (Future)

#### **7. GitHub Personal Access Token** (For Web/Mobile Claude Code)
**Purpose**: Enables Claude Code web/mobile to access your repository

**Where to Get**:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: "Claude Code Access"
4. Scopes needed:
   - `repo` (full control)
   - `workflow` (update GitHub Actions)
5. Copy token (starts with `ghp_...` or `github_pat_...`)

**Where It's Used**:
- Claude Code web (claude.com/code)
- GitHub Actions integration
- PR automation

**Required By**: Only if using web/mobile Claude Code (Task #1)

---

#### **8. Looker/Metabase Credentials** (Dashboard Phase)
**Purpose**: Business intelligence dashboards

**Where to Get**: Depends on chosen BI tool (Day 4 decision)

**Required By**: Day 4 (Dashboards sprint)

---

## 🔐 Secure Storage Methods

**YOU HAVE 3 OPTIONS** (from most to least secure):

### Option 1: n8n Credentials Vault (RECOMMENDED)

**Best For**: All n8n workflow credentials (Apify, Postgres, OpenAI, Slack)

**How to Set Up**:
1. Open n8n: https://n8n.avgj.io (or your Hostinger URL)
2. Click hamburger menu → "Credentials"
3. For each credential:
   - Click "+ Add Credential"
   - Select type (Generic, Postgres, HTTP Header Auth)
   - Name: `Apify Token (Production)`, `Neon Postgres (Production)`, etc.
   - Fill in values
   - Click "Save"

**Why This is Best**:
- Encrypted at rest
- Never visible in workflow JSON
- Automatic injection at runtime
- Zero hard-coding risk

**Example: Apify Token**:
```
Type: HTTP Header Auth
Name: Apify Token (Production)
Credentials:
  Name: Authorization
  Value: Bearer apify_api_xxxxxxxxxxxxx
```

**Example: Neon Postgres**:
```
Type: Postgres
Name: Neon Postgres (Production)
Host: ep-cool-meadow-12345.us-east-2.aws.neon.tech
Database: boring_businesses
User: postgres
Password: [your password]
Port: 5432
SSL: Enabled
```

---

### Option 2: Environment Variables (.env file)

**Best For**: Local development, Slack webhook, GitHub tokens

**How to Set Up**:
1. Create `.env` file in project root:
   ```bash
   cd "/Users/alexjohnson/IDE Work/BoringBusinessesMarketing"
   touch .env
   chmod 600 .env  # Owner read/write only
   ```

2. Add credentials (one per line):
   ```bash
   # Data Sources
   APIFY_API_TOKEN=apify_api_xxxxxxxxxxxxx

   # Database
   NEON_CONNECTION_STRING=postgres://postgres:password@ep-cool-meadow-12345.us-east-2.aws.neon.tech/boring_businesses?sslmode=require

   # AI Services
   OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx

   # Notifications
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00/B00/xxxxx

   # GitHub (if using web/mobile)
   GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxxxxxxxxxx
   ```

3. Load environment:
   ```bash
   source scripts/load-env.sh .env
   ```

**Why Use This**:
- Quick setup
- Works with hooks (`.claude/hooks/*.sh` scripts)
- Standard practice for local dev

**CRITICAL**: `.env` file is **already in `.gitignore`** - never commit it!

---

### Option 3: GitHub Secrets (For Web/Mobile Claude Code)

**Best For**: GitHub Actions, Claude Code web/mobile integration

**How to Set Up**:
1. Go to your repo: https://github.com/abjohnson5f/OnboardIO-Dev (or your repo)
2. Click "Settings" → "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add each secret:
   - Name: `ANTHROPIC_API_KEY` → Value: Your Claude API key
   - Name: `APIFY_API_TOKEN` → Value: apify_api_...
   - Name: `NEON_CONNECTION_STRING` → Value: postgres://...
   - Name: `OPENAI_API_KEY` → Value: sk-proj-...
   - Name: `SLACK_WEBHOOK_URL` → Value: https://hooks.slack.com/...

**Why Use This**:
- Required for GitHub Actions (Claude Code web integration)
- Encrypted by GitHub
- Accessible to workflows only

---

## 📝 Credential Checklist (Copy This)

**Before starting 5-day sprint**, verify:

### n8n Credentials Vault
- [ ] `Apify Token (Production)` - Type: HTTP Header Auth
- [ ] `Neon Postgres (Production)` - Type: Postgres
- [ ] `OpenAI API Key (Production)` - Type: HTTP Header Auth
- [ ] `Slack Webhook (Production)` - Type: HTTP Header Auth
- [ ] `Neo4j/Graphiti (Production)` - Type: Custom (if using KG)

### .env File (Local Development)
- [ ] `APIFY_API_TOKEN=apify_api_...`
- [ ] `NEON_CONNECTION_STRING=postgres://...`
- [ ] `OPENAI_API_KEY=sk-proj-...`
- [ ] `SLACK_WEBHOOK_URL=https://hooks.slack.com/...`
- [ ] File permissions: `chmod 600 .env` (owner-only)
- [ ] Git ignored: Verify `git check-ignore .env` returns `.env`

### GitHub Secrets (If Using Web/Mobile)
- [ ] `ANTHROPIC_API_KEY` (for Claude Code web)
- [ ] `APIFY_API_TOKEN`
- [ ] `NEON_CONNECTION_STRING`
- [ ] `OPENAI_API_KEY`
- [ ] `SLACK_WEBHOOK_URL`
- [ ] `APP_ID` (if using custom GitHub App)
- [ ] `APP_PRIVATE_KEY` (if using custom GitHub App)

---

## 🚨 What Happens If Credentials Are Missing

### Without Proper Setup (BAD):
```
Day 1, Hour 2:
Agent: "Creating Apify ingestion workflow..."
Agent: "Error: APIFY_API_TOKEN not found"
Agent: "Adding placeholder: TODO-CONFIGURE-APIFY-TOKEN"
You: "Wait, what? I need to stop and add credentials now?"
Result: 2-hour delay, broken flow, frustration

Day 2, Hour 1:
Agent: "Connecting to Postgres..."
Agent: "Error: Connection refused"
Agent: "Using SQLite fallback instead"  ← WRONG DATABASE!
You: "No! I need Neon Postgres with JSONB support!"
Result: Rework entire data layer, 8-hour delay
```

### With Proper Setup (GOOD):
```
Day 1, Hour 2:
Agent: "Creating Apify ingestion workflow..."
Agent: "Connected to Apify API successfully"
Agent: "Using credential: Apify Token (Production)"
Agent: "Test query returned 12 businesses"
Result: Zero delays, continuous progress

Day 2, Hour 1:
Agent: "Connecting to Postgres..."
Agent: "Connected to Neon: boring_businesses"
Agent: "JSONB extension: Verified"
Agent: "PGVector extension: Verified"
Result: Smooth sailing
```

---

## 🛡️ Security Best Practices

### DO ✅
1. **Use n8n credential vault** for all workflow credentials
2. **Use .env file** for local development (chmod 600)
3. **Use GitHub Secrets** for web/mobile integrations
4. **Rotate credentials** every 90 days (set calendar reminder)
5. **Test credentials immediately** after adding (see below)

### DON'T ❌
1. **Never commit credentials** to Git (even in private repos)
2. **Never share credentials** via email/Slack/text
3. **Never use production credentials** in development (create separate)
4. **Never reuse passwords** across services
5. **Never store in plaintext** files (except `.env` with proper permissions)

---

## 🧪 Testing Your Credentials (DO THIS NOW)

### Test 1: Apify Token
```bash
curl -H "Authorization: Bearer apify_api_YOUR_TOKEN" \
  "https://api.apify.com/v2/actor-tasks" | jq '.data.total'
# Expected: Number > 0 (your task count)
```

### Test 2: Neon Postgres
```bash
psql "postgres://postgres:PASSWORD@HOST/boring_businesses?sslmode=require" \
  -c "SELECT version();"
# Expected: PostgreSQL version output
```

### Test 3: OpenAI API Key
```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer sk-proj-YOUR_KEY" | jq '.data[0].id'
# Expected: Model name (e.g., "gpt-4o")
```

### Test 4: Slack Webhook
```bash
curl -X POST "YOUR_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d '{"text": "Test from credential setup"}'
# Expected: "ok" response, message appears in Slack
```

**ALL TESTS PASS?** ✅ You're ready for the 5-day sprint!

**ANY TESTS FAIL?** ❌ Stop and fix before proceeding!

---

## 📞 Credential Support Matrix

| Service | Support URL | Common Issues |
|---------|-------------|---------------|
| Apify | https://docs.apify.com/api/v2 | Token expired, rate limits |
| Neon | https://neon.tech/docs/connect/connect-from-any-app | Connection timeout, SSL required |
| OpenAI | https://platform.openai.com/docs | Quota exceeded, key invalid |
| Slack | https://api.slack.com/messaging/webhooks | Webhook revoked, channel deleted |
| GitHub | https://docs.github.com/en/authentication | Token scope insufficient |

---

## 🎯 Quick Reference Card (Print This)

```
┌─────────────────────────────────────────────┐
│ BORING BUSINESSES - CREDENTIAL QUICK CARD   │
├─────────────────────────────────────────────┤
│ Apify Token:                                │
│   Location: n8n → Credentials → Apify       │
│   Format: apify_api_xxxxxxxxxxxxx           │
│                                             │
│ Neon Postgres:                              │
│   Host: ep-cool-meadow-12345.us-east-2...   │
│   DB: boring_businesses                     │
│   User: postgres                            │
│                                             │
│ OpenAI Key:                                 │
│   Location: n8n → Credentials → OpenAI     │
│   Format: sk-proj-xxxxxxxxxxxxx             │
│                                             │
│ Slack Webhook:                              │
│   Channel: #boring-ops                      │
│   Format: https://hooks.slack.com/...       │
│                                             │
│ Emergency: If credential fails, check:      │
│   1. n8n credential vault (most likely)     │
│   2. .env file (local dev)                  │
│   3. GitHub secrets (web/mobile)            │
└─────────────────────────────────────────────┘
```

---

## ✅ Final Pre-Sprint Checklist

Before Alex says "Start the 5-day sprint":

**Technical Setup**:
- [ ] All credentials added to n8n vault
- [ ] .env file created with chmod 600
- [ ] GitHub secrets configured (if using web/mobile)
- [ ] All 4 credential tests passed
- [ ] Slack webhook delivered test message

**Documentation**:
- [ ] This file reviewed and understood
- [ ] Calendar reminder: Rotate credentials in 90 days
- [ ] Emergency contact list updated (Apify, Neon support)

**Business Readiness**:
- [ ] $50-150/month OpenAI budget approved
- [ ] Slack #boring-ops channel created with Alex + Vlad
- [ ] First hypothesis ready (Charlotte luxury tax, Nashville diesel, etc.)

**Sign-Off**:
- [ ] Alex (CMO): Understands credential importance ✅
- [ ] Vlad (Partner): Has backup access to all credentials ✅
- [ ] DevOps (Claude): Verified all credentials functional ✅

---

**Setup Complete?** → Proceed to Day 1: Foundation Sprint! 🚀

**Issues?** → Stop and resolve BEFORE starting sprint. Zero tolerance for "we'll fix it later."
