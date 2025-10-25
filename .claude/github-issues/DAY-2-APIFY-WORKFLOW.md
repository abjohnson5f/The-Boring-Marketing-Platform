# Day 2: Apify Data Collection Workflow Enhancement

**Estimated Duration**: 5-7 hours
**Dependencies**: Day 1 complete (database schema exists)
**Output**: Modified n8n workflow with UPSERT, review flattening, execution tracking

---

@claude Execute Day 2 of the 5-day implementation sprint per Technical Implementation Plan Section 3.1.

## Context Documents (Auto-Loaded)

- **Technical Plan Section 3.1**: Postgres Ingestion Workflow modifications
- **Reference Workflow**: `docs/Reference files/Boring Business - Postgres Ingestion.json`
- **Building Blocks**: `workflows/building-blocks/` (postgres-upsert, postgres-insert-batch)

## Primary Tasks

### 1. Modify Apify Ingestion Workflow

**Base File**: Create new `workflows/01-apify-data-collection.json` (based on reference)

**Required Node Changes** (per Technical Plan Table):

| Step | Node | Modification |
|------|------|--------------|
| 0 | Set Hypothesis Context | Add `hypothesis_id` (input), `run_id` (UUID), `apify_run_id` |
| 2 | Function: Flatten Reviews | Normalize review array structure (`likesCount`, `textTranslated`, `publishAt`) |
| 4 | Postgres Upsert Businesses | Match on `(search_string, title, city, state)`, use JSONB for dimensions |
| 5 | Postgres Reviews | UPSERT on `(business_id, review_id)`, include sentiment scoring |
| 6 | Postgres Metrics Logging | Insert into `etl_logs` for each stage |
| 7 | Webhook Call | POST run summary to orchestrator |

### 2. Implement Building Block Patterns

**UPSERT Template** (from `postgres-upsert.json`):
```javascript
// Use this exact pattern for businesses table
{
  operation: 'upsert',
  table: 'businesses',
  matchColumns: ['search_string', 'title', 'city', 'state'],
  dataMode: 'autoMapInputData'
}
```

**Batch Insert** (from `postgres-insert-batch.json`):
```javascript
// Use for reviews (atomic transactions)
{
  operation: 'insert',
  table: 'business_reviews',
  columns: {
    business_id: '={{$json.business_id}}',
    review_id: '={{$json.id}}',
    // ... map all fields
  }
}
```

### 3. Add Error Handling

**Error Trigger Workflow** (NEW file): `workflows/error-handlers/01-apify-error-handler.json`

Captures:
- HTTP request failures (429, 500, 503)
- Postgres constraint violations
- Missing required fields (phone, website)

Logs to:
- `etl_logs` table with severity
- Slack notification to `#boring-ops`

### 4. Add Inline Documentation

**Sticky Notes** (per Technical Plan):
- Node 0: Explains `hypothesis_id` flow
- Node 2: Documents review flattening logic
- Node 4/5: Shows UPSERT vs INSERT decision
- Node 6: ETL logging best practices

## Success Criteria (Binary)

- [ ] Workflow imports successfully to n8n
- [ ] All node IDs are unique UUIDs
- [ ] UPSERT prevents duplicate businesses
- [ ] Reviews batch insert atomically (all or none)
- [ ] Error handler logs failures to `etl_logs`
- [ ] Sticky notes explain all business logic
- [ ] Workflow follows building block patterns exactly
- [ ] JSON validates (via `.claude/hooks/tool-use-complete.sh`)

## Validation Steps

**Manual Test** (document results):
1. Trigger workflow with sample `hypothesis_id`
2. Verify business UPSERT (re-run same data, no duplicates)
3. Check review batch insert (query `business_reviews` table)
4. Intentionally trigger error (bad HTTP), verify logging
5. Query `etl_logs` for all execution stages

**Expected Results**:
- Business count increases by N (first run), 0 (second run with same data)
- All reviews for business inserted together
- Error shows in `etl_logs` + Slack message

## Outputs

**Files to Create**:
- `workflows/01-apify-data-collection.json` (NEW - primary deliverable)
- `workflows/error-handlers/01-apify-error-handler.json` (NEW)
- `docs/runbooks/apify-workflow-deploy.md` (NEW)
- `docs/testing/day-2-validation-results.md` (NEW)

**PR Description Template**:
```markdown
## Workflow Changes
- ✅ 01-apify-data-collection.json (XX nodes, YY KB)
- ✅ Error handler workflow (ZZ nodes)

## Node Modifications (from Technical Plan Section 3.1)
| Step | Node | Status |
|------|------|--------|
| 0 | Set Hypothesis Context | ✅ hypothesis_id, run_id, apify_run_id |
| 2 | Flatten Reviews | ✅ Normalized structure |
| 4 | UPSERT Businesses | ✅ Idempotent on 4 columns |
| 5 | UPSERT Reviews | ✅ Atomic batch insert |
| 6 | ETL Logging | ✅ All stages tracked |
| 7 | Webhook | ✅ Run summary payload |

## Validation Results
[Paste from docs/testing/day-2-validation-results.md]

## Building Blocks Used
- postgres-upsert.json pattern (businesses)
- postgres-insert-batch.json pattern (reviews)
```

## Error Handling

If workflow build fails:
1. Run JSON validation: `python3 -m json.tool workflows/01-apify-data-collection.json`
2. Check `.claude/ERROR-HANDLING-PROTOCOL.md` Section 4.2 (workflow errors)
3. Verify all credential references use placeholders
4. DO NOT hardcode Neon credentials in workflow
5. Create blocker issue if cannot resolve

## Agent Configuration

**Use**:
- `/workflow-editor` for JSON modifications
- `/testing-agent` for validation runs
- `/documentation-writer` for deployment runbook

**Reference**: `.claude/PARALLEL-EXECUTION-GUIDE.md` Section 3 (workflow patterns)

---

**When complete**: Test workflow manually in n8n, document results, create PR, tag Alex.
