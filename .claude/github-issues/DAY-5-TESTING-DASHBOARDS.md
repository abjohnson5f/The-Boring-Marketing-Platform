# Day 5: End-to-End Testing, Dashboards & Production Readiness

**Estimated Duration**: 6-8 hours
**Dependencies**: Day 1-4 complete (all workflows functional)
**Output**: Validated system, Looker dashboards, production runbooks, handoff documentation

---

@claude Execute Day 5 of the 5-day implementation sprint per Technical Implementation Plan Sections 4, 5, 6.

## Context Documents (Auto-Loaded)

- **Technical Plan Section 4**: Dashboard & Reporting Setup
- **Technical Plan Section 5**: SOP & Diagram Deliverables
- **Technical Plan Section 6**: Validation Checklist
- **PRD Section 7**: Success Metrics

## Primary Tasks

### 1. End-to-End Validation (3 Hypotheses)

**Test Matrix** (document in `docs/testing/day-5-end-to-end-validation.md`):

#### Test Hypothesis 1: Charlotte Luxury Tax (Expected: Validated)
```sql
-- Setup
INSERT INTO opportunity_hypotheses (hypothesis_id, niche, city, state, search_terms, status)
VALUES (
  'charlotte-luxury-tax-001',
  'luxury tax advisory',
  'Charlotte',
  'NC',
  ARRAY['luxury tax advisor charlotte', 'high net worth tax services'],
  'in_analysis'
);
```

**Trigger orchestrator**, verify:
- [ ] Apify data collection completed
- [ ] Businesses inserted into database
- [ ] Reviews flattened and stored
- [ ] RAG analysis executed
- [ ] Metrics calculated (review_velocity ≥10, provider_density ≤12, etc.)
- [ ] Status set to `validated`
- [ ] Lead tasks created (top 10 businesses)
- [ ] Newsletter draft generated
- [ ] Slack notification sent
- [ ] `orchestrator_run_log` shows all stage durations

#### Test Hypothesis 2: Nashville Diesel Mechanics (Expected: Validated)
*Repeat validation steps above*

#### Test Hypothesis 3: Denver Exotic Car Wraps (Expected: Needs Review - edge case)
*Intentionally design to pass only 3/4 thresholds*

**Validation Queries**:
```sql
-- Confirm 3 hypotheses processed
SELECT hypothesis_id, status, analyzed_at
FROM opportunity_hypotheses
WHERE hypothesis_id IN (
  'charlotte-luxury-tax-001',
  'nashville-diesel-001',
  'denver-car-wraps-001'
);

-- Verify metrics calculated
SELECT hypothesis_id, metrics->>'review_velocity' as velocity
FROM opportunities
WHERE hypothesis_id IN (...);

-- Check lead tasks created
SELECT COUNT(*) as task_count
FROM lead_tasks
WHERE hypothesis_id = 'charlotte-luxury-tax-001';
-- Expected: 10

-- Confirm newsletter drafts
SELECT COUNT(*) as newsletter_count
FROM newsletter_issues
WHERE hypothesis_id IN ('charlotte-luxury-tax-001', 'nashville-diesel-001');
-- Expected: 2 (not 3, Denver was needs_review)
```

### 2. Looker Dashboard Setup

**Connect Data Source**:
1. Add Neon Postgres to Looker (use read-only credentials)
2. Test connection with sample query

**Create Explore**: `opportunities_explore`

**Join Structure**:
```sql
FROM opportunity_hypotheses h
LEFT JOIN opportunities o ON h.hypothesis_id = o.hypothesis_id
LEFT JOIN opportunity_metrics m ON o.opportunity_id = m.opportunity_id
LEFT JOIN lead_tasks lt ON o.opportunity_id = lt.opportunity_id
LEFT JOIN newsletter_issues ni ON o.opportunity_id = ni.opportunity_id
```

**5 Required Looks** (per Technical Plan Section 4):

1. **Hypothesis Pipeline**:
   - Chart: Funnel
   - Dimensions: Status (ready_for_review → in_analysis → validated/needs_review/discarded)
   - Measure: Count of hypotheses

2. **Validation Rate**:
   - Chart: Single Value
   - Measure: (COUNT(status='validated') / COUNT(*)) * 100
   - Filter: Last 30 days

3. **Lead Funnel**:
   - Chart: Bar chart
   - Dimensions: Task status (pending, in_progress, completed)
   - Measure: Count of lead tasks
   - Sort: By opportunity score DESC

4. **Run Freshness Trend**:
   - Chart: Line chart
   - X-axis: Date (analyzed_at)
   - Y-axis: Count of opportunities analyzed
   - Granularity: Daily

5. **Runtime SLA Chart**:
   - Chart: Box plot
   - Data: orchestrator_run_log.duration_ms by stage
   - Color: By stage (ingestion, rag, metrics, automation)
   - Target line: 120s (2 min SLA)

