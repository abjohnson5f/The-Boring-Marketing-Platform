# Boring Businesses Platform - Business Glossary

**Purpose**: Standardized terminology for AI agents, documentation, and team communication. All agents must use these terms consistently to prevent context loss.

---

## Core Business Concepts

### James "The Boring Marketer" Playbook
The strategic framework for discovering, validating, and monetizing underserved service niches:
1. **Discover**: Use AI + Google Maps to identify high-value micro-niches
2. **Validate**: Measure demand via review velocity, sentiment, channel gaps
3. **Media-First**: Launch newsletter/directory to build audience
4. **Monetize**: Resell leads ($100-200 each) or partner with operators
5. **Optional Own**: Transition to operational ownership when data justifies

**Example**: Diesel Dudes (mobile diesel mechanics) - $30k/mo, $1.6k/job, 10 inbound calls/day

---

### Tier 2/3 Cities
Fast-growing metropolitan areas outside major hubs (NYC, LA, SF, Chicago).

**Characteristics**:
- Population: 200k - 2M
- Lower competition than Tier 1
- Growing affluent consumer base
- Examples: Charlotte, Nashville, Denver, Austin, Raleigh

**Why Target**: Underserved markets with high demand, lower CAC, less saturated competition.

---

### Media-Led GTM (Go-To-Market)
Launch newsletters, directories, or niche media properties **before** offering services.

**Benefits**:
- Build audience ownership (email list, social following)
- Monetize via lead resale without operational overhead
- Validate demand before capital deployment
- De-risks expansion into service delivery

**Contrast**: Traditional approach requires immediate operational investment (trucks, technicians, insurance).

---

## Key Market Intelligence Metrics

### Review Velocity (RV)
**Definition**: Average number of new reviews per 30 days across top providers in a niche/city.

**Calculation**:
```
RV = (Total new reviews in last 30 days) / (Number of providers)
```

**Threshold**: ≥10 reviews/month (indicates active demand)

**Signal**: High velocity = strong customer engagement, repeat business, growing market

**Example**:
- Charlotte luxury tax advisors: 18.4 reviews/month → **Strong demand**
- Nashville pool resurfacing: 3.2 reviews/month → **Weak demand**

---

### Provider Density (PD)
**Definition**: Count of providers serving a specific niche in a city.

**Calculation**:
```
PD = COUNT(providers WHERE search_string AND city)
```

**Threshold**: ≤12 providers (indicates undersupplied market)

**Signal**: Low density = less competition, room for new entrants

**Example**:
- Denver exotic car wraps: 7 providers → **Undersupplied**
- Dallas general plumbing: 156 providers → **Saturated**

---

### Incumbent Ratio (INC)
**Definition**: Fraction of providers with dominant market position (high ratings, low variance, strong review base).

**Calculation**:
```
Incumbent = (rating ≥4.6 AND variance <0.15 AND reviews >100)
INC = COUNT(incumbents) / COUNT(total_providers)
```

**Threshold**: ≤0.35 (indicates contestable market)

**Signal**: Low ratio = market is up for grabs, high ratio = entrenched competition

**Example**:
- Charlotte luxury tax: INC = 0.22 (2 strong players out of 9) → **Contestable**
- Austin HVAC: INC = 0.68 → **Dominated by incumbents**

---

### Sentiment Balance
**Definition**: Percentage difference between negative and positive reviews.

**Calculation**:
```
Sentiment Balance = (%negative reviews) - (%positive reviews)
```

**Threshold**: ≤-10% (more positive than negative)

**Signal**: Negative-heavy sentiment = service quality gaps, positioning opportunities

**Example**:
- Nashville mobile RV repair: 46% negative, 31% positive = +15% → **Service gap detected**
- Denver dog grooming: 12% negative, 74% positive = -62% → **High satisfaction**

---

### Channel Presence Score
**Definition**: Weighted presence across key marketing channels.

**Calculation**:
```
Score = (0.3 × has_instagram) + (0.2 × has_facebook) +
        (0.3 × has_website) + (0.2 × has_linkedin)
Range: 0 (no presence) to 1 (full coverage)
```

**Threshold**: ≤0.5 (indicates marketing gap)

**Signal**: Low score = opportunity to dominate via superior marketing

