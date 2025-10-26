# Apify Data Collection Workflow - Deployment Runbook

## Overview

This runbook covers deployment, operation, and troubleshooting of the **01 - Apify Data Collection** workflow.

**Location:** `workflows/01-apify-data-collection.json`
**Error Handler:** `workflows/error-handlers/01-apify-error-handler.json`
**Dependencies:** Day 1 database schema (businesses, business_reviews, etl_logs tables)

---

## Prerequisites

### Required Credentials (n8n Credentials Vault)

| Credential ID | Type | Description | Setup Instructions |
|--------------|------|-------------|-------------------|
| `TnlGCmH3cO4VwbS3` | Postgres | Neon - Boring Business Market Research | Already configured (Day 1) |
| `apify-token-credential` | HTTP Query Auth | Apify API Token | Add as query parameter: `token=<APIFY_TOKEN>` |
| `slack-webhook-credential` | Slack API | #boring-ops channel | Use Slack webhook URL or Bot token |
| `n8n-api-credential` | n8n API | For orchestrator webhooks | Local n8n instance API key |

### Database Tables (from Day 1)

Verify tables exist:
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('businesses', 'business_reviews', 'etl_logs');
```

Expected output: 3 rows

---

## Deployment Steps

### 1. Import Workflows to n8n

#### Import Main Workflow
1. Open n8n UI: `http://localhost:5678` (or your hosted URL)
2. Navigate to **Workflows** → **Import from File**
3. Select `workflows/01-apify-data-collection.json`
4. Click **Import**

#### Import Error Handler
1. Navigate to **Workflows** → **Import from File**
2. Select `workflows/error-handlers/01-apify-error-handler.json`
3. Click **Import**
4. **Activate** the error handler workflow (toggle to ON)

### 2. Configure Credentials