**Dashboard**: Combine all 5 Looks into "Boring Businesses - Market Intelligence"

**Alert Configuration**:
- Trigger: Sentiment Balance < -20% (major negative sentiment)
- Or: Conversion rate drops >15% week-over-week
- Action: Slack #boring-ops channel
- Frequency: Daily at 9am ET

### 3. SOP & Diagram Deliverables

**Runbooks to Create**:

#### A. `docs/runbooks/orchestrator-playbook.md`
Must include:
- **Triggering a hypothesis**: Manual POST request + payload example
- **Monitoring progress**: Querying `orchestrator_run_log`
- **Handling errors**: Common failure modes + resolution steps
- **Reprocessing**: How to re-trigger failed hypothesis
- **Manual overrides**: Setting status to validated/discarded manually

#### B. `docs/runbooks/postgres-ingestion.md`
Must include:
- **Credential setup**: Neon connection string in n8n vault
- **Testing workflow**: Sample Apify dataset for validation
- **Troubleshooting**: Duplicate business handling, missing fields
- **Data quality checks**: SQL queries to verify integrity
- **Rollback procedures**: How to delete bad run data

#### C. `docs/runbooks/rag-workflow-operation.md`
(Created in Day 4, verify completeness)

#### D. `docs/runbooks/dashboard-access.md` (NEW)
Must include:
- **Looker login**: URL and credentials
- **Explore guide**: How to filter opportunities by city/niche
- **Custom queries**: Template SQL for common analysis
- **Alert configuration**: How to modify thresholds
- **Export procedures**: Downloading data for offline analysis

**Diagrams** (use Figma or draw.io):

1. **State Machine** (`docs/diagrams/hypothesis-state-machine.png`):
   - States: ready_for_review → in_analysis → validated/needs_review/discarded/blocked
   - Transitions: Manual approval, orchestrator processing, error handling

2. **Orchestrator Flow** (`docs/diagrams/orchestrator-dataflow.png`):
   - Entry: Webhook
   - Stages: Fetch → Validate → Apify → RAG → Metrics → Automation → Complete
   - Decision points: Status check, threshold routing

3. **ERD** (`docs/diagrams/database-schema-erd.png`):
   - Tables: hypotheses, opportunities, runs, metrics, lead_tasks, newsletter_issues, orchestrator_run_log, etl_logs
   - Relationships: Foreign keys, one-to-many connections

4. **Monitoring/Alerting** (`docs/diagrams/monitoring-architecture.png`):
   - Data sources: Neon Postgres, orchestrator_run_log
   - Looker dashboards
   - Slack alert flows

### 4. SLA Recording

**Extract Runtime Data**:
```sql
SELECT
  stage,
  AVG(duration_ms) as avg_ms,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration_ms) as median_ms,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_ms) as p95_ms,
  MAX(duration_ms) as max_ms
FROM orchestrator_run_log
WHERE started_at > NOW() - INTERVAL '7 days'
GROUP BY stage
ORDER BY avg_ms DESC;
```

**Document in PRD** (update Section 7 - Outstanding Decisions):
```markdown
## SLA Actual Results (Week 1)

| Stage | Avg (ms) | Median (ms) | P95 (ms) | Max (ms) |
|-------|----------|-------------|----------|----------|
| Apify Ingestion | ... | ... | ... | ... |
| RAG Analysis | ... | ... | ... | ... |
| Metrics Calculation | ... | ... | ... | ... |
| Newsletter Generation | ... | ... | ... | ... |
| **Total End-to-End** | ... | ... | ... | ... |

**Target**: <120s P95 for full hypothesis processing
**Actual**: ... (PASS/FAIL)
```

### 5. Handoff Documentation

**Create**: `docs/IMPLEMENTATION-COMPLETE.md`

