# Boring Businesses Platform – Technical Implementation Plan

> **Scope:** Translate the PRD into executable steps that Cursor agents and engineers can follow to deliver the 5-day MVP. All workflows assume the existing Hostinger-based self-hosted n8n instance, Neo4j/Graphiti MCP server, Neon Postgres, and Apify dataset access.

## 1. Environment & Tooling Baseline (Day 1)

| Item | Action | Notes |
| --- | --- | --- |
| Repository | Ensure `BoringBusinessesMarketing` repo has `docs/`, `workflows/`, `sql/`, `runbooks/`, `diagrams/`. | Cursor agents will create/edit files. |
| Credentials | Populate n8n credential vault: `Apify API`, `Neon Postgres`, `Graphiti MCP`, `ThoughtSpot (if used)`, Slack webhook. | Reference existing secrets; no plaintext in workflows. |
| Environments | Configure `.env` or n8n environment vars for `DEV` and `PROD` (DB connection strings, Slack channels). | Use Hostinger hosting tools. |
| Runtime logging table | In Postgres, create `orchestrator_run_log` (run_id UUID PK, hypothesis_id UUID, stage TEXT, status TEXT, duration_ms INT, started_at TIMESTAMP DEFAULT now(), completed_at TIMESTAMP, error JSONB). | SQL migration in `sql/001_create_orchestrator_log.sql`. |

## 2. Schema & Data Contracts

1. **SQL Migrations** (execute via Neon console or psql)
   - `sql/002_opportunity_tables.sql`: Create/alter tables per PRD (hypotheses, runs, opportunities, metrics, newsletter_issues, lead_tasks, lead_transactions, thresholds). Include unique constraints & indexes.
   - `sql/003_threshold_seed.sql`: Insert initial metric thresholds per Table 1.
   - `sql/004_runtime_logging.sql`: Create `etl_logs` (run_id UUID FK, stage TEXT, severity TEXT, message TEXT, created_at TIMESTAMP DEFAULT now()).

2. **Payload Formats** (stored in `docs/contracts/` as JSON examples)
   - `apify_run_summary_example.json` (per PRD payload).
   - `rag_analysis_payload.json` (metrics, recommended_actions, top_targets).
   - `newsletter_brief_payload.json` (subject_lines, angles, publish_target_date).

## 3. Workflow Implementation Detail

### 3.1 Postgres Ingestion Workflow (Modify existing `/boring-business-postgres-migration/workflows/.../BORING-BUSINESS-POSTGRES-V2.json`)

Add/Update nodes as follows:

| Step | Node | Type | Key Config | Connects To |
| --- | --- | --- | --- | --- |
| 0 | **Set Hypothesis Context** | `Set` | Add fields: `hypothesis_id` (input), `run_id` (UUID via `{{$uuid.v4()}}`), `apify_run_id` (from HTTP response later). | Downstream nodes reference `$json.hypothesis_id`. |
| 1 | **HTTP Request** | Apify dataset fetch | Already present; ensure query uses stored dataset ID (credential). Append query param `status=SUCCEEDED`. | Output to parser nodes. |
| 2 | **Function: Flatten Reviews** | `Function` | Iterate through `reviews` array, emit one item per review with casing normalized (`likesCount`, `textTranslated`, `publishAt`). | Into Postgres Review insert. |
| 3 | **Merge** | `Merge` (per existing) | Align overview/contact/social/rating/popularTimes streams by `title`. | Maintains pipeline. |
| 4 | **Postgres (Upsert Businesses)** | `Postgres` node | Operation `upsert`, table `businesses`, matching columns `search_string,title,city,state`. Ensure JSON mapping references new `Set` fields. | After merge. |
| 5 | **Postgres Reviews** | `Postgres` node | Operation `upsert`, table `business_reviews`, match on `(business_id, review_id)`. Use flattened output. Include `sentiment_score` via call to `Sentiment` (optional: use Function w/ simple heuristic or LLM). | Receives from Function node. |
| 6 | **Postgres Metrics Logging** | `Postgres` node | Insert into `etl_logs` with `run_id`, `stage`, `message`. Called via IF branches capturing warnings (e.g., missing phone). | After each critical stage. |
| 7 | **Webhook Call (Run Summary)** | `HTTP Request` | POST to orchestrator webhook URL with run summary payload. | Terminal node; if orchestrator called this workflow directly, skip and return JSON. |

