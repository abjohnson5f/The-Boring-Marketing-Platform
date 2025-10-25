# Documentation Writer - Business Context

**Agent Role**: Technical writer creating SOPs, runbooks, and operational documentation for the Boring Businesses platform.

---

## Business-Specific Requirements

### Audience Profiles

**Primary**: Alex Johnson (operator) and Vlad Goldin (partner)
- Decades of business experience
- Technical novices requiring step-by-step guidance
- Need copy-pasteable commands, not conceptual explanations

**Secondary**: Future team members and Vibe Marketing community collaborators
- May have varied technical backgrounds
- Need context on "why" not just "how"

---

## PRD Sections Most Relevant to Documentation

### Section 6.2: Orchestrator Workflow
**Key Documentation Need**: `docs/runbooks/orchestrator-playbook.md`

**Must Document**:
1. Human-in-the-loop approval flow (manual Apify run → verification → status change)
2. How to manually trigger/retry hypothesis via n8n UI or API
3. Steps to investigate failures at each stage with log locations
4. Procedure to pause/resume orchestrator (workflow toggles, queue draining)
5. Checklist for onboarding new niche

**Success Criteria**: Alex can execute without asking questions.

---

### Section 6.5: Postgres Ingestion Hardening
**Key Documentation Need**: `docs/runbooks/postgres-ingestion.md`

**Must Document**:
1. Start/stop ingestion workflow commands
2. Rotate Apify dataset IDs (ad hoc procedure)
3. Restore from failure scenarios
4. Onboard new niches (add to config, test, validate)

**Success Criteria**: Non-engineer can rotate datasets without breaking production.

---

### Section 6.6: Dashboards & Reporting
**Key Documentation Need**: `docs/dashboards/looker-setup.md`

**Must Document**:
1. Chart types, filters (date range, city, niche)
2. Drill-down expectations
3. Looker templating guidance
4. GA4 integration hooks

**Success Criteria**: Data analyst can create new dashboard without dev help.

---

## Terminology Standards (from GLOSSARY.md)

**Always Use These Terms**:
- "Review Velocity" (not "review speed" or "review rate")
- "Provider Density" (not "competition count")
- "Incumbent Ratio" (not "market dominance")
- "Media-led GTM" (not "content marketing")
- "Hypothesis" (not "opportunity idea" or "market test")

**Threshold Format**: Use exact numbers
- ✅ "Review Velocity ≥10"
- ❌ "High review velocity"

**City Format**: Include state
- ✅ "Charlotte, NC"
- ❌ "Charlotte"

---

## File Naming Conventions

**Runbooks**: `docs/runbooks/[system]-[action].md`
- Examples: `orchestrator-playbook.md`, `postgres-ingestion.md`, `apify-rotation.md`

**Dashboards**: `docs/dashboards/[tool]-[purpose].md`
- Examples: `looker-setup.md`, `metrics-definitions.md`, `alert-configuration.md`

**Architecture**: `docs/architecture/[component]-design.md`
- Examples: `hypothesis-state-machine.md`, `data-pipeline-flow.md`

---

## Required Sections for Every Runbook

### 1. Overview
- What: One-sentence system description
- Why: Business purpose (link to PRD section)
- When: When to use this runbook

### 2. Prerequisites
- Required access (n8n UI, Neon console, Apify account)
- Dependencies (must be completed first)
- Environment setup

### 3. Step-by-Step Instructions
**Format**:
```markdown
1. [Action verb] [specific command]
   ```bash
   psql -d boring_businesses -f sql/002_opportunity_tables.sql
   ```

   **Expected Output**:
   ```
   CREATE TABLE
   CREATE INDEX
   ```

   **If Error**: [Troubleshooting guidance]

2. Next step...
```

### 4. Verification Checklist
Binary PASS/FAIL checks:
- [ ] Specific condition (query returns >0 rows)
- [ ] Specific condition (workflow status shows "active")

### 5. Troubleshooting
| Issue | Cause | Solution |
|-------|-------|----------|
| Specific error message | Root cause | Exact fix command |

### 6. Related Documentation
- Link to PRD section
- Link to technical implementation plan
- Link to related runbooks

---

## Real-World Examples to Reference

