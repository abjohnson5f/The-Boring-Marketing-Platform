# Day 4: Hybrid RAG Workflow Enhancement & Newsletter Generation

**Estimated Duration**: 5-7 hours
**Dependencies**: Day 1-3 complete (database, data collection, orchestrator functional)
**Output**: Enhanced RAG workflow with KG tools, newsletter generation workflow

---

@claude Execute Day 4 of the 5-day implementation sprint per Technical Implementation Plan Sections 3.3 & 3.4.

## Context Documents (Auto-Loaded)

- **Technical Plan Section 3.3**: Hybrid RAG Workflow Updates
- **Technical Plan Section 3.4**: Newsletter Agent Workflow
- **Reference**: `docs/Reference files/Hybrid Adaptive RAG Agent Template.json`

## Primary Tasks

### 1. Enhance Hybrid RAG Workflow

**Base File**: Copy from `docs/Reference files/Hybrid Adaptive RAG Agent Template.json`
**Output**: `workflows/03-rag-analysis-enhanced.json`

**Required Modifications** (per Technical Plan 3.3):

#### A. Metadata Injection (NEW Set Node)
```javascript
// Add at workflow start
{
  hypothesis_id: '={{$json.hypothesis_id}}',
  search_string: '={{$json.search_string}}',
  city: '={{$json.city}}',
  state: '={{$json.state}}',
  dataset_path: '={{$json.dataset_path}}'
}
```

#### B. Knowledge Graph (KG) Tool Enhancements

**NEW MCP Nodes**:
1. `get_entity_edge` - Retrieve business relationships
2. `graph_query` - Complex pattern matching
3. Timeout node - If KG call >5s, emit warning to Slack

**Function Node** (NEW): Summarize KG relationships
```javascript
// Extract entities and relationships
const entities = $input.all().map(item => ({
  business_id: item.json.business_id,
  relationships: item.json.edges,
  community_rank: item.json.pagerank
}));

// Identify market structure
const market_leaders = entities.filter(e => e.community_rank > 0.8);
const isolated_players = entities.filter(e => e.relationships.length < 2);

return {
  market_structure: {
    leaders: market_leaders,
    isolated: isolated_players,
    total_entities: entities.length
  }
};
```

#### C. Structured Output (NEW Code Node)

**Output Format** (per Technical Plan payload contract):
```javascript
return {
  metrics: [
    { name: 'review_velocity', value: calculated_velocity, threshold_met: true/false },
    { name: 'provider_density', value: calculated_density, threshold_met: true/false },
    { name: 'sentiment_balance', value: calculated_sentiment, threshold_met: true/false },
    { name: 'high_ticket_confidence', value: calculated_confidence, threshold_met: true/false }
  ],
  recommended_actions: [
    "Launch newsletter targeting [segment]",
    "Partner with [business_name] for lead resale",
    "Investigate [opportunity] based on sentiment gaps"
  ],
  top_targets: [
    { business_id: '...', name: '...', opportunity_score: 0.85, rationale: '...' },
    // ... top 10
  ]
};
```

**Postgres Node** (NEW): UPSERT structured output
```sql
INSERT INTO opportunities (hypothesis_id, summary, metrics, status)
VALUES ($1, $2, $3::jsonb, 'analyzed')
ON CONFLICT (hypothesis_id) DO UPDATE
SET metrics = $3::jsonb, analyzed_at = now();
```

#### D. SQL Tools (NEW Postgres Tool Nodes)

**Add these tool nodes for AI agent**:
1. **List Businesses**:
   ```sql
   SELECT business_id, name, city, avg_rating, total_reviews
   FROM businesses
   WHERE hypothesis_id = $1
   ORDER BY total_reviews DESC;
   ```

2. **Top Distressed Providers**:
   ```sql
   SELECT business_id, name, avg_rating, missing_channels
   FROM businesses
   WHERE hypothesis_id = $1
     AND avg_rating < 3.5
     AND total_reviews > 50
     AND (website IS NULL OR phone IS NULL)
   ORDER BY total_reviews DESC
   LIMIT 10;
   ```

3. **Query Document Rows** (if using vector search):
   ```sql
   SELECT content, metadata
   FROM document_rows
   WHERE hypothesis_id = $1
     AND embedding <=> $2::vector < 0.8
   ORDER BY embedding <=> $2::vector
   LIMIT 20;
   ```

### 2. Build Newsletter Draft Workflow (Manual Publish)

**Create**: `workflows/04-newsletter-draft-generator.json`

**7-Node Workflow**:

| Node | Type | Purpose |
|------|------|---------|
| 1 | Execute Workflow Trigger | Called by orchestrator (validated path only) |
| 2 | Set Input | Extract `hypothesis_id`, `summary`, `recommended_actions`, `metrics`, `niche`, `city` |
| 3 | AI Agent (LLM) | GPT-4 or Claude Sonnet 4.5 to draft newsletter sections |
| 4 | Function Transform | Structure output (subject lines, intro, sections, CTA, preview text) |
| 5 | Function Export | Generate Markdown + HTML strings; optionally build Google Doc payload |
| 6 | Postgres Upsert | Save to `newsletter_issues` with `status='draft'` and `export_assets` JSONB |
| 7 | Respond | Return `{issue_id, export_assets, subject_options, cta_summary}` for orchestrator |