**Example**:
- Luxury tax advisors Charlotte: 0.4 score (missing Instagram, weak website) → **Marketing gap**

---

### High-Ticket Confidence
**Definition**: LLM-derived confidence that services command premium pricing ($3k-15k+).

**Calculation**: LLM analyzes review text for pricing signals + keyword heuristics

**Threshold**: ≥0.7 confidence score

**Signal**: High-ticket services support premium lead pricing ($150-200/lead)

**Keywords**: "expensive", "investment", "premium", "custom", "luxury", "specialized"

**Example**:
- Exotic car wraps: 0.86 confidence (reviews mention "$5k-12k jobs") → **High-ticket confirmed**
- Lawn mowing: 0.23 confidence (reviews mention "$30-50/visit") → **Commodity service**

---

### Lead Viability Score
**Definition**: Count of providers missing critical contact channels (phone, email, website).

**Calculation**:
```
Lead Viability = COUNT(providers WHERE missing_phone OR missing_email OR missing_website)
```

**Threshold**: ≥3 providers (bonus indicator, not mandatory)

**Signal**: More leads to resell to better-marketed competitors

---

## Hypothesis Management

### Hypothesis
A testable market opportunity combining niche + city + rationale.

**Example**:
```
Niche: Luxury tax advisory
City: Charlotte, NC
Rationale: High W2 income ($120k+ median), growing tech/finance sector,
           only 7 providers, reviews mention "hard to find qualified advisor"
```

---

### Hypothesis States

| State | Definition | Trigger | Next Actions |
|-------|-----------|---------|--------------|
| `new` | Hypothesis created but not yet reviewed | Operator creates via form/prompt | Manual Apify crawl, data review |
| `ready_for_review` | Manual Apify crawl completed, awaiting approval | Operator marks ready | Human reviews data quality, approves or rejects |
| `in_analysis` | Approved for automated processing | Operator clicks "Approve" button | Orchestrator runs (ETL → RAG → Scoring) |
| `validated` | All thresholds passed, opportunity confirmed | Scoring engine | Generate newsletter, create lead tasks, notify team |
| `needs_review` | Exactly 1 threshold failed | Scoring engine | Human review with remediation notes |
| `discarded` | 2+ thresholds failed, not viable | Scoring engine | Archive, log reason, update dashboards |
| `blocked` | Technical failure (Apify error, KG timeout) | Error handler | Manual intervention required <1hr |
| `in_campaign` | Newsletter/lead-gen active | Marketing team | Track performance, conversion rates |
| `monetized` | Leads sold or partnership revenue generated | Finance team | Record in lead_transactions table |

---

## Data Pipeline Concepts

### Apify Run
Execution of Google Maps scraper returning business listings, reviews, contacts, hours.

**Outputs**: JSON dataset with fields like `title`, `address`, `rating`, `reviews`, `socialMedia`, `popularTimes`

**Tracking**: `apify_run_id` (e.g., "r-a1b2c3d4"), stored in `opportunity_runs.apify_run_id`

---

### ETL (Extract, Transform, Load)
Process of fetching Apify data → normalizing → inserting into Postgres tables.

**Stages**:
1. **Extract**: HTTP GET to Apify API
2. **Transform**: Flatten reviews array, normalize casing, dedupe
3. **Load**: UPSERT into `businesses`, `business_reviews`, `contacts`, etc.

**Tracking**: Each stage logged to `etl_logs` with timestamps, row counts, errors

---

### Knowledge Graph (KG)
Neo4j graph database storing entity relationships (businesses, reviewers, services, competitors).

**Tools**: Graphiti MCP server (`add_memory`, `search_memory_nodes`, `get_entity_edge`)

**Use Cases**:
- "How are Provider A and Provider B connected?" → Shared reviewers, mentioned competitors
- "Which services are frequently mentioned together?" → Bundling opportunities
- "What do negative reviews cite as pain points?" → Positioning angles

**Fallback**: If KG query >5s, fall back to SQL-only analysis

---

### RAG (Retrieval-Augmented Generation)
Hybrid search combining PGVector (semantic embeddings) + Neo4j KG (entity relationships) + SQL (structured metrics).

**Workflow**: User query → Retrieve relevant docs/entities → Augment LLM prompt → Generate response

**Reranker**: Cohere model improves retrieval precision (relevance scores >0.8 target)

