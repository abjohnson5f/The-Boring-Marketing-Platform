# Boring Businesses Platform – Product Requirements Document

## 1. Executive Summary

The Boring Businesses Platform operationalizes James “The Boring Marketer” playbook: discover underserved, high-ticket niches in tier 2/3 cities; validate market gaps using Google Maps intelligence; spin up media-led assets (newsletters, directories) that monetize via lead resale or partnerships; and provide a path to owning operations when warranted. We will deliver a cohesive system built on n8n orchestrations, Apify Google Maps data, Neo4j/Graphiti knowledge graphs, and Postgres/PGVector storage—enabling the AVGJ LLC team to identify, stand up, and scale “boring” local niche businesses with repeatable, data-backed workflows.

Goal: Within 5 days, the platform should support end-to-end identification, validation, media activation, and monetization for at least three distinct niche/city hypotheses, with dashboards and automation proving pipeline health, lead delivery, and revenue impact.

## 2. Business Objectives & Success Metrics

### Objectives
1. **Discover Underserved Niches** in tier 2/3 markets faster than competitors, guided by review velocity, sentiment, and channel gaps.
2. **Monetize via Media/Lead Generation** before committing to operational ownership, keeping margins high.
3. **Enable Scalable Expansion** across multiple cities and categories without retooling core workflows.
4. **Provide Investor/CMO-grade Reporting** to prove pipeline value and inform strategic bets.

### Key Results
- Process at least 5 new hypotheses per month with automated ingest + analysis.
- Validate 30% of hypotheses into active opportunities (newsletter/lead-gen in flight).
- Drive $20k+ monthly lead/partnership revenue by month six.
- Maintain dashboards covering opportunity pipeline, lead conversion, media engagement, and operational readiness.

## 3. Context & Background

### James “Boring Marketer” Playbook Highlights
- Look for **high-value, underserved micro-niches** in tier 2/3 cities (e.g., luxury tax advisory, exotic car wraps).
- Use **AI + Google Maps data** to measure demand (review volume, velocity), identify service gaps (sentiment, hours), and surface channel deficiencies (missing socials).
- Start as a **media/lead business** (newsletter, directory) to build audience and monetize leads with minimal infrastructure.
- Only move toward owning operations if data and lead flow justify it, ensuring capital-efficient growth.

### Existing Assets
- **Hybrid Adaptive RAG Workflow** (Cole Medin template with custom enhancements): Chat agent, Google Drive ingestion, PGVector store, Graphiti knowledge graph integration, newsletter generator.
- **Postgres Ingestion Pipeline** (`Boring Business - Postgres Ingestion.json`): Apify Google Maps scraper feeding normalized Neon tables for businesses, contacts, social, ratings, reviews, leads, popular times.
- **Business Documentation** (`docs/business-context.md`): Summaries of transcripts, workflows, and current assessments.

### Gaps Identified
- No persistent **hypothesis registry** linking prompts to data runs/outcomes.
- Lack of **structured opportunity snapshots** capturing market scores, channel gaps, lead viability.
- Limited **orchestration** tying ingestion, analysis, and media/lead tasks together.
- Insufficient usage of **knowledge graph capabilities** for multi-entity relationship insights.
- Missing metrics for **pipeline monitoring**, run history, and data freshness.

## 4. Product Scope

### In Scope
1. **Hypothesis Management** – capture, store, and track status of niche/location hypotheses.
2. **Orchestrated Discovery Workflow** – for each hypothesis, automatically run Apify ingestion, KG/RAG analysis, opportunity scoring, and follow-up triggers.
3. **Opportunity Intelligence Hub** – Postgres + KG storage of market metrics, channel gaps, sentiment insights, and lead recommendations.
4. **Media & Lead Activation** – integrated newsletter planning, lead task creation, and performance tracking.
5. **Dashboards & Reporting** – metrics on pipeline stages, lead conversions, city-tier coverage, and KG usage.
6. **Operational Guardrails** – dedupe, credential security, monitoring, and data freshness policies.