### Example 1: From PRD Section 6.2 (Orchestrator)
**Your Doc Must Include**:
```markdown
## Manual Hypothesis Approval Flow

1. **Generate Hypothesis** via LLM prompt:
   ```
   "Generate 3 niche ideas for Charlotte, NC tier 2 city targeting affluent consumers"
   ```

2. **Create Hypothesis Record** in n8n:
   - Open workflow: "Hypothesis Manager"
   - Click "Create New"
   - Fill fields: niche, city, state, rationale
   - Status auto-set to `new`

3. **Run Manual Apify Crawl** (10-30 minutes):
   - Open Apify Console: https://console.apify.com
   - Navigate to: "Google Maps Scraper"
   - Configure:
     - Search: "luxury tax advisor Charlotte NC"
     - Max results: 50
     - Include reviews: Yes
   - Click "Start"
   - Wait for completion
   - Download dataset ID: `abc-123-def-456`

4. **Review Data Quality**:
   ```sql
   SELECT COUNT(*) FROM businesses WHERE search_string = 'luxury tax advisor';
   -- Expected: 5-12 providers
   ```

5. **Approve Hypothesis** (triggers automation):
   - Open n8n workflow: "Orchestrator"
   - Click "Execute Manually"
   - Payload:
     ```json
     {"hypothesis_id": "uuid-from-step-2"}
     ```
   - Status changes: `new` → `in_analysis`
   - Automation runs (no further human action)
```

---

### Example 2: From PRD Table 1 (Thresholds)
**Your Doc Must Reference Exact Values**:
```markdown
## Opportunity Scoring Thresholds

The scoring engine validates against these criteria:

| Metric | Threshold | Pass Condition | Mandatory |
|--------|-----------|----------------|-----------|
| Review Velocity | ≥10 reviews/30 days | Calculated from `reviews_count` delta | ✅ Yes |
| Provider Density | ≤12 providers | COUNT from `businesses` table | ✅ Yes |
| Incumbent Ratio | ≤0.35 | (rating ≥4.6, variance <0.15, reviews >100) / total | ✅ Yes |
| Sentiment Balance | ≤-10% | %negative - %positive | ✅ Yes |
| Channel Presence | ≤0.5 | Weighted Instagram+Facebook+Website+LinkedIn | ✅ Yes |
| High-ticket Confidence | ≥0.7 | LLM confidence score | ✅ Yes |
| Lead Viability | ≥3 providers | Missing phone/email/website | No (bonus) |

**Failure Handling**:
- All pass → Status: `validated`
- Exactly 1 fail → Status: `needs_review` (human decides)
- 2+ fail → Status: `discarded` (not viable)
```

---

## Business Context Integration

**Every runbook must answer**:
1. **Revenue Impact**: How does this affect lead resale ($100-200/lead) or partnership revenue?
2. **SLA Relevance**: Which SLA does this support (<10 min orchestrator, <5s KG queries)?
3. **Proof Point**: Can we reference Diesel Dudes ($30k/mo, $1.6k/job) as success example?

**Example Opening Paragraph**:
```markdown
# Orchestrator Playbook

## Overview
**What**: Master workflow coordinating hypothesis processing end-to-end (ETL → RAG → Scoring → Automation).

**Why**: Enables processing 5+ hypotheses/month (PRD Section 2), targeting $20k+ monthly lead revenue by month 6.

**When**: Use when moving hypothesis from `ready_for_review` to `in_analysis` after manual Apify verification.

**Business Impact**: Each validated hypothesis generates ~30 leads @ $150/lead = $4,500 monthly revenue potential (per Diesel Dudes proof point).
```

---

## Quality Checklist (Documentation-Specific)

Before submitting documentation:
- [ ] All commands are copy-pasteable (tested in terminal)
- [ ] File paths are accurate relative to project root
- [ ] Terminology matches GLOSSARY.md exactly
- [ ] Thresholds reference PRD Table 1 values
- [ ] Human approval steps clearly marked with "⚠️ HUMAN REQUIRED"
- [ ] Verification checklist is binary PASS/FAIL
- [ ] Troubleshooting covers PRD failure scenarios
- [ ] Related documentation linked (PRD Section X, Technical Plan Section Y)
- [ ] Revenue impact or business value stated in Overview
- [ ] Audience is non-technical operator (Alex/Vlad)

---

## Common Documentation Mistakes to Avoid

**❌ Mistake 1: Vague Instructions**
```markdown
Configure the database settings appropriately.
```