---

## Opportunity Management

### Opportunity
Validated market niche ready for monetization activities (newsletter, lead-gen, partnership).

**Required Fields**:
- `hypothesis_id` (source hypothesis)
- `status` (validated, in_campaign, monetized)
- `summary` (market analysis narrative)
- `metrics` (JSONB with RV, PD, INC, sentiment, channel, high-ticket scores)

**Stored In**: `opportunities` table

---

### Lead Task
Outreach assignment targeting specific business for lead resale or partnership.

**Fields**:
- `business_id` (target provider)
- `contact_priority` (1-10, based on marketing gaps + revenue potential)
- `outreach_channel` (phone, email, linkedin, instagram)
- `status` (pending, contacted, converted, declined)

**Automation**: Top 10 targets per validated hypothesis automatically assigned

---

### Newsletter Issue
AI-generated newsletter draft for niche audience.

**Fields**:
- `opportunity_id` (source market)
- `subject_lines` (3-5 options)
- `angle` (positioning: "after-hours support gap", "luxury service void")
- `customer_value` (what subscribers gain)
- `status` (draft, scheduled, sent)

**Monetization**: Sponsorships, affiliate links, lead capture forms

---

## Technical Stack Terms

### n8n
Open-source workflow automation platform (self-hosted on Hostinger VPS ~$5-7/mo).

**Node Types**:
- `Webhook` - HTTP trigger
- `Postgres` - Database operations
- `Execute Workflow` - Call sub-workflows
- `Function` - Custom JavaScript
- `IF` - Conditional branching
- `Merge` - Combine data streams
- `LangChain Agent` - AI decision-making

---

### Neon Postgres
Serverless Postgres with PGVector extension for embeddings.

**Key Tables**:
- `opportunity_hypotheses` - Market ideas
- `opportunity_runs` - Execution history
- `opportunities` - Validated markets
- `opportunity_metrics` - JSONB scoring data
- `newsletter_issues` - Content drafts
- `lead_tasks` - Outreach assignments
- `lead_transactions` - Revenue tracking

---

### PGVector
Postgres extension for storing and searching vector embeddings (semantic search).

**Index Type**: GIN (Generalized Inverted Index) for fast JSONB + vector lookups

**Use Case**: Find businesses/reviews semantically similar to query text

---

### JSONB
Postgres native JSON data type with indexing and querying capabilities.

**Why Use**:
- **Flexible schema**: Apify changes don't break database
- **Fast queries**: GIN indexes enable key lookups
- **RAG-friendly**: Semi-structured data works with LLMs
- **Simple**: No need for 8 separate dimension tables

**Example**:
```json
{
  "review_velocity_month": 18.4,
  "provider_density": 7,
  "sentiment_positive_pct": 31,
  "notable_quotes": ["Clients complain about lack of after-hours support"]
}
```

---

### Hostinger VPS
Virtual Private Server hosting n8n, Neo4j, and supporting services.

**Cost**: $5-7/month (vs. cloud providers $50-100/mo)

**Advantage**: Unlimited workflow executions (cloud n8n charges per execution)

---

## Operational Terms

### SOP (Standard Operating Procedure)
Step-by-step instructions for executing repeatable processes.

**Examples**:
- `docs/runbooks/orchestrator-playbook.md` - How to run hypothesis pipeline
- `docs/runbooks/postgres-ingestion.md` - How to refresh Apify data

**Format**: Markdown with numbered steps, copy-pasteable commands, verification checks

---

### Orchestrator
Master n8n workflow that coordinates hypothesis processing end-to-end.

**Stages**:
1. Pre-flight validation
2. Trigger Apify ETL
3. Execute RAG analysis
4. Run scoring engine
5. Update hypothesis status
6. Trigger automation (newsletter, leads)
7. Log metrics

**SLA Target**: <10 minutes per hypothesis

---

### Human-in-the-Loop
Manual approval gate before automation executes.

**Current HITL Steps**:
1. Operator generates hypothesis (LLM prompt or manual entry)
2. Operator runs **manual** Apify crawl (10-30 min)
3. Operator reviews data quality
4. Operator clicks "Approve" → hypothesis moves to `in_analysis`
5. Automation takes over from there

**Rationale**: Prevents bad data from polluting pipeline, keeps operator in control

