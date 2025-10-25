# Google Looker Studio Setup Guide

**Purpose**: Connect Neon Postgres data to Looker Studio for visual dashboards

**Cost**: FREE for basic use, $9/user/month for Pro (optional)

**Time Required**: 15 minutes

---

## Overview

Google Looker Studio (formerly Data Studio) is a **FREE** business intelligence tool that creates beautiful dashboards from your data.

### Free vs Pro (2025)

| Feature | Free ✅ | Pro ($9/mo) |
|---------|---------|-------------|
| **Interactive dashboards** | ✅ | ✅ |
| **Google data connectors** | ✅ (GA4, Ads, Sheets) | ✅ |
| **Third-party connectors** | ❌ (must pay separately) | ❌ (still pay separately) |
| **Collaboration** | ✅ Basic | ✅ Advanced |
| **Mobile app** | ❌ | ✅ |
| **SLA/Support** | ❌ | ✅ |
| **Gemini AI assistant** | ❌ | ✅ (July 2024+) |
| **API access** | ✅ (needs Workspace) | ✅ |

**Recommendation for you**: **Start with FREE**. You don't need Pro until you hit collaboration limits or want mobile access.

---

## Part 1: Basic Looker Studio Setup (FREE)

### Step 1: Access Looker Studio

1. Go to: https://lookerstudio.google.com/
2. Sign in with your Google account (the one you want to use for analytics)
3. Click **"Blank Report"** or **"Create" → "Report"**

**That's it!** Looker Studio is instantly available - no setup, no billing.

### Step 2: Connect to Neon Postgres

Looker Studio has a **PostgreSQL connector** built-in!

1. In your new report, click **"Add data"**
2. Search for **"PostgreSQL"** in the connectors list
3. Click the **PostgreSQL** connector

4. Fill in connection details:

```
Host name or IP: ep-soft-band-ae2scn9v.c-2.us-east-2.aws.neon.tech
Port: 5432
Database: neondb
Username: neondb_owner
Password: [your Neon password from connection string]
```

**Getting these values from your connection string**:
```
postgresql://neondb_owner:npg_XnZwzfpu36Tb6ep-soft-band-ae2scn9v@ep-soft-band-ae2scn9v.c-2.us-east-2.aws.neon.tech/neondb?sslmode=require
```
- **Username**: `neondb_owner`
- **Password**: `npg_XnZwzfpu36Tb6ep-soft-band-ae2scn9v`
- **Host**: `ep-soft-band-ae2scn9v.c-2.us-east-2.aws.neon.tech`
- **Database**: `neondb`

5. **Enable SSL**: Toggle **"Enable SSL"** to ON (required for Neon)

6. Click **"Authenticate"**

**Expected**: Connection succeeds, shows your Neon tables

### Step 3: Select Your Data

After connecting, you'll see a list of tables from your Neon database:

**For Boring Businesses platform**, you might want:
- `opportunities` - Business opportunity data
- `opportunity_metrics` - Performance metrics
- `newsletter_issues` - Newsletter performance
- `niche_opportunities` (view) - Market gaps
- `customer_pain_points` (view) - Review sentiment

**Select one table** to start (you can add more later).

Click **"Add"** → Looker Studio imports your table schema

### Step 4: Create Your First Chart

Looker Studio automatically creates a basic table view. Now make it visual:

1. Click **"Add a chart"**
2. Choose chart type:
   - **Scorecard**: Single metric (e.g., total opportunities)
   - **Time series**: Trend over time
   - **Bar chart**: Compare categories
   - **Geo map**: Geographic data
   - **Table**: Detailed data view

3. **Configure dimensions and metrics**:
   - **Dimension**: What to group by (e.g., `category`, `city`, `created_at`)
   - **Metric**: What to measure (e.g., `COUNT(id)`, `AVG(rating)`)

4. **Style it**: Use the panel on the right to customize colors, labels, etc.

**Example Dashboard Ideas**:
- Total opportunities by category (Bar chart)
- New opportunities per week (Time series)
- Geographic distribution (Geo map with `city` field)
- Top pain points by frequency (Table from `customer_pain_points` view)

---

## Part 2: Advanced Setup (If Needed)

### When to Upgrade to Pro ($9/month)?

**Upgrade IF you need**:
- Mobile app access (view/edit dashboards on phone)
- Enterprise SLA and support
- Gemini AI to help write calculations
- Advanced collaboration features

**DON'T upgrade for**:
- More data connectors (those cost extra anyway)
- Better visualizations (same in free version)
- Faster performance (same infrastructure)

### API Access (Programmatic Control)

**Prerequisites**:
- Google Workspace or Cloud Identity account (NOT just personal Gmail)
- Google Cloud project with billing enabled
- OAuth 2.0 setup

**When you need it**:
- Automating report creation
- Bulk asset migration
- Programmatic dashboard management

**For most users**: You DON'T need API access. The web UI is sufficient.