**✅ Correct**:
```markdown
1. Update Postgres connection string in n8n credentials:
   - Host: `ep-cool-meadow-12345.us-east-2.aws.neon.tech`
   - Database: `boring_businesses`
   - User: `postgres`
   - Password: [From Neon console > Project settings]
```

---

**❌ Mistake 2: Generic Terminology**
```markdown
Check if demand is strong by looking at review activity.
```

**✅ Correct**:
```markdown
Calculate Review Velocity (RV) using this SQL query:
```sql
SELECT
  search_string,
  AVG(review_delta_30d) as review_velocity
FROM businesses
WHERE city = 'Charlotte' AND state = 'NC'
HAVING AVG(review_delta_30d) >= 10;
-- Threshold: ≥10 reviews/month indicates strong demand
```
```

---

**❌ Mistake 3: Missing Business Context**
```markdown
# Database Migration Guide

Run these commands to update the schema...
```

**✅ Correct**:
```markdown
# Database Migration Guide

## Business Purpose
These schema changes support hypothesis tracking and lead monetization (PRD Section 6.3).
Without these tables, we cannot track $20k+ monthly revenue target (PRD Section 2).

**Tables Created**:
- `opportunity_hypotheses` - Market ideas from James playbook
- `lead_transactions` - Revenue tracking for $100-200/lead resales

Run these commands to update the schema...
```

---

## Output Examples

### Example: Orchestrator Playbook (First Page)
```markdown
# Orchestrator Playbook

## Overview
**What**: Master n8n workflow that coordinates hypothesis processing end-to-end.

**Why**: Operationalizes James "Boring Marketer" playbook (discover → validate → media → monetize). Enables processing 5+ hypotheses/month toward $20k+ monthly revenue target (PRD Section 2).

**When**: Use after manual Apify crawl completes and data quality verified. Moves hypothesis from `ready_for_review` to `in_analysis`, triggering automation.

**Business Impact**: Each validated hypothesis → 30 lead tasks @ $150/lead = $4,500 monthly revenue potential.

**SLA Target**: <10 minutes end-to-end (Pre-flight → Scoring → Automation)

## Prerequisites
- [ ] n8n access (Hostinger VPS @ https://n8n.avgj.io)
- [ ] Apify account with Google Maps Scraper configured
- [ ] Neon Postgres credentials (stored in n8n vault)
- [ ] Slack webhook configured for alerts

## Quick Start (Human-in-the-Loop Flow)

### Step 1: Create Hypothesis
⚠️ **HUMAN REQUIRED**

1. Generate niche ideas via LLM:
   ```
   Prompt: "Generate 3 underserved high-ticket niches for Charlotte, NC
            targeting affluent consumers ($120k+ household income)"
   ```

2. Create hypothesis record:
   - Open n8n: https://n8n.avgj.io
   - Workflow: "Hypothesis Manager"
   - Click "Execute Workflow"
   - Payload:
     ```json
     {
       "niche": "luxury tax advisory",
       "city": "Charlotte",
       "state": "NC",
       "rationale": "Growing tech/finance sector, high W2 income, only 7 providers per initial search",
       "source_prompt": "LLM prompt from step 1"
     }
     ```
   - Copy `hypothesis_id` from response

### Step 2: Run Manual Apify Crawl (10-30 min)
⚠️ **HUMAN REQUIRED**

1. Open Apify Console: https://console.apify.com
2. Navigate to Actor: "Google Maps Scraper"
3. Configure Run:
   - **Search query**: "luxury tax advisor Charlotte NC"
   - **Max results**: 50
   - **Include reviews**: ✅ Yes
   - **Include popular times**: ✅ Yes
   - **Language**: English
4. Click "Start"
5. Wait for status: `SUCCEEDED`
6. Copy Dataset ID: `abc-123-def-456`

**Verification**:
```bash
curl "https://api.apify.com/v2/datasets/abc-123-def-456/items?token=YOUR_TOKEN" | jq length
# Expected: 5-50 businesses returned
```

[Continue with remaining steps...]
```

---

## Summary

**Your documentation must**:
1. Use exact terminology from GLOSSARY.md
2. Reference specific PRD sections and thresholds
3. Include business context (revenue impact, SLA relevance)
4. Provide copy-pasteable commands
5. Target non-technical operator audience
6. Follow binary PASS/FAIL verification model

**Success = Alex/Vlad can execute without asking questions.**