**LLM Prompt** (Node 3):
```
You are a newsletter writer for "The Boring Marketer" brand.

Context:
- Niche: {{$json.niche}}
- City: {{$json.city}}, {{$json.state}}
- Market Metrics: {{$json.metrics}}
- Recommended Actions: {{$json.recommended_actions}}

Task: Draft a newsletter issue targeting local service business owners.

Format:
1. 3 Subject Line Options (curiosity-driven, <50 chars)
2. Preview Text (<90 chars)
3. Intro Paragraph (hook with local insight)
4. 3 Key Highlights (data-driven, actionable)
5. Call-to-Action (subscribe for market intelligence)
6. Suggested Send Timing window (optional, based on insights)

Tone: Authoritative but approachable, data-backed, local-focused.
```

**Export Structure** (Node 5):
```javascript
return {
  issue_id: $json.issue_id,
  subject_lines: data.subject_lines,
  preview_text: data.preview_text,
  content_markdown: renderMarkdown(data),
  content_html: renderHtml(data),
  sections: data.highlights,
  cta_summary: data.cta,
  export_assets: {
    markdown_path: `s3://boring-newsletters/${$json.issue_id}.md`,
    html_path: `s3://boring-newsletters/${$json.issue_id}.html`,
    google_doc_link: $json.google_doc_link ?? null
  }
};
```

**Postgres Upsert (Node 6)**:
```sql
INSERT INTO newsletter_issues (
    opportunity_id,
    status,
    subject_lines,
    content,
    export_assets,
    created_at,
    updated_at
) VALUES ($1, 'draft', $2::jsonb, $3::jsonb, $4::jsonb, now(), now())
ON CONFLICT (issue_id) DO UPDATE
SET subject_lines = $2::jsonb,
    content = $3::jsonb,
    export_assets = $4::jsonb,
    updated_at = now();
```

### Operator Handoff Requirements
- Slack notification must include subject options, highlights, and links in `export_assets`.
- Reference `docs/runbooks/newsletter-manual-publish.md` in the message text.
- Add orchestrator reminder task (24h follow-up if `published_manually_at` is NULL).

## Success Criteria (Binary)

- [ ] RAG workflow imports and executes
- [ ] KG tool nodes added (get_entity_edge, graph_query)
- [ ] Timeout warning triggers if KG >5s
- [ ] Structured output matches payload contract exactly
- [ ] SQL tool nodes query correct tables
- [ ] Newsletter workflow generates subject lines + export assets
- [ ] LLM output stored in `newsletter_issues` (`content` JSONB + `export_assets` JSONB)
- [ ] Orchestrator can call both workflows successfully
- [ ] Manual Slack notification references the runbook
- [ ] All JSON validates

## Validation Steps

**Newsletter Workflow Test**:
1. Trigger with validated hypothesis data.
2. Review LLM output for brand alignment.
3. Confirm `newsletter_issues` row contains `export_assets` with Markdown/HTML references.
4. Ensure Slack payload (simulated) includes runbook link and reminder instructions.
5. Verify orchestrator receives `{issue_id, export_assets, subject_options, cta_summary}`.

**Expected Results**:
- RAG analysis completes in <60s (including KG calls)
- Newsletter draft generated in <10s
- Export assets stored and accessible for operator copy/paste
- Manual publish SLA reminders configured

## Outputs

**Files to Create**:
- `workflows/03-rag-analysis-enhanced.json` (MODIFIED from reference)
- `workflows/04-newsletter-draft-generator.json` (NEW)
- `docs/runbooks/rag-workflow-operation.md` (NEW)
- `docs/runbooks/newsletter-manual-publish.md` (already linked, ensure up to date)
- `docs/testing/day-4-rag-validation.md` (NEW)

**PR Description Template**:
```markdown
## RAG Workflow Enhancements
- ✅ Metadata injection (hypothesis_id, city, state)
- ✅ KG tool nodes (get_entity_edge, graph_query)
- ✅ Timeout monitoring (>5s warning)
- ✅ Structured output (metrics, actions, targets)
- ✅ SQL tool nodes (3 new queries)

## Newsletter Draft Workflow
- ✅ 04-newsletter-draft-generator.json (7 nodes, XX KB)
- ✅ LLM integration (GPT-4 / Claude Sonnet 4.5)
- ✅ Export assets (Markdown + HTML, optional Google Doc)
- ✅ Postgres integration (`newsletter_issues` + `export_assets` JSONB)
- ✅ Slack-ready payload referencing manual publish runbook

## Validation Results
### RAG Analysis
[Paste structured output example]

### Newsletter Draft
**Subject Lines**:
1. ...
2. ...
3. ...

**CTA Summary**: ...
**Export Assets**: markdown/html paths verified
```

## Error Handling

If newsletter draft workflow fails:
1. Test LLM API key and quota
2. Verify export asset renderer functions
3. Check `newsletter_issues` schema (ensure `export_assets` column exists)
4. Simplify prompt if LLM timing out
5. Confirm S3 (or storage) credentials configured for asset upload

## Agent Configuration

**Use**:
- `/workflow-editor` for both workflow modifications
- `/testing-agent` for validation runs
- `/documentation-writer` for operation runbooks

**Reference**: `.claude/GLOSSARY.md` for business terminology (use in newsletter prompts)

---

**When complete**: Test both workflows end-to-end, generate sample newsletter, create PR with outputs.