**Error Handling:** Wrap critical write nodes with `Execute Workflow` error branch or n8n `Error Trigger` to log into `etl_logs` and slack (via Slack node) tagging Alex.

### 3.2 Orchestrator Workflow (`workflows/orchestrator/JAMES-PLAYBOOK.json`)

| Order | Node | Type | Config | Notes |
| --- | --- | --- | --- | --- |
| 0 | **Webhook Trigger** | `Webhook` | Path `/orchestrator/hypothesis/run`, auth header. Accepts payload `{hypothesis_id}` or manual trigger. | Entry point. |
| 1 | **Postgres (Fetch Hypothesis)** | `Postgres` | Query `SELECT * FROM opportunity_hypotheses WHERE hypothesis_id=$1 AND status IN ('ready_for_review','in_analysis');`. | If no record → respond error. |
| 2 | **IF - Status Check** | `IF` | Condition: status equals `ready_for_review`. If true → return error requiring manual approval. | Ensures human approval executed. |
| 3 | **Postgres (Update Status)** | `Postgres` | Set status to `in_analysis`, log `analyzed_at` null. | Pre-run. |
| 4 | **Execute Workflow** | `Execute Workflow` | Call modified Apify ingestion workflow, pass `hypothesis_id`, `city`, `state`, `search_terms`. | Wait for completion. |
| 5 | **Write Run Log** | `Postgres` | Insert into `opportunity_runs` with summary fields returned from ingestion (records, duration, warnings). | Use returned JSON. |
| 6 | **Execute Workflow (RAG Analysis)** | `Execute Workflow` | Call Hybrid RAG workflow with `hypothesis_id`, `search_string`, dataset path. | Expect structured JSON response. |
| 7 | **Function (Metrics Transform)** | `Function` | Compute derived metrics (review velocity, provider density, sentiment balance, channel score, high-ticket). Compare with thresholds fetched from `opportunity_thresholds`; output pass/fail flags. | Use Postgres query inside node or prefetch thresholds via separate Postgres node. |
| 8 | **Postgres (Write Opportunity)** | `Postgres` | Upsert `opportunities` (hypothesis_id, summary, status). Insert `opportunity_metrics` (JSONB). | Include `analysis_version` increment. |
| 9 | **IF - Thresholds** | `IF` | If all mandatory pass → route validated. If exactly one fail → needs_review. Else discarded. | Use booleans from Function. |
| 10A | **Automation: Newsletter** | `Execute Workflow` | Trigger newsletter draft generator; receive `issue_id`, export asset links, and CTA summary for operator upload. | Only for validated. |
| 10A-REMINDER | **Manual Publish Reminder** | `IF` + `Slack` | If `published_manually_at` is null after 24h, send reminder to operator (optional scheduled workflow). | Keeps SLA on track. |
| 10B | **Automation: Lead Tasks** | `Function` + `Postgres` | Create tasks for top 10 targets with channel priority; insert into `lead_tasks`. | Validated path. |
| 10C | **Slack Notify** | `Slack` | Send success summary to channel, include run metrics and status. | For validated & needs_review/discarded (different messages). |
| 11 | **Postgres (Update Hypothesis Status)** | `Postgres` | Set `status` to `validated`/`needs_review`/`discarded`, update timestamps. | Finalize. |
| 12 | **Postgres (Runtime Log)** | `Postgres` | Insert into `orchestrator_run_log` each stage duration; use `Date.now()` at node transitions to compute ms. | For SLA tracking. |
| 13 | **Respond** | `Respond to Webhook` | Return JSON with status, metrics, next steps. | Endpoint response. |

**Retry & Failure:** Use `Error Trigger` workflow to catch exceptions → write to `orchestrator_run_log` w/ status `error`, create Slack alert, set hypothesis status `blocked`.

### 3.3 Hybrid RAG Workflow Updates (`Tools & Frameworks/.../Hybrid Adaptive RAG Agent Template.json`)

1. **Metadata Injection**
   - Add `Set` node near start to attach `hypothesis_id`, `search_string`, `city`, `state` from input payload.

2. **KG Tool Enhancements**
   - Add MCP nodes for `get_entity_edge` and store results in new `Function` node summarizing relationships.
   - Introduce `IF` node to monitor runtime; if KG call takes >5s, emit warning (via Slack) and skip to SQL fallback.

