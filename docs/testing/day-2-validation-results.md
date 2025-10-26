# Day 2 Validation Results

**Workflow:** 01 - Apify Data Collection
**Date:** [TO BE FILLED DURING DAY 5 VALIDATION]
**Tester:** [NAME]
**Environment:** [DEV / PROD]

---

## Test Execution Summary

| Test Case | Status | Notes |
|-----------|--------|-------|
| Workflow imports successfully | [ ] PASS / [ ] FAIL | |
| All node IDs are unique UUIDs | [ ] PASS / [ ] FAIL | |
| UPSERT prevents duplicate businesses | [ ] PASS / [ ] FAIL | |
| Reviews batch insert atomically | [ ] PASS / [ ] FAIL | |
| Error handler logs failures to etl_logs | [ ] PASS / [ ] FAIL | |
| Sticky notes explain all business logic | [ ] PASS / [ ] FAIL | |
| JSON validates via hook | [ ] PASS / [ ] FAIL | |

**Overall Result:** [ ] PASS / [ ] FAIL

---

## Detailed Test Results

### Test 1: Workflow Import

**Objective:** Verify workflow JSON is valid and imports without errors

**Steps:**
1. Navigate to n8n UI
2. Click **Workflows** → **Import from File**
3. Select `workflows/01-apify-data-collection.json`
4. Observe import result

**Expected Result:** Workflow imports successfully with all nodes visible

**Actual Result:**
```
[TO BE FILLED]
```

**Status:** [ ] PASS / [ ] FAIL

---

### Test 2: UPSERT Idempotency

**Objective:** Verify re-running the same Apify dataset does NOT create duplicates

**Steps:**
1. Execute workflow manually with test hypothesis:
   ```json
   {
     "hypothesis_id": "test-upsert-001",
     "city": "Charlotte",
     "state": "NC",
     "search_string": "test search"
   }
   ```
2. Query business count:
   ```sql
   SELECT COUNT(*) FROM businesses WHERE run_id = '[RUN_ID_FROM_STEP_1]';
   ```
   Record count: **N**

3. Execute workflow again with SAME input
4. Query business count again:
   ```sql
   SELECT COUNT(*) FROM businesses;
   ```
   Record count: **Should still be N**

**Expected Result:**
- First run: N businesses inserted
- Second run: 0 new businesses, N existing businesses updated

**Actual Result:**
```
First run: [COUNT] businesses
Second run: [COUNT] businesses (should match first run)

Duplicate check:
[PASTE SQL RESULTS]
```

**Status:** [ ] PASS / [ ] FAIL

---

### Test 3: Review Flattening

**Objective:** Verify reviews are stored as individual rows, not array strings

**Steps:**
1. Execute workflow with hypothesis that has businesses with reviews
2. Query business_reviews table:
   ```sql
   SELECT business_id, stars, review_text, likes_count
   FROM business_reviews
   ORDER BY created_at DESC
   LIMIT 5;
   ```

3. Verify:
   - `stars` is a single integer (e.g., `4`), NOT a string array like `"[3,5,4]"`
   - `review_text` contains actual text, NOT array representation
   - `likes_count` is an integer, NOT array

**Expected Result:**
```
business_id | stars | review_text                | likes_count
------------|-------|----------------------------|-------------
123         | 5     | "Great service!"           | 3
123         | 4     | "Good but pricey"          | 1
124         | 3     | "Average experience"       | 0
```

**Actual Result:**
```
[PASTE SQL RESULTS]
```

**Status:** [ ] PASS / [ ] FAIL

---

### Test 4: Atomic Review Insertion

**Objective:** Verify all reviews for a business are inserted together (all or none)

**Steps:**
1. Intentionally trigger an error mid-review-insert:
   - Modify INSERT - Reviews node to include invalid field
   - Execute workflow
2. Check business_reviews table:
   ```sql
   SELECT business_id, COUNT(*) AS review_count
   FROM business_reviews
   WHERE business_id = [TEST_BUSINESS_ID]
   GROUP BY business_id;
   ```

**Expected Result:**
- Either ALL reviews for the business exist, OR
- NO reviews for the business exist (not partial)

