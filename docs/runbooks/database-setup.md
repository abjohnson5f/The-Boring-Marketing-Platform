# Database Setup Runbook

**Purpose**: Step-by-step guide for executing Day 1 database migrations on Neon Postgres
**Target Audience**: Engineers, operators, and CI/CD systems
**Last Updated**: 2025-10-25
**Status**: Day 1 Foundation

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Connection Setup](#connection-setup)
3. [Migration Execution](#migration-execution)
4. [Validation](#validation)
5. [Rollback Procedures](#rollback-procedures)
6. [Troubleshooting](#troubleshooting)
7. [Common Errors](#common-errors)

---

## Prerequisites

### Required Access
- [ ] Neon Postgres connection string (stored in `NEON_CONNECTION_STRING` secret)
- [ ] PostgreSQL client installed (`psql` version 12+)
- [ ] Read/write permissions on target database

### Required Files
All migration files should exist in `sql/`:
```
sql/
├── 001_create_orchestrator_log.sql
├── 002_opportunity_tables.sql
├── 003_threshold_seed.sql
├── 004_runtime_logging.sql
└── tests/
    └── 001_constraint_validation.sql
```

### Environment Verification
```bash
# Verify PostgreSQL client version
psql --version
# Expected: psql (PostgreSQL) 12.x or higher

# Check migration files exist
ls -1 sql/00*.sql
# Expected: 4 files listed
```

---

## Connection Setup

### Option 1: Direct Connection (Manual Execution)

```bash
# Export connection string from your secure credential store
export NEON_CONNECTION_STRING="postgresql://user:password@host.neon.tech/dbname?sslmode=require"

# Test connection
psql "$NEON_CONNECTION_STRING" -c "SELECT version();"
```

**Expected Output**:
```
PostgreSQL 15.x on x86_64-pc-linux-gnu
```

### Option 2: Using GitHub Actions

The connection string is automatically available in GitHub Actions via the secret `NEON_CONNECTION_STRING`.

```yaml
# Example workflow step
- name: Run migrations
  env:
    DATABASE_URL: ${{ secrets.NEON_CONNECTION_STRING }}
  run: |
    psql "$DATABASE_URL" -f sql/001_create_orchestrator_log.sql
```

### Option 3: Using load-env.sh Script

```bash
# Create local .env file (DO NOT COMMIT)
echo "NEON_CONNECTION_STRING=postgresql://..." > .env

# Load environment
source scripts/load-env.sh .env

# Verify
psql "$NEON_CONNECTION_STRING" -c "SELECT 1;"
```

---

## Migration Execution

### Pre-Migration Checklist
- [ ] Database backup completed (if production)
- [ ] Connection string verified
- [ ] All 4 migration files present
- [ ] Target environment confirmed (dev/staging/production)

### Execution Order

Migrations **must** be executed in numerical order:

#### Step 1: Create Orchestrator Log Table
```bash
psql "$NEON_CONNECTION_STRING" -f sql/001_create_orchestrator_log.sql
```

**Expected Output**:
```
CREATE EXTENSION
CREATE TABLE
CREATE INDEX
CREATE INDEX
COMMENT
COMMENT
```

**What This Creates**:
- `orchestrator_run_log` table
- 2 indexes (hypothesis_id, started_at)
- pgcrypto extension (for UUID generation)

---

#### Step 2: Create Opportunity Tables
```bash
psql "$NEON_CONNECTION_STRING" -f sql/002_opportunity_tables.sql
```

**Expected Output**:
```
CREATE EXTENSION
CREATE TABLE  (x8)
CREATE INDEX  (x15+)
COMMENT       (x20+)
```

**What This Creates**:
- 8 core business tables
- 15+ indexes including GIN index for JSONB
- Foreign key relationships with CASCADE DELETE
- CHECK constraints for status enums

**Tables Created**:
1. `opportunity_hypotheses` - Niche/city hypothesis registry
2. `opportunity_runs` - Run history log
3. `opportunities` - Derived opportunity snapshots
4. `opportunity_metrics` - JSONB metrics storage
5. `newsletter_issues` - Newsletter drafts
6. `lead_tasks` - Lead outreach tasks
7. `lead_transactions` - Monetization records
8. `opportunity_thresholds` - Scoring thresholds

---

#### Step 3: Seed Threshold Configuration
```bash
psql "$NEON_CONNECTION_STRING" -f sql/003_threshold_seed.sql
```

**Expected Output**:
```
INSERT 0 7
```

**What This Creates**:
- 7 threshold records in `opportunity_thresholds`
- Values per PRD Table 1 (review_velocity=10, provider_density=12, etc.)
- Upsert logic (safe to re-run)

---

#### Step 4: Create ETL Logging Table
```bash
psql "$NEON_CONNECTION_STRING" -f sql/004_runtime_logging.sql
```

**Expected Output**:
```
CREATE TABLE
CREATE INDEX
CREATE INDEX
COMMENT
COMMENT
```

**What This Creates**:
- `etl_logs` table for ingestion workflow logging
- 2 indexes (run_id, created_at)
- JSONB metadata column for debugging

---

### Automated Execution Script

You can run all migrations in sequence using this helper script:

```bash
#!/usr/bin/env bash
# run-migrations.sh
set -euo pipefail

echo "Starting Day 1 migrations..."

MIGRATIONS=(
    "sql/001_create_orchestrator_log.sql"
    "sql/002_opportunity_tables.sql"
    "sql/003_threshold_seed.sql"
    "sql/004_runtime_logging.sql"
)

for migration in "${MIGRATIONS[@]}"; do
    echo "Executing: $migration"
    psql "$NEON_CONNECTION_STRING" -f "$migration"
    if [ $? -eq 0 ]; then
        echo "✓ $migration completed successfully"
    else
        echo "✗ $migration failed"
        exit 1
    fi
done

echo "All migrations completed successfully!"
```

**Usage**:
```bash
chmod +x run-migrations.sh
./run-migrations.sh
```

---

## Validation

After migrations complete, run the comprehensive validation suite:

### Run Validation Tests
```bash
psql "$NEON_CONNECTION_STRING" -f sql/tests/001_constraint_validation.sql
```

### Expected Results

All tests should return **PASS** status:

**Section 1: Table Existence**
```
TEST PASS: All 10 expected tables exist
```

**Section 2: Constraints (10 tests)**
- ✓ Primary keys on all tables
- ✓ Unique constraints (hypotheses, opportunities)
- ✓ Foreign keys with CASCADE DELETE
- ✓ CHECK constraints on status/severity enums
- ✓ Duration validation (>= 0)

**Section 3: Indexes (6 tests)**
- ✓ Standard B-tree indexes on foreign keys
- ✓ GIN index on JSONB columns
- ✓ Composite indexes (status + priority)

**Section 4: Threshold Data (3 tests)**
- ✓ 7 threshold records present
- ✓ Correct threshold values per PRD
- ✓ 6 mandatory + 1 optional threshold

**Section 5: JSONB Validation**
- ✓ JSONB columns accept valid JSON structures

**Section 6: CASCADE DELETE**
- ✓ Child records deleted when parent removed

**Section 7: Query Performance**
- ✓ Index usage confirmed via EXPLAIN

### Manual Verification Queries

```sql
-- 1. Verify all tables created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
-- Expected: 10 tables

-- 2. Check threshold seed data
SELECT metric, threshold_value, mandatory
FROM opportunity_thresholds
WHERE environment = 'production'
ORDER BY metric;
-- Expected: 7 rows

-- 3. Verify foreign key relationships
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;
-- Expected: Multiple FK relationships

-- 4. Test JSONB functionality
SELECT metrics FROM opportunity_metrics LIMIT 1;
-- Should work even if empty result

-- 5. Check index coverage
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- Expected: 15+ indexes
```

---

## Rollback Procedures

### Full Rollback (Nuclear Option)

⚠️ **WARNING**: This will delete ALL tables and data created by Day 1 migrations.

```sql
-- Execute in psql with extreme caution
BEGIN;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS etl_logs CASCADE;
DROP TABLE IF EXISTS lead_transactions CASCADE;
DROP TABLE IF EXISTS lead_tasks CASCADE;
DROP TABLE IF EXISTS newsletter_issues CASCADE;
DROP TABLE IF EXISTS opportunity_metrics CASCADE;
DROP TABLE IF EXISTS opportunities CASCADE;
DROP TABLE IF EXISTS opportunity_runs CASCADE;
DROP TABLE IF EXISTS opportunity_thresholds CASCADE;
DROP TABLE IF EXISTS opportunity_hypotheses CASCADE;
DROP TABLE IF EXISTS orchestrator_run_log CASCADE;

-- Verify all tables dropped
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
    'orchestrator_run_log',
    'opportunity_hypotheses',
    'opportunity_runs',
    'opportunities',
    'opportunity_metrics',
    'newsletter_issues',
    'lead_tasks',
    'lead_transactions',
    'opportunity_thresholds',
    'etl_logs'
);
-- Expected: 0 rows

COMMIT;
-- Or ROLLBACK if you want to abort
```

### Partial Rollback

If only specific migrations need to be reversed:

```sql
-- Rollback Step 4 only
DROP TABLE IF EXISTS etl_logs CASCADE;

-- Rollback Step 3 only
DELETE FROM opportunity_thresholds WHERE environment = 'production';

-- Rollback Step 2 only
DROP TABLE IF EXISTS lead_transactions CASCADE;
DROP TABLE IF EXISTS lead_tasks CASCADE;
DROP TABLE IF EXISTS newsletter_issues CASCADE;
DROP TABLE IF EXISTS opportunity_metrics CASCADE;
DROP TABLE IF EXISTS opportunities CASCADE;
DROP TABLE IF EXISTS opportunity_runs CASCADE;
DROP TABLE IF EXISTS opportunity_thresholds CASCADE;
DROP TABLE IF EXISTS opportunity_hypotheses CASCADE;

-- Rollback Step 1 only
DROP TABLE IF EXISTS orchestrator_run_log CASCADE;
```

### Re-running Migrations After Rollback

After rollback, simply re-execute migrations in order (see [Migration Execution](#migration-execution)).

All migration scripts are **idempotent** using `IF NOT EXISTS` and `ON CONFLICT` clauses, so they can be safely re-run.

---

## Troubleshooting

### Connection Failures

#### Error: "could not translate host name to address"
```
psql: error: could not translate host name "host.neon.tech" to address
```

**Solution**:
- Check network connectivity
- Verify DNS resolution: `nslookup host.neon.tech`
- Ensure VPN/firewall not blocking Neon endpoints

---

#### Error: "FATAL: password authentication failed"
```
psql: error: FATAL: password authentication failed for user "username"
```

**Solution**:
- Verify `NEON_CONNECTION_STRING` is correct
- Check if password contains special characters (URL-encode if needed)
- Confirm user exists: contact Neon admin

---

#### Error: "SSL connection required"
```
FATAL: no pg_hba.conf entry for host
```

**Solution**:
- Ensure connection string includes `?sslmode=require`
- Example: `postgresql://user:pass@host.neon.tech/db?sslmode=require`

---

### Migration Execution Errors

#### Error: "relation already exists"
```
ERROR: relation "opportunity_hypotheses" already exists
```

**Solution**:
- Migrations already executed successfully
- Verify with: `\dt` in psql
- If partial migration, check which step failed and rollback that step only

---

#### Error: "column already exists"
```
ERROR: column "created_on" of relation "opportunity_hypotheses" already exists
```

**Solution**:
- This is expected if re-running 002_opportunity_tables.sql
- The `ADD COLUMN IF NOT EXISTS` clause should prevent this
- If error persists, check PostgreSQL version (requires 9.6+)

---

#### Error: "constraint violation"
```
ERROR: duplicate key value violates unique constraint
```

**Solution**:
- Check if threshold data already seeded
- Script uses `ON CONFLICT DO UPDATE` so this should not occur
- If it does, manually verify: `SELECT * FROM opportunity_thresholds;`

---

#### Error: "insufficient privilege"
```
ERROR: permission denied for schema public
```

**Solution**:
- Verify database user has CREATE/ALTER privileges
- Grant permissions: `GRANT ALL ON SCHEMA public TO username;`
- Contact Neon admin if using managed database

---

### Validation Failures

#### Test fails: "Missing tables"
**Diagnosis**: Migration 001 or 002 did not complete
**Solution**: Re-run failed migration, check logs for errors

---

#### Test fails: "FK constraint missing"
**Diagnosis**: Migration 002 partially executed
**Solution**: Rollback Step 2, re-run 002_opportunity_tables.sql

---

#### Test fails: "Threshold count incorrect"
**Diagnosis**: Migration 003 did not complete
**Solution**: Check threshold table: `SELECT COUNT(*) FROM opportunity_thresholds;`
If 0, re-run 003_threshold_seed.sql

---

## Common Errors

### 1. Extension "pgcrypto" Not Available

**Error**:
```
ERROR: extension "pgcrypto" is not available
```

**Solution**:
Neon Postgres should have pgcrypto pre-installed. If not:
```sql
-- Check available extensions
SELECT * FROM pg_available_extensions WHERE name = 'pgcrypto';

-- If exists but not enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

### 2. Timeout on Large Migrations

**Error**:
```
ERROR: canceling statement due to statement timeout
```

**Solution**:
```sql
-- Increase statement timeout (adjust as needed)
SET statement_timeout = '5min';
```

### 3. Connection Pool Exhaustion

**Error**:
```
FATAL: remaining connection slots are reserved
```

**Solution**:
- Close other psql sessions
- Check Neon connection limits in dashboard
- Use connection pooling (PgBouncer) for high-concurrency scenarios

### 4. Disk Space Issues

**Error**:
```
ERROR: could not extend file: No space left on device
```

**Solution**:
- Check Neon storage quota in dashboard
- Upgrade plan if at limit
- Clean up unused databases/tables

---

## Post-Migration Checklist

After successful migration and validation:

- [ ] All 10 tables exist
- [ ] All validation tests pass
- [ ] 7 threshold records seeded
- [ ] Foreign key relationships working
- [ ] CASCADE DELETE tested
- [ ] Indexes created (15+ indexes)
- [ ] JSONB columns functional
- [ ] Query performance acceptable (review EXPLAIN output)
- [ ] Backup strategy documented
- [ ] Team notified of schema changes
- [ ] Update CHANGELOG or migration log

---

## Next Steps

After Day 1 completion:

1. **Day 2**: Implement KG/RAG enhancements (see Technical Implementation Plan)
2. **Day 3**: Build orchestrator workflow
3. **Day 4**: Create dashboards and finalize SOPs
4. **Day 5**: End-to-end validation with real hypotheses

---

## Support

**For Issues**:
- Check [Error Handling Protocol](../../.claude/ERROR-HANDLING-PROTOCOL.md)
- Review [Technical Implementation Plan](../prd/Boring-Businesses-Technical-Implementation-Plan.md)
- Contact: Alex Johnson (@abjohnson5f)

**Documentation**:
- PRD: `docs/prd/Boring-Businesses-Platform-PRD.md`
- Business Context: `docs/business-context.md`
- Claude Instructions: `.claude/CLAUDE.md`

---

**Runbook Version**: 1.0
**Last Validated**: 2025-10-25
**Next Review**: After Day 5 completion
