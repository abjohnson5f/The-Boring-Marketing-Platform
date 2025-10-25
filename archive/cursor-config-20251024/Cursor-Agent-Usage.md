# Cursor Multi-Agent Usage Guide

This guide explains how to coordinate multiple Cursor agents for the Boring Businesses build.

## 1. Directory Overview
- `.cursor/agents/` – agent templates (workflow editor, SQL migration writer, documentation writer, testing agent).
- `docs/Reference files/` – read-only snapshots of original workflows (do NOT edit).
- `workflows/` – editable n8n workflow JSON output.
- `sql/` – migration files.
- `docs/runbooks/`, `docs/dashboards/` – documentation outputs.

## 2. Typical Execution Flow
1. **Prepare:** Confirm implementation plan changes (Day 1–5 tasks) and ensure credentials configured in n8n.
2. **Run SQL migrations agent** to create/update schema before dependent workflows.
3. **Run workflow editor agents** for each targeted workflow (Postgres ingestion, orchestrator, RAG, alerts) in parallel tabs.
4. **Generate SOPs/diagrams** using documentation writer once workflows stabilize.
5. **Invoke testing agent** for dry runs and runtime logging.
6. **Review outputs** (diffs, logs) manually before commit.

## 3. Conflict Avoidance
- One agent per file at a time; if multiple agents must modify same workflow, sequence them (e.g., ingestion edits before orchestrator integration).
- Use `--context` to specify exact tasks (e.g., “Add runtime logging node”).
- If an agent touches a forbidden path, cancel and adjust prompt.

## 4. Review & Merge Protocol
1. Inspect diffs in Cursor; verify JSON validity and adherence to plan.
2. Execute manual validation:
   - n8n test executions (dev environment).
   - SQL migrations applied in dev before prod.
   - Slack alerts triggered via test payloads.
3. Update runtimes in `orchestrator_run_log` during tests.
4. Commit with descriptive message (e.g., `feat: add orchestrator workflow`), referencing tasks completed.

## 5. Rollback / Recovery
- Keep copies of original workflows in `docs/Reference files/` to restore if necessary.
- For SQL, use transaction-safe migrations; if rollback needed, execute inverse SQL script.
- If workflow causes production failure, disable in n8n and revert to previous committed version.

## 6. Future Contributors
- Provide this guide along with PRD and Technical Implementation Plan.
- Ensure newcomers understand human-in-loop approvals and Slack alert expectations.