**Actual Result:**
```
[DESCRIBE OUTCOME]
```

**Status:** [ ] PASS / [ ] FAIL

---

### Test 5: Error Handling & Logging

**Objective:** Verify errors are logged to etl_logs and Slack

**Steps:**
1. Intentionally cause an error:
   - Modify Apify API URL to invalid endpoint
   - Execute workflow
2. Check etl_logs:
   ```sql
   SELECT * FROM etl_logs WHERE severity = 'error' ORDER BY created_at DESC LIMIT 1;
   ```
3. Check Slack #boring-ops channel for alert

**Expected Result:**
- etl_logs contains error entry with:
  - `run_id`: current run
  - `stage`: failing node name
  - `severity`: "error"
  - `message`: descriptive error text
- Slack message posted to #boring-ops mentioning @alex

**Actual Result:**
```
etl_logs entry:
[PASTE SQL RESULT]

Slack notification:
[SCREENSHOT OR DESCRIPTION]
```

**Status:** [ ] PASS / [ ] FAIL

---

### Test 6: Sticky Notes Documentation

**Objective:** Verify all 6 Sticky Notes are present and explain business logic

**Steps:**
1. Open workflow in n8n
2. Locate all Sticky Notes:
   - Step 0: Set Hypothesis Context
   - Step 2: Flatten Reviews
   - Step 4: UPSERT Businesses
   - Step 5: INSERT Reviews
   - Step 6: ETL Logging
   - Step 7: Webhook Summary

3. Verify each note:
   - Explains WHAT the node does
   - Explains WHY (decision rationale)
   - Includes example data or field descriptions

**Expected Result:** All 6 Sticky Notes present with clear explanations

**Actual Result:**
```
[ ] All 6 present
[ ] Content is clear and useful
[ ] Notes [LIST ANY ISSUES]
```

**Status:** [ ] PASS / [ ] FAIL

---

### Test 7: JSON Validation via Hook

**Objective:** Verify `.claude/hooks/tool-use-complete.sh` validates workflow JSON

**Steps:**
1. Run hook manually:
   ```bash
   bash .claude/hooks/tool-use-complete.sh
   ```
2. Check for JSON validation errors
3. Verify hook log in `docs/testing/hook-log.md`

**Expected Result:**
- No JSON syntax errors
- Hook log shows validation PASS
- All node IDs are unique

**Actual Result:**
```
[PASTE HOOK OUTPUT]
```

**Status:** [ ] PASS / [ ] FAIL

---

## Performance Metrics

| Metric | Expected | Actual | Status |
|--------|----------|--------|--------|
| Workflow file size | < 50 KB | [SIZE] | [ ] PASS / [ ] FAIL |
| Number of nodes | 14-18 | [COUNT] | [ ] PASS / [ ] FAIL |
| Apify API fetch time | < 30s | [TIME] | [ ] PASS / [ ] FAIL |
| Business UPSERT (100 records) | < 5s | [TIME] | [ ] PASS / [ ] FAIL |
| Review INSERT (500 reviews) | < 10s | [TIME] | [ ] PASS / [ ] FAIL |
| End-to-end execution | < 60s | [TIME] | [ ] PASS / [ ] FAIL |

---

## Issues Found

### Issue 1: [TITLE]

**Severity:** [ ] Critical / [ ] High / [ ] Medium / [ ] Low

**Description:**
```
[DETAILED DESCRIPTION]
```

**Steps to Reproduce:**
```
1.
2.
3.
```

**Expected vs Actual:**
```
Expected: [WHAT SHOULD HAPPEN]
Actual: [WHAT HAPPENED]
```

**Workaround:**
```
[IF AVAILABLE]
```

**Fix Required:** [ ] Yes / [ ] No

---

## Sign-Off

**Tested By:** ___________________
**Date:** ___________________
**Approved By:** ___________________
**Date:** ___________________

**Notes:**
```
[ANY ADDITIONAL COMMENTS]
```

---

**Document Version:** 1.0
**Template Created:** 2025-10-26
**Sprint:** Day 2 - Apify Data Collection Workflow Enhancement