#### Apify API Token
1. In the imported workflow, click on **Apify API - Fetch Google Maps Data** node
2. Under **Authentication**, select **Generic Credential Type** → **HTTP Query Auth**
3. Click **Create New Credential**
4. Name: `Apify API Token`
5. Add query parameter:
   - **Name:** `token`
   - **Value:** `<YOUR_APIFY_TOKEN>` (get from https://console.apify.com/account/integrations)
6. Save

#### Slack Notification (Optional but Recommended)
1. Open error handler workflow
2. Click on **Slack Notification** node
3. Create Slack credential:
   - Option A: Use Slack webhook URL
   - Option B: Use Slack Bot token
4. Update channel ID to your `#boring-ops` channel

### 3. Update Dataset ID

By default, the workflow uses dataset `ZZgMMauHlpYOqDmPR`. To use a different dataset:

1. Click on **Apify API - Fetch Google Maps Data** node
2. Update URL parameter:
   ```
   https://api.apify.com/v2/datasets/YOUR_DATASET_ID/items?status=SUCCEEDED
   ```

### 4. Test Workflow (Dry Run)

1. Click **Execute Workflow** (manual trigger)
2. Provide test input:
   ```json
   {
     "hypothesis_id": "test-hypothesis-001",
     "city": "Charlotte",
     "state": "NC",
     "search_string": "luxury tax advisor"
   }
   ```
3. Verify execution completes without errors
4. Check database:
   ```sql
   SELECT run_id, stage, severity, message
   FROM etl_logs
   ORDER BY created_at DESC
   LIMIT 5;
   ```

---

## Manual Operation

### Running Ad Hoc Data Collection

**When to use:** Testing new niches, refreshing stale data, manual hypothesis validation

**Steps:**
1. Open n8n workflow
2. Click **Execute Workflow**
3. Enter parameters in manual trigger:
   ```json
   {
     "hypothesis_id": "manual-test-20251026",
     "city": "Nashville",
     "state": "TN",
     "search_string": "mobile diesel mechanic"
   }
   ```
4. Monitor execution logs
5. Verify results in database

### Rotating Apify Dataset IDs

**Scenario:** You've run a new Apify crawl and want to ingest that specific dataset

**Steps:**
1. Get new dataset ID from Apify console (e.g., `ABC123XYZ`)
2. Click **Apify API - Fetch Google Maps Data** node
3. Update URL:
   ```
   https://api.apify.com/v2/datasets/ABC123XYZ/items?status=SUCCEEDED
   ```
4. Save workflow
5. Execute manually to verify new dataset
6. Revert URL back to default or update permanently

---

## Automation (Orchestrator Integration)

### Called by Orchestrator Workflow

When the orchestrator calls this workflow (Day 3 implementation):

**Input payload:**
```json
{
  "hypothesis_id": "uuid-from-orchestrator",
  "city": "Denver",
  "state": "CO",
  "search_string": "exotic car detailing",
  "orchestrator_webhook_url": "http://localhost:5678/webhook/orchestrator/run-summary"
}
```

**Output payload (returned via webhook):**
```json
{
  "run_id": "2025-10-26T21:00:00.000Z-abc123",
  "hypothesis_id": "uuid-from-orchestrator",
  "apify_run_id": "r-12345",
  "city": "Denver",
  "state": "CO",
  "search_terms": ["exotic car detailing"],
  "records_ingested": 47,
  "warnings": [],
  "duration_ms": 12500,
  "started_at": "2025-10-26T21:00:00.000Z",
  "completed_at": "2025-10-26T21:00:12.500Z"
}
```

---

## Troubleshooting

### Issue: "Apify API request failed (429 Too Many Requests)"

**Cause:** Rate limit exceeded
**Solution:**
1. Wait 60 seconds and retry
2. Add retry logic (future enhancement)
3. Check Apify plan limits at https://console.apify.com

### Issue: "Postgres constraint violation on businesses table"

**Cause:** Duplicate key on UPSERT match columns
**Fix:**
1. Check etl_logs for full error:
   ```sql
   SELECT * FROM etl_logs WHERE severity = 'error' ORDER BY created_at DESC LIMIT 1;
   ```
2. Verify match columns are unique: `(search_string, title, city, state)`
3. If data truly has duplicates, consider adding business website/phone to match columns

### Issue: "Reviews not showing up in database"

**Diagnostic Steps:**
1. Check if businesses were inserted:
   ```sql
   SELECT COUNT(*) FROM businesses WHERE run_id = 'YOUR_RUN_ID';
   ```
2. Check if Apify data has reviews array:
   - Inspect `apify_data` JSONB column in businesses table
   - Verify `reviews` key exists and is populated
3. Check Function: Flatten Reviews node output in n8n execution log
4. Verify business_id is being passed correctly to INSERT - Reviews node

### Issue: "No data returned from Apify API"

**Cause:** Empty dataset or incorrect dataset ID
**Fix:**
1. Verify dataset ID in Apify console
2. Check dataset status (must be SUCCEEDED)
3. Confirm dataset has items:
   ```bash
   curl "https://api.apify.com/v2/datasets/YOUR_DATASET_ID/items?token=YOUR_TOKEN"
   ```

### Issue: "Error handler not firing on failures"

**Verification:**
1. Confirm error handler workflow is **Active** (toggle ON)
2. Check Error Trigger node is configured for `workflow.error` event
3. Manually trigger an error (e.g., invalid SQL) to test

---

## Monitoring & Maintenance

### Daily Checks

1. **Review ETL Logs:**
   ```sql
   SELECT stage, severity, COUNT(*)
   FROM etl_logs
   WHERE created_at > NOW() - INTERVAL '24 hours'
   GROUP BY stage, severity;
   ```

2. **Check Slack #boring-ops for error alerts**

3. **Verify data freshness:**
   ```sql
   SELECT MAX(created_at) AS last_ingestion
   FROM businesses;
   ```

### Weekly Maintenance

1. **Archive old etl_logs (>30 days):**
   ```sql
   DELETE FROM etl_logs WHERE created_at < NOW() - INTERVAL '30 days';
   ```

2. **Review Apify usage/costs** at https://console.apify.com/billing

3. **Validate UPSERT deduplication is working:**
   ```sql
   SELECT search_string, title, city, state, COUNT(*) AS duplicates
   FROM businesses
   GROUP BY search_string, title, city, state
   HAVING COUNT(*) > 1;
   ```
   Expected: 0 rows

---

## Rollback Procedure

### If Deployment Fails

1. **Disable workflow:**
   - Toggle workflow to **Inactive**
   - Error handler remains active

2. **Revert to previous version:**
   - n8n keeps workflow history
   - Go to **Workflow** → **Settings** → **Versions**
   - Restore previous working version

3. **Check for data corruption:**
   ```sql
   SELECT run_id, COUNT(*) AS records, MAX(created_at) AS ingested_at
   FROM businesses
   GROUP BY run_id
   ORDER BY ingested_at DESC
   LIMIT 10;
   ```

4. **If data needs rollback:**
   ```sql
   -- CAUTION: Only run if you're certain
   DELETE FROM business_reviews WHERE business_id IN (
     SELECT business_id FROM businesses WHERE run_id = 'BAD_RUN_ID'
   );
   DELETE FROM businesses WHERE run_id = 'BAD_RUN_ID';
   ```

---

## Performance Benchmarks

**Expected Performance (based on Day 5 validation):**

| Metric | Target | Actual (to be filled) |
|--------|--------|----------------------|
| Apify API fetch | < 30s | |
| Business UPSERT (100 records) | < 5s | |
| Review INSERT (500 reviews) | < 10s | |
| End-to-end (500 businesses, 2500 reviews) | < 60s | |

**If performance degrades:**
- Check Postgres indexes exist on `businesses(search_string, city, state)`
- Review Apify dataset size (larger datasets take longer)
- Check network latency to Neon (use `EXPLAIN ANALYZE` on queries)

---

## Support & Escalation

| Issue Type | Contact | Response SLA |
|-----------|---------|--------------|
| Workflow errors | Alex Johnson (Slack: @alex) | < 1 hour |
| Apify API issues | Apify Support (support@apify.com) | 24 hours |
| Database issues | Neon Support (support@neon.tech) | 24 hours |
| n8n platform issues | n8n Community (forum.n8n.io) | Best effort |

---

## Appendix: SQL Queries for Validation

### Verify UPSERT worked (no duplicates)
```sql
SELECT search_string, title, city, state, COUNT(*)
FROM businesses
GROUP BY search_string, title, city, state
HAVING COUNT(*) > 1;
```

### Check review counts match Apify data
```sql
SELECT
  b.title,
  b.reviews_count AS apify_review_count,
  COUNT(r.review_id) AS actual_review_count
FROM businesses b
LEFT JOIN business_reviews r ON b.business_id = r.business_id
GROUP BY b.business_id, b.title, b.reviews_count
HAVING b.reviews_count != COUNT(r.review_id);
```

### List recent ingestion runs
```sql
SELECT
  run_id,
  COUNT(DISTINCT business_id) AS businesses,
  MIN(created_at) AS started,
  MAX(created_at) AS completed
FROM businesses
GROUP BY run_id
ORDER BY MIN(created_at) DESC
LIMIT 10;
```

---

**Document Version:** 1.0
**Last Updated:** 2025-10-26
**Owner:** Implementation Team (Day 2 Sprint)