**Template**:
```markdown
# Boring Businesses Platform - Implementation Complete

**Date**: 2025-10-XX
**Sprint Duration**: 5 days
**Status**: Production Ready ✅

## Deliverables Completed

### Day 1: Database Foundation
- ✅ 4 SQL migrations applied (001-004)
- ✅ 8 tables created in Neon
- ✅ Indexes and constraints validated
- ✅ Runbook: database-setup.md

### Day 2: Apify Data Collection
- ✅ 01-apify-data-collection.json (XX nodes)
- ✅ UPSERT prevents duplicate businesses
- ✅ Atomic review batch inserts
- ✅ Error handling workflow
- ✅ Runbook: apify-workflow-deploy.md

### Day 3: Orchestrator
- ✅ 02-orchestrator-james-playbook.json (13 nodes)
- ✅ 3-way threshold routing
- ✅ SLA tracking in orchestrator_run_log
- ✅ Slack notifications
- ✅ Runbook: orchestrator-playbook.md

### Day 4: RAG & Newsletter
- ✅ 03-rag-analysis-enhanced.json (with KG tools)
- ✅ 04-newsletter-generator.json (6 nodes)
- ✅ Structured output to opportunities table
- ✅ Runbooks: rag-workflow-operation.md, newsletter-generation.md

### Day 5: Testing & Dashboards
- ✅ 3 hypotheses validated end-to-end
- ✅ Looker dashboard (5 Looks + alerts)
- ✅ 4 diagrams (state machine, dataflow, ERD, monitoring)
- ✅ SLA metrics documented
- ✅ Runbook: dashboard-access.md

## Production Readiness Checklist

- [x] All workflows deployed to Hostinger n8n
- [x] Credentials configured (Apify, Neon, Slack, LLM)
- [x] Database tables created and validated
- [x] End-to-end hypothesis processing functional
- [x] Looker dashboards accessible
- [x] Slack alerts configured
- [x] Runbooks created for all operations
- [x] Diagrams saved in docs/diagrams/
- [x] SLA targets met (P95 < 120s)

## Next Steps (Post-MVP)

1. Automate hypothesis generation (LLM + approval UI)
2. Integrate CRM webhook for lead handoff
3. Enhance sentiment scoring with LLM
4. Build Astro-based public directory
5. Add KG cleanup automation

## Support & Maintenance

**Primary Contact**: Alex Johnson
**Slack Channel**: #boring-ops
**Looker Dashboard**: [URL]
**n8n Instance**: https://n8n.yourdomain.com
**GitHub Repository**: https://github.com/abjohnson5f/BoringBusinessesMarketing

**Last Updated**: 2025-10-XX

🤖 Generated with Claude Code
```

## Success Criteria (Binary)

- [ ] 3 hypotheses processed successfully
- [ ] 2 validated, 1 needs_review (as expected)
- [ ] Looker dashboard accessible with all 5 Looks
- [ ] Slack alerts configured and tested
- [ ] 4 runbooks complete with screenshots
- [ ] 4 diagrams created and saved
- [ ] SLA data extracted and documented
- [ ] IMPLEMENTATION-COMPLETE.md created
- [ ] All validation queries return expected results
- [ ] README updated with setup summary

## Outputs

**Files to Create**:
- `docs/testing/day-5-end-to-end-validation.md` (NEW - test results)
- `docs/runbooks/dashboard-access.md` (NEW)
- `docs/diagrams/*.png` (4 diagram files)
- `docs/IMPLEMENTATION-COMPLETE.md` (NEW)
- `README.md` (UPDATE with handoff summary)

**Looker Deliverables**:
- "Boring Businesses - Market Intelligence" dashboard
- 5 Looks configured
- 1 Alert rule (sentiment/conversion)

**PR Description Template**:
```markdown
## 🎉 Day 5 Complete - Platform Production Ready

### End-to-End Validation Results
| Hypothesis | Niche | City | Expected Status | Actual Status | ✅/❌ |
|-----------|-------|------|-----------------|---------------|-------|
| charlotte-luxury-tax-001 | Luxury Tax | Charlotte, NC | Validated | Validated | ✅ |
| nashville-diesel-001 | Diesel Mechanics | Nashville, TN | Validated | Validated | ✅ |
| denver-car-wraps-001 | Exotic Car Wraps | Denver, CO | Needs Review | Needs Review | ✅ |

### Database Validation
- Businesses inserted: XX
- Reviews stored: YY
- Opportunities created: 3
- Lead tasks generated: 20 (10 per validated hypothesis)
- Newsletter drafts: 2

### Looker Dashboard
- ✅ 5 Looks configured
- ✅ Alert rule created
- ✅ Dashboard accessible at [URL]

### Documentation
- ✅ 4 runbooks complete
- ✅ 4 diagrams created
- ✅ SLA metrics documented (P95: XXXms, Target: <120s)
- ✅ IMPLEMENTATION-COMPLETE.md

### SLA Results
[Paste from SQL query]

**Platform Status**: Production Ready ✅
**Next Action**: Deploy to production, process real hypotheses
```

## Error Handling

If end-to-end tests fail:
1. Identify which stage failed (query `orchestrator_run_log`)
2. Check `etl_logs` for detailed error messages
3. Review Days 1-4 deliverables for issues
4. Reprocess individual stages to isolate problem
5. DO NOT mark Day 5 complete until all 3 hypotheses validate

## Agent Configuration

**Use**:
- `/testing-agent` for end-to-end validation runs
- `/documentation-writer` for runbooks and IMPLEMENTATION-COMPLETE.md
- `/sql-migrations` if schema fixes needed
- `/workflow-editor` if workflow bugs found during testing

**Parallel Execution**: Can run 3 hypothesis tests simultaneously

---

**When complete**: Archive implementation notes, notify Alex, close sprint with final PR and handoff doc.

🎯 **This is the final day - platform goes live after this!**