### Out of Scope (Initial Release)
- Automated partner contracting or payments.
- Full operational execution (hiring technicians, dispatching trucks) for owned businesses.
- Third-party CRM integration beyond webhook/task creation (optional in later phases).

## 5. Personas & User Stories

### Personas
1. **Boring Businesses CMO** – cares about pipeline visibility, market differentiation, and revenue impact.
2. **Principal Engineer** – responsible for system reliability, data infrastructure, and extensibility.
3. **Growth Operator** – executes lead outreach, partnership deals, and newsletter campaigns.
4. **Data Analyst** – monitors dashboards, validates hypotheses, tunes scoring models.
5. **Content Strategist** – crafts newsletters/directories using AI outputs and raw insights.

### Representative User Stories
- *As the CMO*, I need a dashboard showing current hypotheses, validated opportunities, and revenue so I can prioritize resources.
- *As the Growth Operator*, I want automatic lead task creation with prioritized contact info so I can reach high-value providers quickly.
- *As the Principal Engineer*, I need deduped, secure pipelines with observability so I can trust automation at scale.
- *As the Content Strategist*, I want AI-generated newsletter briefs grounded in real reviews so I can publish faster without losing nuance.
- *As the Data Analyst*, I need to compare Apify runs over time (review velocity, sentiment shift) to identify emerging opportunities.

## 6. Detailed Requirements

### 6.1 Hypothesis Management
- **Input Channels:** Manual form, AI prompt outputs, CSV import.
- **Data Fields:** hypothesis_id, niche, city, state, rationale, source_prompt, created_by, created_at, status.
- **Status States:** `new`, `ready_for_review`, `in_analysis`, `validated`, `needs_review`, `discarded`, `in_campaign`, `monetized`.
- **Human-in-the-loop:** Hypotheses originate from operator-generated prompts; operator must run at least one manual Apify crawl before approval. Only after manual verification does the operator move status from `ready_for_review` to `in_analysis` via n8n UI (button) or API call.
- **Automation:** Once in `in_analysis`, orchestrator workflow runs automatically. Manual overrides available for retry/cancel.
- **Concurrency Expectation:** Support at least three hypotheses in parallel during initial launch.
- **Ownership:** Initially operated by Alex Johnson (and possibly Vlad Goldin). SOPs will be drafted by the implementation team (this project) for handoff.

### 6.2 Orchestrator Workflow ("James Playbook")

**High-Level Sequence**
1. **Trigger** – Hypothesis transitions from `new` → `in_analysis` via manual approval or API call. n8n Webhook receives `{hypothesis_id}` and metadata.
2. **Pre-flight Validation** – Workflow confirms hypothesis exists, status `in_analysis`, and no active run within last 24h. On failure, emit `validation_failed` event with reason.
3. **Data Scrape** – Call Apify ingestion workflow with `hypothesis_id`, `city`, `state`, `search_terms`. On completion, ETL posts run summary to orchestrator (`records_ingested`, `warnings`, `apify_run_id`, `duration_ms`). Failures trigger retry (up to 3 attempts with exponential backoff) and alert Slack `#boring-ops`.
4. **KG/RAG Analysis** – Invoke Hybrid Adaptive RAG workflow via n8n Execute Workflow node. Payload includes `hypothesis_id`, `search_string`, and `dataset_location`. The workflow returns structured JSON (see Payload Contracts below).
5. **Scoring Engine** – Using returned metrics and Postgres tables:
   - Calculate review velocity, provider density, sentiment polarity, channel presence, lead viability, incumbency ratio.
   - Compare against static thresholds (Table 1). Store raw values + pass/fail flags in `opportunity_metrics` (persist raw metric and boolean `*_passed`).
6. **Decision Logic** – Update `opportunities.status`:
   - `validated` when all mandatory thresholds pass.
   - `needs_review` when exactly one mandatory threshold fails (attach remediation notes).
   - `discarded` when more than one mandatory threshold fails (log reason trail).
   - Automatic requeue (`in_analysis`) if data scrape or analysis failed; orchestrator schedules retry.
