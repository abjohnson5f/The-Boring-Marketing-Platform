# Boring Businesses Marketing Platform

> **Enterprise-grade market intelligence system for discovering and validating "boring business" opportunities using AI-powered hypothesis testing and automated data collection.**

[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/abjohnson5f/The-Boring-Marketing-Platform/actions)
[![Claude Code](https://img.shields.io/badge/Powered%20by-Claude%20Code-7C3AED?logo=anthropic&logoColor=white)](https://claude.com/claude-code)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2016-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![n8n](https://img.shields.io/badge/Workflows-n8n-EA4B71?logo=n8n&logoColor=white)](https://n8n.io/)

---

## 🎯 What This Platform Does

The Boring Businesses Marketing Platform automates the **James Playbook** methodology for identifying high-revenue, low-competition service businesses. It combines:

- **Automated Data Collection**: Scrapes Google Maps for business listings, reviews, and market signals
- **AI-Powered Analysis**: Uses Claude, GPT-4, and Gemini for hypothesis validation and opportunity scoring
- **PostgreSQL + Knowledge Graph**: Stores structured data with JSONB flexibility and semantic relationships
- **Interactive RAG Interface**: Chat with your market data to discover patterns and pain points
- **Automated Workflows**: n8n orchestration for end-to-end hypothesis processing

**Example Hypothesis**: *"Luxury tax advisory services in Charlotte, NC have high demand but few qualified providers"*

**Platform Output**:
- Market metrics (provider density, review velocity, sentiment balance)
- Validation status (validated/needs review/discarded)
- Newsletter draft targeting top 10 potential clients
- Lead list with contact information and pain points

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions (CI/CD)                   │
│  • Claude Code autonomous execution via @claude mentions    │
│  • 5-day implementation sprint (Issues #1-5)                │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   n8n Workflow Automation                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ 01: Data     │→ │ 02: James    │→ │ 03: RAG      │      │
│  │ Collection   │  │ Orchestrator │  │ Analysis     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         ↓                  ↓                  ↓             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              PostgreSQL (Neon) + Knowledge Graph             │
│  • Businesses, reviews, hypotheses, opportunities            │
│  • JSONB for flexible API data storage                      │
│  • PGVector for semantic search                             │
│  • 8 strategic analysis views                               │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                  AI Services (Multi-Model)                   │
│  Claude (analysis) | GPT-4 (writing) | Gemini (bulk tasks)  │
│  OpenRouter (failover) | Custom RAG (queries)               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- **GitHub Account**: For CI/CD automation
- **Neon Account**: PostgreSQL database (free tier available)
- **Apify Account**: Google Maps scraping
- **OpenAI/Anthropic API Keys**: AI analysis
- **Slack Workspace**: Notifications (optional but recommended)

### 1. Clone Repository

```bash
git clone https://github.com/abjohnson5f/The-Boring-Marketing-Platform.git
cd The-Boring-Marketing-Platform
```

### 2. Configure GitHub Secrets

Required secrets (add via GitHub Settings → Secrets → Actions):

```bash
# AI Services
ANTHROPIC_API_KEY=sk-ant-api03-...
OPENAI_API_KEY=sk-proj-...
GOOGLE_GEMINI_API_KEY=AIza...
OPENROUTER_API_KEY=sk-or-...

# Data Infrastructure
NEON_CONNECTION_STRING=postgres://user:pass@host/db
APIFY_API_TOKEN=apify_api_...

# Notifications
SLACK_BOT_TOKEN=xoxb-...
SLACK_CHANNEL_ID=C07XXXXXXXX
```

**Quick setup script:**
```bash
gh secret set ANTHROPIC_API_KEY  # Follow prompts for each secret
```

See [.claude/SECRETS-REFERENCE.md](.claude/SECRETS-REFERENCE.md) for detailed setup guide.

### 3. Launch 5-Day Implementation Sprint

The platform is built through 5 autonomous GitHub issues:

```bash
# Already created - just re-trigger to start execution
gh issue list

# Day 1: Database Foundation (migrations, schema, validation)
# Day 2: Data Collection Workflow (Apify integration, UPSERT logic)
# Day 3: Orchestrator (JAMES-PLAYBOOK automation)
# Day 4: RAG Enhancement (AI chat interface, tools)
# Day 5: Testing & Dashboards (validation, monitoring)

# Re-trigger workflows (if needed)
gh issue close 1 2 3 && gh issue reopen 1 2 3
```

**Claude Code will:**
1. Read issue specifications
2. Apply database migrations
3. Build n8n workflows
4. Create test suites
5. Generate documentation
6. Submit Pull Requests for your review

**Monitor progress:**
- GitHub Actions: https://github.com/abjohnson5f/The-Boring-Marketing-Platform/actions
- Slack: #boring-ops channel (real-time notifications)

### 4. Validate Installation

After Day 5 completes:

```bash
# Run test suite
psql "$NEON_CONNECTION_STRING" -f schema/run-tests.sql

# Expected: 38/40 tests pass (95% target)
```

---

## 📋 Project Structure

```
BoringBusinessesMarketing/
├── .claude/                          # Claude Code configuration
│   ├── CLAUDE.md                     # Project memory (auto-loaded)
│   ├── SECRETS-REFERENCE.md          # Credential setup guide
│   ├── commands/                     # Slash command agents
│   │   ├── documentation-writer.md   # /documentation-writer
│   │   ├── sql-migrations.md         # /sql-migrations
│   │   ├── testing-agent.md          # /testing-agent
│   │   └── workflow-editor.md        # /workflow-editor
│   ├── github-issues/                # 5-day sprint issue templates
│   │   ├── DAY-1-DATABASE-FOUNDATION.md
│   │   ├── DAY-2-APIFY-WORKFLOW.md
│   │   ├── DAY-3-ORCHESTRATOR.md
│   │   ├── DAY-4-RAG-ENHANCEMENT.md
│   │   └── DAY-5-TESTING-DASHBOARDS.md
│   └── hooks/                        # Automated validation
│       ├── user-prompt-submit.sh     # Security: blocks dangerous commands
│       ├── tool-use-complete.sh      # Validation: JSON checks
│       └── agent-finish.sh           # Notifications: Slack integration
├── .github/
│   └── workflows/
│       └── claude.yml                # GitHub Actions CI/CD
├── docs/
│   ├── prd/
│   │   ├── Boring-Businesses-Platform-PRD.md
│   │   └── Boring-Businesses-Technical-Implementation-Plan.md
│   └── business-context.md           # James Playbook methodology
├── sql/                              # Database migrations
│   ├── 001_create_orchestrator_log.sql
│   ├── 002_opportunity_tables.sql
│   ├── 003_threshold_seed.sql
│   └── 004_runtime_logging.sql
├── workflows/                        # n8n workflow JSON (created by Day 2-4)
│   ├── 01-data-collection.json
│   ├── 02-orchestrator-james-playbook.json
│   ├── 03-rag-analysis-enhanced.json
│   └── building-blocks/              # Reusable n8n patterns
└── env.template                      # Local development credentials template
```

---

## 🔧 Development Workflow

### Using Claude Code Slash Commands

The platform includes 4 specialized agents for common tasks:

#### `/documentation-writer`
Create SOPs, runbooks, and technical documentation.

```
/documentation-writer

Create an SOP for deploying n8n workflows to production, including:
- Pre-deployment checklist
- Credential configuration steps
- Rollback procedures
```

**Output:** `docs/runbooks/workflow-deployment-sop.md`

#### `/sql-migrations`
Author PostgreSQL migrations with proper versioning.

```
/sql-migrations

Create a migration to add GIN indexes for JSONB search on the businesses table.
Include rollback instructions.
```

**Output:** `sql/005_add_jsonb_indexes.sql`

#### `/testing-agent`
Execute and validate workflows and data transformations.

```
/testing-agent

Test the RAG chat workflow end-to-end:
1. Trigger webhook with sample query
2. Verify database queries execute
3. Validate response structure
4. Measure response time
```

**Output:** `docs/testing/test-results-2025-10-25.md`

#### `/workflow-editor`
Modify n8n workflow JSON with precision.

```
/workflow-editor

Update the Apify data collection workflow to:
- Add retry logic for HTTP failures
- Include execution time tracking
- Add Sticky Note documenting rate limits
```

**Output:** `workflows/01-data-collection.json` (updated)

---

## 🛡️ Security & Validation

### Automated Hooks

**Security Hook** (`user-prompt-submit.sh`):
- Blocks dangerous commands: `rm -rf`, `cat .env`, etc.
- Prevents accidental credential exposure

**Validation Hook** (`tool-use-complete.sh`):
- Validates JSON syntax for all workflow files
- Logs all file changes to audit trail
- Prevents invalid workflows from being committed

**Notification Hook** (`agent-finish.sh`):
- Sends Slack notifications on agent task completion
- Includes modified file list and status

### Credential Management

**Never commit secrets to git!** All credentials are stored in:
1. **GitHub Secrets** (for CI/CD) - Encrypted, masked in logs
2. **n8n Credentials Vault** (for workflows) - Encrypted at rest
3. **Local `.env` file** (for development) - Git-ignored, `chmod 600`

See [.claude/SECRETS-REFERENCE.md](.claude/SECRETS-REFERENCE.md) for complete setup guide.

---

## 📊 Database Schema

### Core Tables

**opportunity_hypotheses**
- Hypothesis definitions and lifecycle tracking
- Status: `draft` → `in_analysis` → `validated`/`needs_review`/`discarded`

**businesses**
- Scraped business data from Apify
- JSONB for flexible API response storage
- Indexed on `apify_place_id` for UPSERT idempotency

**business_reviews**
- Flattened review data with sentiment analysis
- Foreign key to businesses
- Supports semantic search via PGVector

**opportunities**
- Validated hypotheses with calculated metrics
- Threshold comparison results
- Newsletter drafts and lead lists

**market_executions**
- Workflow run tracking
- SLA monitoring (execution duration)
- Success/failure statistics

### Strategic Views

8 SQL views for market analysis:
- `niche_opportunities` - Market gap analysis
- `customer_pain_points` - Negative review patterns
- `market_leaders` - Top performers by category/city
- `vulnerable_players` - Declining businesses
- `review_velocity_trends` - Growth trajectories
- `niche_service_gaps` - Unmet demand discovery
- `business_model_opportunities` - Newsletter viability scoring
- `niche_swot_analysis` - Competitive SWOT by category

See `sql/` directory for complete schema definitions.

---

## 🤖 AI Model Strategy

### Multi-Model Cost Optimization

| Task | Model | Why | Cost/1K Requests |
|------|-------|-----|------------------|
| Sentiment analysis | Gemini Flash | Fast, cheap, accurate | ~$0.05 |
| Keyword extraction | Gemini Flash | Bulk processing | ~$0.05 |
| Business classification | Gemini Pro | Nuanced categorization | ~$0.50 |
| Hypothesis analysis | Claude Sonnet | Deep reasoning, long context | ~$3.00 |
| Newsletter generation | GPT-4 | Best writing quality | ~$5.00 |
| RAG chat interface | Claude Sonnet | Conversational, context-aware | ~$2.50 |

**Monthly savings:** ~$80/month (53% reduction vs OpenAI-only)

### Automatic Failover

**OpenRouter** provides redundancy:
- If OpenAI has an outage → Routes to Claude/Gemini automatically
- Zero downtime during provider incidents
- Cost optimization via model selection

---

## 📈 Usage Examples

### Validate a Hypothesis

```bash
# Trigger orchestrator workflow via webhook
curl -X POST https://n8n.avgj.io/webhook/orchestrator/hypothesis/run \
  -H 'Content-Type: application/json' \
  -d '{
    "hypothesis_id": "charlotte-luxury-tax-2025-10"
  }'
```

**What happens:**
1. Apify scrapes 100 businesses + 500 reviews (Charlotte luxury tax advisors)
2. Data stored in PostgreSQL with JSONB flexibility
3. AI analyzes sentiment, keywords, pain points
4. Metrics compared against thresholds (review velocity, provider density, etc.)
5. Status determined: `validated` (generate newsletter) or `needs_review` (manual check)
6. Slack notification with results + action buttons

### Query Market Data via RAG

```bash
# Chat with your data
curl -X POST https://n8n.avgj.io/webhook/rag-chat \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "What are the top 3 complaints about HVAC services in Denver?",
    "conversation_id": "session-123"
  }'
```

**Response:**
```json
{
  "answer": "Based on 487 reviews, top complaints are:\n1. Long wait times (mentioned in 23% of negative reviews)\n2. High prices for simple repairs (18%)\n3. Upselling unnecessary services (15%)",
  "sources": [
    {"business": "ABC HVAC", "review_count": 156},
    {"business": "Denver Comfort", "review_count": 98}
  ],
  "confidence": 0.92
}
```

### Generate Strategic Analysis

```sql
-- Find high-opportunity niches in Charlotte
SELECT
  category,
  city,
  opportunity_score,
  avg_rating,
  market_saturation,
  growth_trend
FROM niche_opportunities
WHERE city = 'Charlotte'
  AND opportunity_score > 0.7
ORDER BY opportunity_score DESC
LIMIT 10;
```

---

## 🧪 Testing

### Automated Test Suite

```bash
# Run all 40 tests (database, workflows, RAG, tools)
psql "$NEON_CONNECTION_STRING" -f schema/run-tests.sql

# Expected output:
# ✅ 38/40 tests passed (95%)
# ⚠️  2 tests skipped (manual validation required)
```

### Test Categories

1. **Database Health** (8 tests) - Tables, indexes, triggers, views
2. **Data Collection Workflow** (6 tests) - UPSERT, batch, JSONB
3. **RAG Chat Interface** (5 tests) - Webhook, agent, memory, tools
4. **AI Tool Execution** (7 tests) - All 3 tools validated
5. **Error Handling** (4 tests) - Invalid SQL, NULLs, duplicates
6. **Performance** (5 tests) - Index usage, <100ms queries
7. **End-to-End** (5 tests) - Complete workflows, multi-turn chat

See `docs/testing/` for detailed test plans and results.

---

## 🚨 Troubleshooting

### GitHub Actions Failing

**Check secrets:**
```bash
gh secret list
# Verify all 8 secrets configured
```

**View logs:**
```bash
gh run list --limit 5
gh run view <run-id> --log
```

### Database Connection Issues

**Test connection:**
```bash
psql "$NEON_CONNECTION_STRING" -c "SELECT version();"
```

**Common issues:**
- SSL required: Ensure `?sslmode=require` in connection string
- IP whitelist: Check Neon dashboard for allowed IPs

### n8n Workflows Not Executing

**Verify credentials:**
- n8n → Credentials → Check all configured
- Test each credential individually

**Check webhook URLs:**
```bash
# Trigger manually
curl -X POST https://n8n.avgj.io/webhook-test/your-workflow
```

### Slack Notifications Not Appearing

**Verify bot setup:**
```bash
# Test bot token
curl -X POST https://slack.com/api/auth.test \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN"
```

**Check channel invitation:**
```slack
/invite @Boring Businesses Platform
```

See [.claude/SECRETS-REFERENCE.md](.claude/SECRETS-REFERENCE.md) for comprehensive troubleshooting.

---

## 📚 Documentation

- **[PRD](docs/prd/Boring-Businesses-Platform-PRD.md)** - Complete product requirements
- **[Technical Implementation Plan](docs/prd/Boring-Businesses-Technical-Implementation-Plan.md)** - 5-day sprint details
- **[Business Context](docs/business-context.md)** - James Playbook methodology
- **[Secrets Reference](.claude/SECRETS-REFERENCE.md)** - Credential setup guide
- **[Claude Code Configuration](.claude/README.md)** - Agents, hooks, slash commands

---

## 🤝 Contributing

This is a private business intelligence platform. For collaborators:

### Development Standards

- **TypeScript strict mode** when applicable
- **Test coverage required** before committing
- **Document WHY, not just WHAT** in code comments
- **Binary success criteria** for all features

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes, test locally
psql "$NEON_CONNECTION_STRING" -f schema/run-tests.sql

# Commit with descriptive message
git commit -m "Add: high-ticket confidence scoring algorithm

- Implements weighted scoring across 5 signals
- Includes test coverage for edge cases
- Updates documentation with algorithm explanation"

# Push and create PR
git push origin feature/your-feature-name
gh pr create --title "Add high-ticket confidence scoring"
```

### PR Requirements

- ✅ All tests pass (40/40 target)
- ✅ Documentation updated
- ✅ No secrets committed
- ✅ JSON validated (workflows)
- ✅ PRD alignment confirmed

---

## 📞 Support

### For Issues

1. Check [troubleshooting section](#-troubleshooting) above
2. Review relevant documentation in `docs/`
3. Check GitHub Actions logs for CI/CD issues
4. Review Slack #boring-ops for notifications

### For Questions

- **Architecture**: See [Technical Implementation Plan](docs/prd/Boring-Businesses-Technical-Implementation-Plan.md)
- **Business Logic**: See [Business Context](docs/business-context.md)
- **Credentials**: See [Secrets Reference](.claude/SECRETS-REFERENCE.md)

---

## 📄 License

Proprietary - All Rights Reserved

**Copyright © 2025 Alex Johnson**

This software and associated documentation are confidential and proprietary. Unauthorized copying, distribution, or use is strictly prohibited.

---

## 🙏 Acknowledgments

**Technologies:**
- [Claude Code](https://claude.com/claude-code) by Anthropic - Autonomous development
- [n8n](https://n8n.io/) - Workflow automation
- [Neon](https://neon.tech/) - Serverless PostgreSQL
- [Apify](https://apify.com/) - Web scraping infrastructure

**Methodology:**
- **James Playbook** - Boring businesses opportunity framework

---

**Built with Claude Code** - Autonomous AI-powered development

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

## Testing Neon Branch-per-PR Workflow

This PR tests the automatic Neon database branching workflow.