3. **Structured Output**
   - After agent response, add code node to output JSON per payload contract (metrics array, recommended_actions, top_targets) and call Postgres upsert (same structure orchestrator expects).
   - Return JSON to orchestrator via `Respond to Webhook` node or success output.

4. **SQL Tools**
   - Ensure Postgres tool nodes exist for `List Businesses`, `Get File Contents`, `Query document_rows`. Add new tool `Top Distressed Providers` (SQL selecting businesses with low rating/high reviews, missing socials).

### 3.4 Newsletter Draft Workflow

| Node | Details |
| --- | --- |
| Trigger | `Execute Workflow` triggered by orchestrator validated path. |
| Inputs | `hypothesis_id`, `summary`, `recommended_actions`, `metrics`, optional CTA guidance. |
| LLM | Use GPT-5 Codex or Claude Sonnet 4.5 to draft newsletter sections (subject options, intro, body, CTA, preview text). |
| Persist Draft | Upsert `newsletter_issues` with `status='draft'`, store `subject_lines`, `content.markdown`, `content.sections`. |
| Export Assets | Generate Markdown + HTML snippets (optionally Google Doc); write locations to `export_assets` JSONB column. |
| Notify Operator | Post Slack message summarizing highlights and linking export files plus manual publish checklist. |
| Output | Return `{issue_id, export_assets, subject_options, cta_summary}` for orchestrator logging. |

### 3.5 Slack & Alert Workflow

Standalone n8n workflow `ALERT-NOTIFY.json` triggered via `Webhook` nodes across workflows.

| Node | Config |
| --- | --- |
| Webhook Trigger | Accept `{stage, severity, message, hypothesis_id}` |
| Postgres | Insert into `etl_logs` or `orchestrator_run_log` as needed |
| Slack | Send message to `#boring-ops` with formatted block (stage, severity, message, run_id hyperlink). |

## 4. Dashboard & Reporting Setup (Day 4)

1. **ThoughtSpot**
   - Connect Neon Postgres (or replica) as a live connection.
   - Model worksheets for `opportunities`, `newsletter_issues`, `lead_tasks`, and `opportunity_metrics`.
   - Build initial Liveboards covering pipeline, validation rate, publish lag, and lead conversion.
2. **Alerts**
   - Configure ThoughtSpot Monitor or Pinboard alerts to Slack when negative sentiment > threshold or conversion drops.
   - Backup: n8n scheduled workflow to query Postgres and notify Slack if metrics exceed thresholds.

## 5. SOP & Diagram Deliverables (Day 4)

- **Runbooks**
  - Draft `docs/runbooks/orchestrator-playbook.md`, `docs/runbooks/postgres-ingestion.md`, and `docs/runbooks/newsletter-manual-publish.md` (operator-facing manual upload checklist with screenshots).
- **Diagrams** (`docs/diagrams/`)
  - Use Figma (template link) for state machine, orchestrator flow, ERD, monitoring/alerting. Export PNG/SVG for quick reference.

## 6. Validation Checklist (Day 5)

1. **Dry Runs**
   - Execute 3 hypotheses end-to-end; ensure ingestion, scoring, automation complete without manual intervention post-approval.
   - Verify Slack alerts on success/failure paths and confirm the newsletter draft package includes working export links.

2. **Data Verification**
   - Confirm rows in `opportunities`, `opportunity_metrics`, `lead_tasks`, `newsletter_issues`, `orchestrator_run_log`.
   - Ensure `newsletter_issues.export_assets` populated and accessible; capture manual publish confirmations.

3. **SLA Recording**
   - Extract runtime durations from `orchestrator_run_log`; document in PRD outstanding decisions section.

4. **Handoff**
   - Ensure README update summarizing setup, workflows, and runbooks.
   - Walk operators through `newsletter-manual-publish` runbook and SLA expectations.
   - Archive implementation notes in `docs/prd/IMPLEMENTATION-COMPLETE.md` once signed off.

## 7. Post-MVP Backlog

- Automate hypothesis generation pipeline (LLM + approval UI).
- Integrate CRM (webhook placeholder already present).
- Enhance sentiment scoring using LLM for nuanced tagging.
- Build automated KG cleanup when businesses removed from Google Maps.
- Explore Astro-based web front end for public directories and dashboards.

