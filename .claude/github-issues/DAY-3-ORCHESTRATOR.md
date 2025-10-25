# Day 3: Orchestrator Workflow (JAMES-PLAYBOOK.json)

**Estimated Duration**: 6-8 hours
**Dependencies**: Day 1 & 2 complete (database + data collection workflow functional)
**Output**: Master orchestration workflow coordinating all hypothesis validation stages

---

@claude Execute Day 3 of the 5-day implementation sprint per Technical Implementation Plan Section 3.2.

## Context Documents (Auto-Loaded)

- **Technical Plan Section 3.2**: Orchestrator Workflow detailed table
- **PRD Section 6.2**: Orchestrator state machine
- **Glossary**: Hypothesis lifecycle states

## Primary Tasks

### 1. Build Orchestrator Workflow from Scratch

**Create**: `workflows/02-orchestrator-james-playbook.json`

**13-Node Workflow** (exact sequence from Technical Plan Section 3.2):

| Order | Node Type | Purpose | Key Config |
|-------|-----------|---------|------------|
| 0 | Webhook Trigger | Entry point | Path: `/orchestrator/hypothesis/run`, accepts `{hypothesis_id}` |
| 1 | Postgres Fetch | Get hypothesis record | Query hypotheses table, check status `ready_for_review` or `in_analysis` |
| 2 | IF Status Check | Manual approval gate | If `ready_for_review` → return error (needs human approval first) |
| 3 | Postgres Update | Pre-run status | Set status to `in_analysis`, null `analyzed_at` |
| 4 | Execute Workflow | Call Apify workflow | Pass `hypothesis_id`, `city`, `state`, `search_terms` |
| 5 | Postgres Run Log | Record execution | Insert into `opportunity_runs` with summary from step 4 |
| 6 | Execute Workflow | Call RAG analysis | Trigger Hybrid RAG with `hypothesis_id`, dataset path |
| 7 | Function Transform | Metrics calculation | Compute derived metrics, compare vs thresholds |
| 8 | Postgres Write | Save opportunity | UPSERT `opportunities`, INSERT `opportunity_metrics` JSONB |
| 9 | IF Thresholds | Routing logic | validated / needs_review / discarded based on threshold pass/fail |
| 10A | Execute Newsletter | Validated path only | Trigger newsletter generator workflow |
| 10B | Function + Postgres | Lead tasks | Create top 10 target tasks, insert into `lead_tasks` |
| 10C | Slack Notify | All paths | Different message per status |
| 11 | Postgres Update | Finalize hypothesis | Set `status`, update timestamps |
| 12 | Postgres Runtime Log | SLA tracking | Insert stage durations into `orchestrator_run_log` |
| 13 | Respond to Webhook | Return JSON | Status, metrics, next steps |

### 2. Implement Threshold Logic (Function Node #7)

**JavaScript Code** (from PRD Table 1 thresholds):

```javascript
// Fetch thresholds from opportunity_thresholds table
const thresholds = await getThresholds();

// Calculate derived metrics
const metrics = {
  review_velocity: $input.all()[0].json.total_reviews / $input.all()[0].json.business_count,
  provider_density: $input.all()[0].json.business_count / $input.all()[0].json.population_estimate,
  sentiment_balance: ($input.all()[0].json.positive_reviews - $input.all()[0].json.negative_reviews) / $input.all()[0].json.total_reviews,
  high_ticket_confidence: $input.all()[0].json.avg_price_signal_score
};

// Compare to thresholds
const validation = {
  review_velocity_pass: metrics.review_velocity >= thresholds.review_velocity_min,
  provider_density_pass: metrics.provider_density <= thresholds.provider_density_max,
  sentiment_balance_pass: metrics.sentiment_balance <= thresholds.sentiment_balance_max,
  high_ticket_pass: metrics.high_ticket_confidence >= thresholds.high_ticket_min
};

// Routing decision
const mandatory_pass_count = Object.values(validation).filter(v => v === true).length;
let status;
if (mandatory_pass_count === 4) status = 'validated';
else if (mandatory_pass_count === 3) status = 'needs_review';
else status = 'discarded';

return { metrics, validation, status };
```

### 3. Error Handling & Retry Logic

**Error Trigger** (NEW): `workflows/error-handlers/02-orchestrator-error-handler.json`

Handles:
- Workflow execution failures (Apify timeout, RAG crash)
- Database write failures
- Threshold query failures

Actions:
- Write to `orchestrator_run_log` with status `error`
- Update hypothesis status to `blocked`
- Slack alert to Alex with full context

**Retry Policy**:
- HTTP requests: 3 retries, exponential backoff
- Database operations: 2 retries, immediate
- Workflow execution: NO automatic retry (manual investigation required)

