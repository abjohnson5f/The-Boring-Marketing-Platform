# ThoughtSpot Analytics Cloud Setup Guide

**Purpose**: Connect ThoughtSpot Analytics Cloud to Neon Postgres, enable AI-assisted Liveboards, and configure Slack alerting.

---

## Prerequisites
- ✅ ThoughtSpot Analytics Cloud subscription (FAQ: https://www.thoughtspot.com/pricing)
- ✅ Access to your Snowflake/BigQuery/Redshift/Postgres warehouse (Neon in our case)
- ✅ Network access from ThoughtSpot Cloud to your database (AWS PrivateLink / IP allowlist)
- ✅ Slack incoming webhook (optional) for Monitor alerts

---

## Part 1: Subscribe & Provision ThoughtSpot Cloud

1. Visit [ThoughtSpot Pricing](https://www.thoughtspot.com/pricing) → Select **Team** or **Essentials** plan (search-first BI with Genie Copilot).
2. Complete checkout & provision an Analytics Cloud instance (you’ll receive an org URL like `https://your-company.thoughtspot.cloud`).
3. Create the first admin user (email + SSO recommended). Enable MFA.

> **Tip**: Request the **ThoughtSpot Everywhere** trial if you plan to embed Liveboards later.

---

## Part 2: Configure Database Connectivity (Neon Postgres)

1. Ensure Neon instance allows ThoughtSpot ingress:
   - Preferred: Configure AWS PrivateLink or VPC peering (see [docs](https://docs.thoughtspot.com/cloud/latest/connections-sql-server-private-link.html) – same process for Postgres).
   - Alternate: Temporarily allow ThoughtSpot IP ranges (contact support for current CIDR list).
2. Create a dedicated Postgres user with read access to schema/tables:
   ```sql
   CREATE ROLE ts_reader WITH LOGIN PASSWORD '***';
   GRANT CONNECT ON DATABASE boring_businesses TO ts_reader;
   GRANT USAGE ON SCHEMA public TO ts_reader;
   GRANT SELECT ON ALL TABLES IN SCHEMA public TO ts_reader;
   ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ts_reader;
   ```
3. In ThoughtSpot Cloud:
   - Go to **Data → Connections → + New Connection**
   - Choose **PostgreSQL**
   - Enter Neon host, port, database, username `ts_reader`, and password
   - Test connection → Save

---

## Part 3: Model Worksheets & Liveboards

1. **Create Worksheets (semantic layer)**
   - From the connection, select tables/views (`opportunities`, `opportunity_metrics`, `newsletter_issues`, `lead_tasks`)
   - Define relationships (joins) as needed (e.g., opportunities → newsletter_issues on `opportunity_id`)
   - Add calculated columns for KPI-friendly metrics (e.g., publish lag = `published_manually_at - created_at`)

2. **Build Liveboards**
   - Open a worksheet → use **Search** to create visual answers
   - Pin answers to a new Liveboard called **“Opportunity Pipeline”**
   - Recommended visuals:
     - Validation funnel (validated vs needs_review vs discarded)
     - Publish lag trend (line chart)
     - Newsletter status (sent vs awaiting upload)
     - Lead conversion table by niche/city

3. **Enable Genie Copilot (optional)**
   - Admin → **Spotter** → Enable Genie
   - Assign Spotter privileges to ops/marketing group
   - Provide example prompts (see Part 5)

---

## Part 4: Configure Alerts & Slack Integration

1. In ThoughtSpot, open Liveboard → click the KPI tile → **Set Alert**
   - Condition examples:
     - Negative sentiment % > 30%
     - Publish lag > 24h for any opportunity
   - Delivery: Email or Slack webhook
2. For Slack:
   - Create webhook in Slack (`/incoming-webhook`)
   - Paste webhook URL into ThoughtSpot alert destination
   - Customize message format (ThoughtSpot supports templated text)

> Backup plan: use n8n scheduled workflow querying Postgres, then send Slack message.

---

## Part 5: Genie Copilot & Prompt Library

Provide users with a prompt cheat sheet:
```
"show validation rate by city for last 30 days"
"compare publish lag for Charlotte vs Denver opportunities"
"list newsletters awaiting manual upload"
"which niches had negative sentiment spike this week"
```

Train Genie on domain terms by adding synonyms/aliases in worksheet column metadata (e.g., `validation_rate` → “conversion rate”, `publish_lag_hours` → “send delay”).

---

## Part 6: Embed or Share (Optional)

- Enable ThoughtSpot Everywhere trial for embedding Liveboards into internal portals.
- Generate embed URL or use SDK to integrate with Astro front-end.
- Configure row-level security if sharing outside core team.

---

## Cost Snapshot (2025)
| Item | Cost | Notes |
| --- | --- | --- |
| ThoughtSpot Team Plan | ~$95/user/month | Search, Liveboards, Genie Copilot |
| ThoughtSpot Everywhere (embed) | Contact Sales | Optional add-on |
| Database egress | Varies | Neon outbound traffic for queries |

> ThoughtSpot bills per creator/viewer license. Monitor usage to right-size seats.

---

## Helpful Links
- ThoughtSpot Connections (Postgres): https://docs.thoughtspot.com/cloud/latest/connection-configuration.html
- Spotter / Genie Copilot: https://docs.thoughtspot.com/cloud/latest/spotter.html
- ThoughtSpot Everywhere: https://www.thoughtspot.com/product/everywhere
- Neon Postgres VPC Peering: https://neon.tech/docs/connect/security

**Setup Complete!** ThoughtSpot now delivers search-driven analytics on your boring-business pipeline. 🚀