7. **Automation Hooks** – On `validated`:
   - Generate newsletter brief via Newsletter agent; persist to `newsletter_issues` (status `draft`).
   - Create lead tasks (one per top 10 target businesses) with prioritized outreach channel ranking.
   - Optionally push webhook to CRM/Slack (configurable per environment).
8. **Completion** – Mark hypothesis `analyzed_at` timestamp, update run history, emit analytics event (`hypothesis.analyzed`).

**Table 1 – Initial Thresholds (Configurable)**

| Metric | Calculation | Threshold | Mandatory? | Notes |
| --- | --- | --- | --- | --- |
| Review Velocity | Avg new reviews per 30 days across top providers | ≥ 10 | Yes | Calculated from change in `reviews_count`; minimum 5 providers required |
| Provider Density | Count of providers for search string in city | ≤ 12 | Yes | Adjust per niche via config; high value indicates saturation |
| Incumbent Ratio | `incumbent_count / total_providers` (ratings ≥4.6, variance<0.15) | ≤ 0.35 | Yes | Lower ratio signals contestable market |
| Sentiment Balance | `%negative - %positive` | ≤ -10% | Yes | Negative reviews should not outweigh positives |
| Channel Presence Score | Weighted presence across Instagram, Facebook, LinkedIn, website | ≤ 0.5 | Yes | 0=absent, 1=fully covered |
| High-ticket Confidence | LLM-derived confidence score | ≥ 0.7 | Yes | Combines LLM output and keyword heuristics |
| Lead Viability | Count of providers missing phone/email/website | ≥ 3 | No | Bonus indicator for lead resale priority |

Thresholds stored in Postgres table `opportunity_thresholds` with columns (`metric`, `threshold_value`, `mandatory`, `environment`, `updated_at`).

**Operational Runbook (Orchestrator)**
- Maintain `docs/runbooks/orchestrator-playbook.md` covering:
  - Human-in-the-loop approval flow (manual Apify run, verification, status change to `in_analysis`).
  - How to manually trigger/retry a hypothesis run (n8n UI/API).
  - Steps to investigate failures at each stage (Apify ETL, KG/RAG, scoring, activation) with log locations.
  - Procedure to pause/resume orchestrator in production (n8n workflow toggles, queue draining).
  - Checklist for onboarding a new niche (create hypothesis, run manual crawl, verify data, run smoke test, confirm dashboards).

**Payload Contracts**
- **Apify ETL → Orchestrator** (`opportunity_runs`):
  ```json
  {
    "run_id": "uuid",
    "hypothesis_id": "uuid",
    "apify_run_id": "r-123",
    "city": "Charlotte",
    "state": "NC",
    "search_terms": ["luxury tax advisor"],
    "records_ingested": 142,
    "warnings": ["missing_phone:27"],
    "duration_ms": 182000,
    "started_at": "2025-10-23T14:11:00Z",
    "completed_at": "2025-10-23T14:14:02Z"
  }
  ```
- **RAG Workflow → Orchestrator** (`opportunities` & `opportunity_metrics`):
  ```json
  {
    "hypothesis_id": "uuid",
    "summary": "Luxury tax advisors in Charlotte show high demand with poor social coverage...",
    "metrics": {
      "review_velocity_month": 18.4,
      "provider_density": 7,
      "incumbent_ratio": 0.22,
      "sentiment_positive_pct": 31,
      "sentiment_negative_pct": 46,
      "channel_presence_score": 0.4,
      "high_ticket_confidence": 0.86,
      "notable_quotes": ["Clients complain about lack of after-hours support"]
    },
    "recommended_actions": [
      "Position newsletter around after-hours coverage",
      "Highlight two competitors without Instagram"
    ],
    "top_targets": [
      {"business_id": 123, "contact_priority": 1, "channels": ["phone", "email"]},
      {"business_id": 456, "contact_priority": 2, "channels": ["linkedin"]}
    ]
  }
  ```

