# ThoughtSpot Analytics Onboarding Guide

**Purpose**: Get the team productive in ThoughtSpot Analytics Cloud—connect Neon Postgres, build Liveboards, and share insights without traditional BI overhead.

---

## Why ThoughtSpot
- **Search-first analytics**: ask questions in plain language, get visual answers instantly.
- **Genie Copilot**: AI assistant for insights, explanations, and follow-up questions.
- **Live on your warehouse**: no extracts; ThoughtSpot queries Neon Postgres directly.
- **Shareable Liveboards**: curated dashboards with drill-down and alerting built in.

---

## Part 1: Access ThoughtSpot
1. Navigate to your org URL (example: `https://boringbiz.thoughtspot.cloud`).
2. Sign in with SSO or the credentials issued by the admin.
3. New users land on the **Home** page with recent Liveboards and search templates.

> **Roles**:
> - **Admin**: manages connections, worksheets, users.
> - **Creator**: builds worksheets, Liveboards, answers.
> - **Viewer**: searches and consumes published content.

---

## Part 2: Connect Neon Postgres (Admin)
1. Go to **Data** → **Connections** → **+ Create connection**.
2. Choose **PostgreSQL**.
3. Fill in:
   - Host: `ep-neon-host.compute.aws`
   - Port: `5432`
   - Database: `boring_businesses`
   - Username: `ts_reader`
   - Password: `********`
4. Test connection → Save.

> Ensure ThoughtSpot IPs are allowed or PrivateLink/VPC peering is configured (see main setup guide).

---

## Part 3: Build Worksheets (Semantic Layer)
1. Open the Postgres connection → select tables or views:
   - `opportunities`
   - `opportunity_metrics`
   - `newsletter_issues`
   - `lead_tasks`
2. Click **Create worksheet**.
3. Define joins (e.g., `opportunities.opportunity_id = newsletter_issues.opportunity_id`).
4. Add calculated columns:
   - `validation_rate = validated_opportunities / total_opportunities`
   - `publish_lag_hours = EXTRACT(EPOCH FROM published_manually_at - created_at)/3600`
5. Save as `Boring Biz Opportunity Worksheet`.

---

## Part 4: Explore & Build Liveboards (Creators)
1. From a worksheet, click **Search**.
2. Use natural language (examples):
   - “validation rate by city for last 30 days”
   - “publish lag hours by niche”
   - “list newsletters awaiting manual upload”
3. Turn answers into visuals by choosing chart types.
4. Pin visuals to a Liveboard (e.g., `Opportunity Pipeline`).
5. Organize sections: Overview, Publish Ops, Lead Funnel.
6. Share the Liveboard with Viewer groups (read-only) or Creator groups (edit).

---

## Part 5: Genie Copilot (Spotter)
1. Admin → **Spotter** → Enable Genie Copilot.
2. Assign “Spotter” privilege to Marketing Ops and Leadership groups.
3. Provide prompt examples in Slack/Confluence:
   - “Explain why Charlotte validation dropped last week.”
   - “Compare lead conversion for HVAC vs Tax niches.”
   - “What is the trend of publish lag over the past 90 days?”
4. Encourage users to follow up with “why” or “compare” for deeper insight.

---

## Part 6: Alerts & Sharing
1. Open a Liveboard tile → **Alert** → set threshold (e.g., publish lag > 24h).
2. Choose delivery method (email, Slack webhook).
3. For Slack, paste webhook URL and customize message.
4. Use ThoughtSpot’s scheduling to email PDFs/links on a cadence (e.g., weekly ops review).

---

## Best Practices
- **Model once, reuse everywhere**: keep worksheets tidy; add synonyms for Genie.
- **Avoid heavy SQL inside ThoughtSpot**: push logic to warehouse views when possible.
- **Govern access**: group-level sharing keeps metrics consistent.
- **Iterate with users**: collect feedback via Slack, adjust Liveboards quickly.

---

## Resources
- ThoughtSpot Docs: https://docs.thoughtspot.com
- Spotter/Genie Guide: https://docs.thoughtspot.com/cloud/latest/spotter-getting-started.html
- ThoughtSpot Community: https://community.thoughtspot.com

With ThoughtSpot in place, your ops team can self-serve insights while the warehouse remains the single source of truth. Let the data-driven experimentation begin! 🚀
