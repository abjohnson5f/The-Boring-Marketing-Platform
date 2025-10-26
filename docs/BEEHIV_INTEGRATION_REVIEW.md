# Beehiv Newsletter Workflow – Manual Publish Implementation Review

## Executive Summary

**Status**: Scope change approved – automate content creation, keep Beehiv publishing manual.  
**Timeline Impact**: -2 hours vs prior estimate (no API build).  
**Cost Impact**: $0 (no Enterprise upgrade required).  
**Risk Level**: Low – removes dependency on Beta API, shifts QA to operator.

---

## Updated Direction

### Previous Assumption
- Automatically create and publish Beehiv drafts through the v2 API.
- Store Beehiv post IDs and sync status programmatically.

### New Reality (Manual Publish)
- Automation ends with a ready-to-send newsletter package stored in Postgres and exported for the operator.
- The operator copies the generated content into Beehiv, schedules/sends, and records the publish state manually.
- No Beehiv credentials or API access are required for MVP.

### Why This Matters
The Beehiv posts API is enterprise-only beta and incompatible with the current plan. Manual upload keeps the workflow compliant while preserving automated content generation.

---

## Required Changes vs Original Plan

| Area | Original Approach | Manual-Publish Adjustment |
| --- | --- | --- |
| Credentials | Add Beehiv API key/publication ID to n8n vault. | Remove from Day 1 checklist; no new secrets required. |
| Database | Columns for Beehiv IDs and statuses. | Optional: add `published_manually_at`, `publish_notes` for operator tracking. |
| Newsletter Workflow | Call Beehiv API after inserting local draft. | Stop at local insert, generate export assets (Markdown/HTML/Doc). |
| Orchestrator | Expect `beehiiv_post_id` in response. | Receive package metadata only (`issue_id`, paths to exports). |
| Status Sync | Poll/webhook for Beehiv updates. | Replace with manual checkbox or periodic reminder workflow. |
| Runbook | Emphasize API troubleshooting. | Document manual copy/paste procedure and verification steps. |

---

## Revised Newsletter Workflow Specification

### Workflow: `NEWSLETTER-DRAFT-GENERATOR.json`
1. **Inputs**: `hypothesis_id`, `summary`, `recommended_actions`, `metrics`, optional CTA guidance.
2. **LLM Generation**: Produce subject line options, intro, body sections, CTA, preview text.
3. **Local Persistence**: Upsert `newsletter_issues` with structured JSON (`subject_lines`, `content.markdown`, `content.sections`).
4. **Export Assets**: 
   - Render Markdown + HTML snippets.  
   - Optionally create a Google Doc or Notion-compatible file (store link in Postgres).
5. **Notify Operator**: Post Slack message with top highlights, file links, and “Manual Publish Checklist”.
6. **Return Payload**:
   ```json
   {
     "issue_id": "uuid",
     "content_markdown_path": "s3://.../issue_id.md",
     "html_snippet_path": "s3://.../issue_id.html",
     "subject_options": ["Subject 1", "Subject 2"],
     "cta_summary": "Primary CTA copy"
   }
   ```

### Error Handling
- If content generation fails, surface Slack alert and set `newsletter_issues.status = 'failed'`.
- No retries against Beehiv; operator re-runs workflow once content prompt is corrected.

---

## Orchestrator Updates (Step 10A)
- Execute the newsletter draft workflow.
- Persist returned file references to `newsletter_issues.export_assets` (JSONB).
- Append task to manual checklist: “Upload newsletter to Beehiv within 24h”.
- Send Slack summary with:
  - Subject line options
  - Key talking points
  - Direct links to export files
  - Button or link to `docs/runbooks/newsletter-manual-publish.md`

---

## Database Schema Recommendations

```sql
ALTER TABLE newsletter_issues
    ADD COLUMN IF NOT EXISTS export_assets JSONB,
    ADD COLUMN IF NOT EXISTS published_manually_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS publish_notes TEXT;

COMMENT ON COLUMN newsletter_issues.export_assets IS 'Locations of operator-facing files (markdown, html, doc links).';
COMMENT ON COLUMN newsletter_issues.published_manually_at IS 'Timestamp recorded after operator confirms manual send in Beehiv.';
```

Indexes on Beehiv IDs are no longer required unless future automation is reintroduced.

---

## Operator Workflow (Manual Publish)
1. Receive Slack notification with newsletter summary and file links.
2. Open Markdown/HTML file, paste content into Beehiv editor.
3. Adjust formatting/images as desired; set subject line and preview text.
4. Schedule or send immediately inside Beehiv.
5. Record completion: update `newsletter_issues.status = 'sent'`, set `published_manually_at`, add optional notes (e.g., send list, adjustments).
6. Log key metrics (opens/clicks) manually until native Beehiv integrations are available.

A companion runbook will outline the above steps with screenshots and troubleshooting tips.

---

## Dashboard & Reporting Adjustments
- Track newsletters by local status: `draft`, `ready_for_upload`, `awaiting_confirmation`, `sent`.
- Surface SLA: time from automated draft creation to operator confirmation.
- Collect manual notes for insights (formatting tweaks, audience tweaks).
- Optional: n8n reminder workflow that pings the operator if `published_manually_at` remains NULL after 24 hours.

---

## Risk & Mitigation Summary

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Operator delay | Leads to stale content or missed cadence. | SLA reminders, dashboard flag when `published_manually_at` is NULL for >24h. |
| Formatting drift between Markdown and Beehiv editor | Inconsistent visuals. | Provide HTML version and include styling guidelines in runbook. |
| Lack of engagement metrics automation | Harder to analyze impact. | Store manual metrics in `publish_notes` or separate tracking sheet until API access considered. |
| Future need for automation | Rework later if Enterprise access secured. | Keep modular workflow design; export assets preserved for future API call insertion. |

---

## Next Steps
1. Update technical implementation plan and PRD sections referencing automated Beehiv drafts.
2. Implement revised newsletter workflow (content generation + exports).
3. Draft runbook `docs/runbooks/newsletter-manual-publish.md` with checklist, screenshots, and FAQs.
4. Adjust dashboards to highlight manual publish SLA and completion tracking.
5. Revisit automation once enterprise API access becomes cost-effective.