**Failure & Alerting Policy**
- Any hard failure (Apify fetch error, KG call timeout > 2 attempts, DB write failure) raises Slack alert to `#boring-ops` tagging Alex Johnson.
- Orchestrator stores failure state in `opportunity_runs.last_error` and schedules automatic retry after 2 hours (max 3 per stage).
- If all retries exhausted, hypothesis status set to `blocked`; manual intervention expected immediately (target < 1 hour response). Silent failures are unacceptable; workflow pauses further processing until acknowledged. Latency spikes >5s in KG also trigger warning and pause for investigation.

### 6.3 Opportunity Intelligence Hub
- **Tables:**
  - `opportunity_hypotheses`
  - `opportunity_runs`
  - `opportunities` (one per hypothesis per run or cumulative snapshot)
  - `opportunity_metrics` (JSONB storing metric breakdowns)
  - `newsletter_issues`
  - `lead_tasks`
  - `lead_transactions` (to log sold/converted leads)
- **Relationships:** `opportunities` references `hypothesis_id`; `lead_tasks` reference `opportunity_id`.
- **Data Retention:** keep run history for trend analysis; mark stale runs (>30 days) for refresh.
- **Constraints & Indexes:**
  - `opportunity_hypotheses`: PK `hypothesis_id`; unique (`niche`, `city`, `state`, `created_at::date`). Index on `status` for filtering.
  - `opportunity_runs`: PK `run_id`; FK `hypothesis_id`; index on `created_at` descending; store `run_stage` status.
  - `opportunities`: PK `opportunity_id`; FK `hypothesis_id`; unique (`hypothesis_id`, `analysis_version`).
  - `opportunity_metrics`: PK `metrics_id`; FK `opportunity_id`; JSONB column with GIN index for key lookups.
  - `newsletter_issues`: PK `issue_id`; FK `opportunity_id`; `status` enum (`draft`, `scheduled`, `sent`).
  - `lead_tasks`: PK `task_id`; FK `opportunity_id`; `business_id`; index on `status`, `contact_priority`.
  - `lead_transactions`: PK `transaction_id`; FK `opportunity_id`; index on `partner_id`.
  - Add `CHECK` constraints for valid status enums.

### 6.4 Hybrid RAG Enhancements
- **Metadata Linkage:** Every document inserted into PGVector/KG must include `hypothesis_id`, `search_string`, city, state.
- **Graph Tools:** Implement MCP tool operations for `get_entity_edge`, `search_memory_nodes`, and custom queries (e.g., `top_related_entities`).
- **Prompt Tuning:** Update agent instructions to call KG for relationship/comparative questions and combine with SQL results for quantitative backing.
- **Structured Outputs:** After analysis, write structured payloads (market summary, recommended actions) to Postgres for dashboards.
- **Graph Query Playbook:**
  - Relationship Question: "How are Provider A and Provider B connected?" → use `search_memory_nodes` + `get_entity_edge` to pull shared reviewers, services, or mentioned partners. If no edges found, agent notes lack of direct relationship.
  - Competitor Gap: Query KG for nodes with negative sentiment tags and missing attributes (e.g., "after-hours support") to recommend positioning.
  - Cluster Insight: Summarize top co-mentioned entities per niche; feed results into opportunity recommendations.
- **Fallback Logic:** If KG returns empty or exceeds latency threshold (5s), agent falls back to SQL-only analysis and logs KG miss for later graph enrichment.