---

## Financial Terms

### Lead Resale
Selling qualified business contacts to operators/partners.

**Typical Pricing**: $100-200 per lead (high-ticket services command premium)

**Example**: Charlotte luxury tax advisor with no website, 4.2 rating, 87 reviews → $150 lead

---

### Partnership Model
Revenue-sharing arrangement where Boring Businesses provides leads, partner provides service delivery.

**Structure**:
- Lead fee: $100-200 upfront
- Revenue share: 10-20% of job value (for ongoing deals)
- Performance tracking: Stored in `lead_transactions` table

---

### Unit Economics
Financial metrics per customer/lead.

**Target Metrics**:
- Lead price: $100-200
- Conversion rate: 20-30% (leads → paying partners)
- Monthly revenue: $20k+ by month 6
- CAC (Customer Acquisition Cost): <$50 via organic/SEO

**Proof Point**: Diesel Dudes $1.6k/job × 10 calls/day × 30% close = $144k/month potential

---

## Compliance & Ethics Terms

### robots.txt
File specifying which URLs crawlers can access.

**Policy**: Respect robots.txt directives, throttle requests, prefer official APIs

**Note**: Google Maps data is public, but excessive scraping violates TOS

---

### Data Retention Policy
Rules for how long reviewer/business data is stored.

**Current Policy**: Keep run history for trend analysis, mark stale runs (>30 days) for refresh

**Compliance**: No PII sensitivity detected (all public business data)

---

## Agent-Specific Terms

### Idempotent Migration
SQL migration that can be run multiple times without errors or data corruption.

**Techniques**:
- `CREATE TABLE IF NOT EXISTS`
- `CREATE INDEX IF NOT EXISTS`
- `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
- UPSERT on unique keys

**Why Required**: Re-running migrations shouldn't break production

---

### Binary Success Criteria
Test outcomes that are objectively PASS or FAIL (not subjective "looks good").

**Examples**:
- ✅ Good: "Query responds in <100ms P95"
- ❌ Bad: "Performance is acceptable"
- ✅ Good: "Review velocity ≥10"
- ❌ Bad: "Demand seems strong"

**Why Required**: Enables automated testing, removes ambiguity

---

### Surgical Editing
Modifying specific parts of large files (like 162KB workflow JSON) without affecting unrelated sections.

**Techniques**:
- Preserve credential IDs
- Maintain node connections
- Validate JSON syntax after changes
- Use precise search/replace (not regenerate entire file)

**Why Required**: Prevents breaking production workflows

---

## Acronyms Quick Reference

| Acronym | Full Term | Context |
|---------|-----------|---------|
| RV | Review Velocity | Market demand metric |
| PD | Provider Density | Competition metric |
| INC | Incumbent Ratio | Market contestability |
| GTM | Go-To-Market | Launch strategy |
| SOP | Standard Operating Procedure | Operational runbook |
| KG | Knowledge Graph | Neo4j relationship database |
| RAG | Retrieval-Augmented Generation | Hybrid search + LLM |
| ETL | Extract, Transform, Load | Data pipeline |
| HITL | Human-in-the-Loop | Manual approval gate |
| CAC | Customer Acquisition Cost | Marketing efficiency |
| SLA | Service Level Agreement | Performance target |
| PRD | Product Requirements Document | Project specification |

---

## Usage Instructions for AI Agents

**When generating documentation**:
- Use terms from this glossary exactly (e.g., "Review Velocity", not "review speed")
- Reference thresholds with specific numbers (≥10, not "high")
- Include glossary term in parentheses on first use in document

**When writing code/SQL**:
- Use table names from glossary (`opportunity_hypotheses`, not `hypotheses`)
- Use field names from glossary (`review_velocity_month`, not `velocity`)
- Include comments referencing glossary terms

**When testing**:
- Validate against thresholds defined in glossary
- Use binary success criteria (PASS/FAIL)
- Reference specific metrics (RV ≥10, not "strong demand")

**When creating examples**:
- Use realistic city/niche combinations from tier 2/3 cities
- Reference pricing models from glossary ($100-200/lead)
- Cite proof points (Diesel Dudes $30k/mo)

---

**Last Updated**: October 24, 2025
**Maintained By**: Claude Code Configuration Team
**Version**: 1.0
