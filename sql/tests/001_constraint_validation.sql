-- 001_constraint_validation.sql
-- Purpose: Validate Day 1 database schema after migrations
-- Expected: All queries should return expected row counts

\echo '========================================='
\echo 'Day 1 Schema Validation Tests'
\echo '========================================='

-- Test 1: Verify all expected tables exist
\echo ''
\echo 'Test 1: Checking table existence...'
SELECT
    COUNT(*) as table_count,
    CASE
        WHEN COUNT(*) = 10 THEN 'PASS ✓'
        ELSE 'FAIL ✗ Expected 10 tables'
    END as status
FROM information_schema.tables
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
    'market_thresholds',
    'runtime_log'
);

-- Test 2: Verify primary keys exist
\echo ''
\echo 'Test 2: Checking primary key constraints...'
SELECT
    COUNT(*) as pk_count,
    CASE
        WHEN COUNT(*) >= 10 THEN 'PASS ✓'
        ELSE 'FAIL ✗ Expected at least 10 PKs'
    END as status
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND constraint_type = 'PRIMARY KEY';

-- Test 3: Verify foreign keys exist
\echo ''
\echo 'Test 3: Checking foreign key constraints...'
SELECT
    COUNT(*) as fk_count,
    CASE
        WHEN COUNT(*) >= 5 THEN 'PASS ✓'
        ELSE 'FAIL ✗ Expected at least 5 FKs'
    END as status
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND constraint_type = 'FOREIGN KEY';

-- Test 4: Verify threshold seed data
\echo ''
\echo 'Test 4: Checking threshold seed data...'
SELECT
    COUNT(*) as threshold_count,
    CASE
        WHEN COUNT(*) = 7 THEN 'PASS ✓'
        ELSE 'FAIL ✗ Expected 7 threshold records'
    END as status
FROM market_thresholds;

-- Test 5: Verify indexes exist
\echo ''
\echo 'Test 5: Checking indexes...'
SELECT
    COUNT(*) as index_count,
    CASE
        WHEN COUNT(*) >= 15 THEN 'PASS ✓'
        ELSE 'FAIL ✗ Expected at least 15 indexes'
    END as status
FROM pg_indexes
WHERE schemaname = 'public';

\echo ''
\echo '========================================='
\echo 'Validation Complete'
\echo '========================================='