### 6.5 Postgres Ingestion Hardening
- **Upserts:** Use unique key on (`search_string`, `title`, `city`, `state`) or Apify `placeId` when available to avoid duplicates across runs.
- **Review Rows:** Normalize reviews into `business_reviews` row-per-review with sentiment scoring (store `sentiment_score`, `sentiment_label`).
- **Correct Field Mapping:** Align casing with Apify schema (likesCount, textTranslated, publishAt, etc.).
- **Credentials:** Store API tokens in n8n credentials vault; remove from workflow files.
- **Scheduler:** Enable weekly run with logging, error notifications, and dataset rotation.
- **Error Logging:** Capture ETL errors per stage to `etl_logs` (run_id, stage, severity, message, timestamp).
- **Operational Runbook:** Provide step-by-step SOP: start/stop ingestion workflow, rotate Apify dataset IDs (ad hoc), restore from failure, and onboard new niches. Include location in repo (e.g., `docs/runbooks/postgres-ingestion.md`).

### 6.6 Dashboards & Reporting
- **Metrics:**
  - Hypothesis pipeline counts by status and city tier.
  - Opportunity validation rate (validated / analyzed).
  - Lead funnel: tasks created → contacted → converted → revenue.
  - Newsletter performance: opens, CTR, lead lift.
  - City coverage & saturation: number of active opportunities per city, provider density trends.
  - Run freshness: days since last Apify run per hypothesis.
- **Visualization Tools:** Favor Looker initial rollout (for GA4 alignment), with Metabase fallback.
- **Dashboard Specs:** Provide wireframes/KPIs document in `docs/dashboards/` describing chart types, filters (date range, city, niche), drill-down expectations. Include guidance for Looker templating and GA4 integration hooks.
- **Alerts:** Slack notifications (channel TBD) when opportunity metrics shift > defined thresholds (e.g., negative sentiment spike, lead conversion drop). Implement via Looker/Metabase pulses or n8n alert workflow.

### 6.7 Security & Compliance
- Ensure Apify use respects terms of service; implement throttling.
- Restrict VPS access; monitor for credential leaks.
- Document data retention/deletion policies (especially reviewer data).

## 7. Non-Functional Requirements
- **Scalability:** Handle ingestion for multiple cities concurrently; support at least 10 hypotheses per batch.
- **Reliability:** Retry mechanisms for Apify fetch, KG insertion; alerting on failure.
- **Performance:** KG queries should respond within acceptable latency (target <5s) for agent usage.
- **Maintainability:** Config-driven dataset IDs, city lists; clear documentation for non-engineers.

## 8. System Architecture Overview

- LLM-assisted dev: Cursor agents (GPT-5 Codex, Sonnet 4.5) used throughout implementation for rapid workflow/code edits.

### Data Flow
Hypothesis → Orchestrator → (Apify ETL → Postgres tables) & (RAG workflow → PGVector + KG) → Opportunity scoring → Activation tasks → Dashboards.

### Diagram Artifacts
- Maintain system diagrams in `docs/diagrams/` (Mermaid/Draw.io):
  - Hypothesis state machine (statuses, transitions, triggers).
  - Orchestrator data flow showing interactions with Apify ETL and RAG workflow.
  - Postgres ERD depicting all tables, keys, and relationships.
  - Monitoring/alerting pathways (Slack notifications, retry loops, dashboard refresh).

## 9. Implementation Roadmap

### Day 1 – Foundations & Hardening Sprint
- Stand up repo structure, credentials vault entries, and environment configs for n8n/Apify/Neon/Neo4j.
- Fix critical ingestion issues (upsert keys, field casing, review normalization) using Cursor agents to patch workflows rapidly.
- Draft initial SOP skeletons and diagram stubs so downstream tasks have placeholders.

### Day 2 – KG/RAG Enhancements
- Update hybrid workflow with metadata linkage, new MCP tools, and prompt adjustments.
- Implement structured JSON outputs and persistence to `opportunities`/`opportunity_metrics`.
- Validate KG queries and fallback logic with at least one hypothesis sample run.

### Day 3 – Orchestrator Implementation
- Build hypothesis registry schema + CRUD interfaces.
- Author orchestrator workflow (trigger → validation → ETL → RAG → scoring → automation) leveraging Cursor agents for n8n node generation.
- Wire Slack/alert mechanisms and ensure retries/logging behave as specified.