**If you need it**: See [Google's API docs](https://developers.google.com/looker-studio/integrate/api)

---

## Part 3: Connecting to Your Strategic Views

After running Day 1-3 migrations, you'll have powerful SQL views. Here's how to use them in Looker Studio:

### Example: Market Gap Analysis Dashboard

1. **Add data source**: PostgreSQL connection → `niche_opportunities` view
2. **Create charts**:

**Chart 1: Top Opportunities by Category**
- Type: Bar chart
- Dimension: `category`
- Metric: `opportunity_score` (Average)
- Sort: Descending by opportunity score

**Chart 2: Geographic Opportunity Map**
- Type: Geo map
- Dimension: `city`
- Metric: `gap_size`
- Color: Gradient (red = high gap, green = low gap)

**Chart 3: Review-Driven Gaps**
- Type: Table
- Dimensions: `category`, `city`, `gap_description`
- Metrics: `gap_size`, `opportunity_score`
- Filter: `opportunity_score > 7`

### Example: Customer Pain Points Dashboard

1. **Add data source**: PostgreSQL → `customer_pain_points` view
2. **Create charts**:

**Chart 1: Most Common Pain Points**
- Type: Word cloud or bar chart
- Dimension: `pain_point_theme`
- Metric: `mention_count`

**Chart 2: Pain Points by Category**
- Type: Heat map
- Rows: `category`
- Columns: `pain_point_theme`
- Metric: `severity_score`

---

## Part 4: Troubleshooting

### Error: "Connection failed"

**Cause**: Neon requires SSL

**Solution**:
- Ensure **"Enable SSL"** is toggled ON in connection settings
- If still failing, Neon compute might be sleeping (visit dashboard to wake it)

### Error: "Authentication failed"

**Cause**: Wrong username or password

**Solution**:
- Double-check your `NEON_CONNECTION_STRING`
- Extract username/password exactly as shown in Step 2 above
- If recently changed, get new connection string from Neon dashboard

### Error: "No tables visible"

**Cause**: Tables not yet created (migrations not run)

**Solution**:
```bash
# Run Day 1 migrations
source scripts/load-env.sh
./scripts/run-migrations.sh
```

### Chart shows "No data"

**Cause**: Query returns zero rows

**Solution**:
- Check your filters (might be too restrictive)
- Verify data exists: `psql "$NEON_CONNECTION_STRING" -c "SELECT COUNT(*) FROM opportunities;"`
- Ensure migrations populated seed data

### "Third-party connector" pricing confusion

**Clarification**:
- **PostgreSQL connector is FREE** (it's a Google-provided connector)
- You only pay for connectors like Salesforce, HubSpot, etc. from third parties
- See pricing at: https://lookerstudio.google.com/data

---

## Part 5: Best Practices

### Data Refresh

**Free version**:
- Manual refresh: Click refresh button in report
- Automatic: Every 12 hours (Looker Studio default)

**To force immediate refresh**: Click **Resource → Manage added data sources → Refresh**

### Performance Tips

1. **Use views instead of complex queries**
   - ✅ Connect to `niche_opportunities` view (pre-aggregated)
   - ❌ Don't write complex SQL in Looker Studio (slow)

2. **Limit data with filters**
   - Add date range filters (e.g., last 90 days)
   - Use category filters for focused dashboards

3. **Use extract connectors for large datasets**
   - If >100K rows, consider BigQuery export
   - For now, Neon direct connection is fine

### Sharing Reports

**Anyone with link** (default):
- Click **Share** → Get link
- Choose "Anyone with the link can view"
- No Google account required for viewers!

**Embed in website**:
- Click **File → Embed report**
- Copy iframe code
- Paste into Astro site (future)

---

## Part 6: Alternative: Metabase (Open Source)

If you prefer **self-hosted** analytics instead of Google:

**Metabase** is a popular alternative:
- Free and open source
- Self-host on your server or use Metabase Cloud
- Native PostgreSQL support
- Beautiful UI, similar to Looker Studio
- More customizable, less Google-dependent

**Setup**: https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker

**For Boring Businesses**:
- Looker Studio = Faster setup, Google ecosystem
- Metabase = More control, privacy, customization

---

## Summary: Do You Need Looker Studio Pro?

**Start with FREE Looker Studio IF**:
- ✅ You need dashboards connected to Neon
- ✅ You want Google ecosystem integration (GA4, Ads, Sheets)
- ✅ You're okay with web-only access
- ✅ You don't need SLAs or enterprise support

**Upgrade to Pro ($9/mo) ONLY IF**:
- ✅ You need mobile app access
- ✅ You need enterprise SLAs
- ✅ You want Gemini AI assistant for calculations
- ✅ You have budget and advanced collaboration needs

**For Boring Businesses Marketing Platform**:
- **Recommendation**: Start with **FREE**
- Revisit Pro after you're generating revenue from the platform
- Most features you need are in the free tier!

---

## Environment Variables (Not Needed for Basic Usage!)

You mentioned confusion about Looker API credentials. Here's the truth:

**For connecting Looker Studio to Neon via UI**: **NO env vars needed!**

**LOOKER_CLIENT_ID and LOOKER_CLIENT_SECRET** are ONLY for:
- Programmatic API access (rare)
- Automated report generation (advanced)
- Enterprise integrations (not needed for your use case)

**What you DO need**:
- Neon connection string (already have: `NEON_CONNECTION_STRING`)
- Google account (free Gmail works)
- Browser access to https://lookerstudio.google.com/

**That's it!** No API keys, no client secrets, no complex OAuth.

---

## Next Steps

1. ✅ Visit https://lookerstudio.google.com/ (30 seconds)
2. ✅ Click "Blank Report" (30 seconds)
3. ✅ Add PostgreSQL connector with your Neon credentials (2 minutes)
4. ✅ Create your first chart from `opportunities` table (5 minutes)
5. → Share dashboard link or embed in future Astro site

**No billing, no upgrades needed to start!** 🎉

---

## Additional Resources

- **Looker Studio Gallery**: https://lookerstudio.google.com/gallery (inspiration)
- **PostgreSQL Connector Docs**: https://support.google.com/looker-studio/answer/6370296
- **Looker Studio Community**: https://www.en.advertisercommunity.com/t5/Looker-Studio/ct-p/looker-studio
- **Tutorial Videos**: https://www.youtube.com/results?search_query=looker+studio+postgresql

---

**Ready to create dashboards!** The free version has everything you need. 🚀
