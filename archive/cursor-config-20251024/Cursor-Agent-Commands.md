# Cursor Agent Commands & Workflow

## Prerequisites
- Repo synced locally or via Cursor.
- `.cursor/agents/` contains `workflow-editor.json`, `sql-migrations.json`, `documentation-writer.json`, `testing-agent.json`.
- Reference workflows stored read-only under `docs/Reference files/`.
- Implementation plan available at `docs/prd/Boring-Businesses-Technical-Implementation-Plan.md`.

## Launching Agents

### 1. Workflow Editing (n8n JSON)
```
cursor agents run .cursor/agents/workflow-editor.json \
  --input workflows/orchestrator/JAMES-PLAYBOOK.json \
  --output workflows/orchestrator/JAMES-PLAYBOOK.json \
  --context "Implement orchestrator workflow per plan (section 3.2)."
```
- Repeat with other workflow files (e.g., Postgres ingestion, Hybrid RAG). Ensure output path is under `workflows/`.

### 2. SQL Migrations
```
cursor agents run .cursor/agents/sql-migrations.json \
  --output sql/002_opportunity_tables.sql \
  --context "Create/alter tables defined in Implementation Plan section 2."
```
- After generation, review and apply via `psql -f sql/002_opportunity_tables.sql` or Neon console.

### 3. Documentation / SOPs
```
cursor agents run .cursor/agents/documentation-writer.json \
  --output docs/runbooks/orchestrator-playbook.md \
  --context "Draft orchestrator runbook per Implementation Plan section 5."
```
- Repeat for `docs/runbooks/postgres-ingestion.md`, `docs/dashboards/Looker-dashboard-spec.md`, etc.

### 4. Testing Agent
```
cursor agents run .cursor/agents/testing-agent.json \
  --output docs/testing/test-run-YYYYMMDD.md \
  --context "Validate orchestrator end-to-end with three hypotheses."
```
- Agent will log results or provide manual steps.

## Parallel Execution Tips
- Use multiple terminal tabs or Cursor tasks to run agents concurrently (e.g., one per workflow).
- For dependent tasks, wait for SQL migrations before workflow edits that rely on new tables.
- Keep reference files untouched; agents output to editable directories only.

## Review & Merge
1. Inspect agent outputs in Cursor diff view.
2. Run manual QA (n8n test executions, SQL validation).
3. Commit changes with descriptive messages (`feat: add orchestrator workflow`).
4. Update `docs/prd/IMPLEMENTATION-COMPLETE.md` after Day 5 validation.

## Troubleshooting
- If agents attempt to edit forbidden paths, adjust prompt/context to clarify output location.
- For missing credentials or environment vars, pause and supply via n8n/UI before rerunning agents.
- Use Ref MCP to fetch latest n8n docs when prompt clarity is needed.