### Day 4 – Dashboards, Alerts, and SOP Finalization
- Implement dashboard queries/visuals in chosen BI tool (Metabase default) and set up alert workflows.
- Flesh out runbooks (`orchestrator-playbook`, `postgres-ingestion`) and finalize diagrams.
- Conduct end-to-end dry run on two hypotheses, capture metrics, and tune thresholds if needed.

### Day 5 – Validation, Pilot Activation & Handoff
- Execute full pipeline on three distinct niche/city hypotheses, ensuring data ingestion, KG/RAG analysis, opportunity scoring, and automation fire end-to-end.
- Populate SLA tracking table with actual run durations and document remaining optimizations.
- Review dashboards with stakeholders, archive final PRD + SOPs, and list post-day-5 backlog items.

## 10. Risks & Mitigations
- **Duplicate Data / Drift:** Build dedupe logic, track run IDs, schedule cleanups.
- **LLM Cost Overruns:** Batch Graphiti calls, monitor token usage, consider model downgrades where acceptable.
- **Workflow Complexity:** Modularize orchestrations, maintain diagrams, provide operator training.
- **Apify Dependency:** Plan backup scraping strategy; consider maintaining our own Google Maps scraper if cost/limits become problematic.
- **Threshold Stagnation:** Document schedule (quarterly) to review static scoring thresholds and adjust using accumulated data.
- **SLA Ambiguity:** After first 3 orchestrator runs, record end-to-end duration and set explicit SLA target (<10 minutes) with improvement plan.

## 11. Decisions & Open Questions

### Recently Decided
- **CRM integration** will wait until after initial rollout; no HubSpot/Salesforce work in Phase 1.
- **Opportunity scoring thresholds** remain static for now; revisit once sufficient data accumulates.
- **Orchestrator SLA priority**: execute as fast as possible without sacrificing data integrity; engineering to benchmark post-launch and iterate.
- **Reviewer data retention** poses no additional compliance concerns at this stage; proceed with planned storage.

### Outstanding
- Establish timeline/criteria for reevaluating scoring model.
- Capture baseline orchestrator latency metrics after MVP launch to formalize SLA commitments.

## 12. Appendices

### A. Transcripts & Source Materials
- “My AI agents scrape Google Maps to make $$ in BORING businesses” – James & Greg transcript.
- “Knowledge Graphs in n8n are FINALLY Here!” – Cole Medin transcript.

### B. Workflow References
- `Tools & Frameworks/Templates/Cole Medin/Hybrid Adaptive RAG Agent Template.json`
- `/Downloads/Boring Business - Postgres Ingestion.json`
- Future orchestrator workflow (TBD path).

### C. Data Dictionary (Initial)
- `opportunity_hypotheses`: hypothesis_id (UUID), niche, city, state, rationale, source_prompt, created_by, created_at, status, last_run_at.
- `opportunity_runs`: run_id, hypothesis_id, apify_dataset_id, run_timestamp, businesses_ingested, warnings, errors.
- `opportunities`: opportunity_id, hypothesis_id, status, summary, last_updated_at.
- `opportunity_metrics`: opportunity_id, metric_payload JSONB (review_velocity, provider_density, sentiment_scores, channel_presence, high_ticket_flag).
- `newsletter_issues`: issue_id, opportunity_id, publish_target_date, subject_lines, angle, customer_value.
- `lead_tasks`: task_id, opportunity_id, business_id, contact_priority, outreach_channel, status, assigned_to.
- `lead_transactions`: transaction_id, opportunity_id, partner_id, amount, lead_volume, conversion_rate.

### D. Glossary
- **Review Velocity (RV):** 30-day normalized count of new reviews (signal of demand).
- **Provider Density (PD):** Number of providers per search string/city (competition proxy).
- **INC:** Incumbent score (fraction of providers with high rating, low variance, strong review base).
- **Tier 2/3 Cities:** Fast-growing metropolitan areas outside the major hubs (e.g., Charlotte, Nashville, Denver).
- **Media-led GTM:** Launching newsletters/directories to capture audience before offering services.