### 4. Inline Documentation

**Sticky Notes** (critical decision points):
- Node 2: Explains manual approval requirement
- Node 7: Documents threshold logic and routing rules
- Node 9: Shows 3-way routing paths
- Node 12: Explains SLA tracking methodology

## Success Criteria (Binary)

- [ ] Workflow imports to n8n without errors
- [ ] All 13 nodes present with unique IDs
- [ ] Webhook trigger accepts `hypothesis_id` payload
- [ ] Postgres queries use parameterized statements (no SQL injection)
- [ ] Threshold logic matches PRD Table 1 exactly
- [ ] 3-way routing (validated/needs_review/discarded) functional
- [ ] Error handler catches all failure modes
- [ ] Runtime logging tracks each stage duration
- [ ] Slack notifications send to correct channel
- [ ] JSON structure validates

## Validation Steps

**End-to-End Test** (document in `docs/testing/day-3-orchestrator-validation.md`):

1. **Setup Test Hypothesis**:
   ```sql
   INSERT INTO opportunity_hypotheses (hypothesis_id, niche, city, state, status)
   VALUES ('test-123', 'luxury tax', 'Charlotte', 'NC', 'in_analysis');
   ```

2. **Trigger Orchestrator**:
   ```bash
   curl -X POST https://n8n.yourdomain.com/webhook/orchestrator/hypothesis/run \
     -H 'Content-Type: application/json' \
     -d '{"hypothesis_id": "test-123"}'
   ```

3. **Verify Each Stage**:
   - [ ] Apify workflow triggered (check `opportunity_runs` table)
   - [ ] RAG analysis completed (check `opportunities` table)
   - [ ] Metrics calculated (check `opportunity_metrics` JSONB)
   - [ ] Status updated (query `opportunity_hypotheses`)
   - [ ] Lead tasks created (if validated)
   - [ ] Slack message received
   - [ ] Runtime log shows all stages

4. **Threshold Edge Cases**:
   - Test exactly 3 thresholds passing (should be `needs_review`)
   - Test all 4 passing (should be `validated`)
   - Test <3 passing (should be `discarded`)

## Outputs

**Files to Create**:
- `workflows/02-orchestrator-james-playbook.json` (NEW - 13 nodes)
- `workflows/error-handlers/02-orchestrator-error-handler.json` (NEW)
- `docs/runbooks/orchestrator-operation.md` (NEW)
- `docs/testing/day-3-orchestrator-validation.md` (NEW)

**PR Description Template**:
```markdown
## Orchestrator Workflow
- ✅ 02-orchestrator-james-playbook.json (13 nodes, XX KB)
- ✅ Error handler workflow (YY nodes)

## Node Implementation Status
| Order | Node | Status | Validation |
|-------|------|--------|------------|
| 0 | Webhook Trigger | ✅ | Accepts hypothesis_id |
| 1 | Postgres Fetch | ✅ | Queries hypotheses table |
| 2 | IF Status Check | ✅ | Blocks if ready_for_review |
| 3 | Postgres Update | ✅ | Sets in_analysis |
| 4 | Execute Apify | ✅ | Passes context |
| 5 | Postgres Run Log | ✅ | Records execution |
| 6 | Execute RAG | ✅ | Triggers analysis |
| 7 | Function Transform | ✅ | Threshold logic |
| 8 | Postgres Write | ✅ | UPSERT opportunity |
| 9 | IF Thresholds | ✅ | 3-way routing |
| 10A | Newsletter | ✅ | Validated path |
| 10B | Lead Tasks | ✅ | Top 10 targets |
| 10C | Slack Notify | ✅ | All paths |
| 11 | Update Status | ✅ | Finalize |
| 12 | Runtime Log | ✅ | SLA tracking |
| 13 | Respond | ✅ | JSON output |

## Threshold Logic Validation
[Paste test results for edge cases]

## End-to-End Test Results
[Paste from docs/testing/day-3-orchestrator-validation.md]
```

## Error Handling

If orchestrator build fails:
1. Validate JSON structure for all 13 nodes
2. Check credential references (should be placeholders)
3. Test Function node JavaScript syntax in n8n console
4. Verify Postgres queries against Day 1 schema
5. Review `.claude/ERROR-HANDLING-PROTOCOL.md` Section 5.1

## Agent Configuration

**Use**:
- `/workflow-editor` for orchestrator build
- `/sql-migrations` if schema changes needed
- `/testing-agent` for end-to-end validation
- `/documentation-writer` for operation runbook

**Reference**: Technical Plan Section 3.2 table (exact spec)

---

**When complete**: Test full hypothesis flow end-to-end, document all stage results, create PR with evidence.
