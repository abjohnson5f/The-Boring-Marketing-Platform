-- 001_constraint_validation.sql
-- Purpose: Validate database schema constraints, indexes, and data integrity after Day 1 migrations
-- Expected: All tests should return 'PASS' status

-- =============================================================================
-- SECTION 1: TABLE EXISTENCE VALIDATION
-- =============================================================================

DO $$
DECLARE
    expected_tables TEXT[] := ARRAY[
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
    ];
    table_name TEXT;
    missing_tables TEXT[] := '{}';
BEGIN
    FOREACH table_name IN ARRAY expected_tables
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.tables
            WHERE table_schema = 'public' AND tables.table_name = table_name
        ) THEN
            missing_tables := array_append(missing_tables, table_name);
        END IF;
    END LOOP;

    IF array_length(missing_tables, 1) > 0 THEN
        RAISE NOTICE 'TEST FAIL: Missing tables: %', array_to_string(missing_tables, ', ');
    ELSE
        RAISE NOTICE 'TEST PASS: All 10 expected tables exist';
    END IF;
END $$;

-- =============================================================================
-- SECTION 2: CONSTRAINT VALIDATION
-- =============================================================================

-- Test 2.1: Unique constraint on hypothesis_id
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: opportunity_hypotheses.hypothesis_id has PRIMARY KEY'
        ELSE 'FAIL: opportunity_hypotheses.hypothesis_id PRIMARY KEY missing'
    END AS test_result
FROM information_schema.table_constraints
WHERE table_name = 'opportunity_hypotheses'
AND constraint_type = 'PRIMARY KEY'
AND constraint_name LIKE '%hypothesis_id%';

-- Test 2.2: Unique constraint on (niche, city, state, created_on)
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: opportunity_hypotheses unique constraint on niche/city/state/date exists'
        ELSE 'FAIL: opportunity_hypotheses unique constraint missing'
    END AS test_result
FROM pg_indexes
WHERE tablename = 'opportunity_hypotheses'
AND indexname = 'uq_opportunity_hypotheses_niche_city_state_day';

-- Test 2.3: Foreign key integrity (opportunity_runs → opportunity_hypotheses)
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: opportunity_runs has FK to opportunity_hypotheses'
        ELSE 'FAIL: opportunity_runs FK to opportunity_hypotheses missing'
    END AS test_result
FROM information_schema.table_constraints
WHERE table_name = 'opportunity_runs'
AND constraint_type = 'FOREIGN KEY';

-- Test 2.4: Foreign key integrity (opportunities → opportunity_hypotheses)
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: opportunities has FK to opportunity_hypotheses'
        ELSE 'FAIL: opportunities FK to opportunity_hypotheses missing'
    END AS test_result
FROM information_schema.table_constraints
WHERE table_name = 'opportunities'
AND constraint_type = 'FOREIGN KEY';

-- Test 2.5: Status check constraint on opportunity_hypotheses
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: opportunity_hypotheses status CHECK constraint exists'
        ELSE 'FAIL: opportunity_hypotheses status CHECK constraint missing'
    END AS test_result
FROM information_schema.check_constraints
WHERE constraint_name = 'chk_opportunity_hypotheses_status';

-- Test 2.6: Status check constraint on opportunities
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: opportunities status CHECK constraint exists'
        ELSE 'FAIL: opportunities status CHECK constraint missing'
    END AS test_result
FROM information_schema.check_constraints
WHERE constraint_name = 'chk_opportunities_status';

-- Test 2.7: Status check constraint on newsletter_issues
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: newsletter_issues status CHECK constraint exists'
        ELSE 'FAIL: newsletter_issues status CHECK constraint missing'
    END AS test_result
FROM information_schema.check_constraints
WHERE constraint_name = 'chk_newsletter_issue_status';

-- Test 2.8: Status check constraint on lead_tasks
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: lead_tasks status CHECK constraint exists'
        ELSE 'FAIL: lead_tasks status CHECK constraint missing'
    END AS test_result
FROM information_schema.check_constraints
WHERE constraint_name = 'chk_lead_tasks_status';

-- Test 2.9: Severity check constraint on etl_logs
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: etl_logs severity CHECK constraint exists'
        ELSE 'FAIL: etl_logs severity CHECK constraint missing'
    END AS test_result
FROM information_schema.check_constraints
WHERE constraint_name = 'chk_etl_logs_severity';

-- Test 2.10: Duration check constraint on orchestrator_run_log
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM pg_constraint c
            JOIN pg_class t ON c.conrelid = t.oid
            WHERE t.relname = 'orchestrator_run_log'
            AND c.contype = 'c'
            AND pg_get_constraintdef(c.oid) LIKE '%duration_ms%'
        ) THEN 'PASS: orchestrator_run_log duration_ms CHECK constraint exists'
        ELSE 'FAIL: orchestrator_run_log duration_ms CHECK constraint missing'
    END AS test_result;

-- =============================================================================
-- SECTION 3: INDEX VALIDATION
-- =============================================================================

-- Test 3.1: Indexes on orchestrator_run_log
SELECT
    CASE
        WHEN COUNT(*) >= 2 THEN 'PASS: orchestrator_run_log has expected indexes (hypothesis_id, started_at)'
        ELSE 'FAIL: orchestrator_run_log missing indexes (found: ' || COUNT(*) || ', expected: 2+)'
    END AS test_result
FROM pg_indexes
WHERE tablename = 'orchestrator_run_log'
AND indexname IN ('idx_orchestrator_run_log_hypothesis', 'idx_orchestrator_run_log_started_at');

-- Test 3.2: Indexes on opportunity_hypotheses
SELECT
    CASE
        WHEN COUNT(*) >= 2 THEN 'PASS: opportunity_hypotheses has expected indexes'
        ELSE 'FAIL: opportunity_hypotheses missing indexes (found: ' || COUNT(*) || ', expected: 2+)'
    END AS test_result
FROM pg_indexes
WHERE tablename = 'opportunity_hypotheses'
AND indexname IN ('idx_opportunity_hypotheses_status', 'uq_opportunity_hypotheses_niche_city_state_day');

-- Test 3.3: Indexes on opportunity_runs
SELECT
    CASE
        WHEN COUNT(*) >= 2 THEN 'PASS: opportunity_runs has expected indexes'
        ELSE 'FAIL: opportunity_runs missing indexes (found: ' || COUNT(*) || ', expected: 2+)'
    END AS test_result
FROM pg_indexes
WHERE tablename = 'opportunity_runs'
AND indexname IN ('idx_opportunity_runs_hypothesis', 'idx_opportunity_runs_started_at');

-- Test 3.4: GIN index on opportunity_metrics JSONB column
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: opportunity_metrics has GIN index on metrics JSONB'
        ELSE 'FAIL: opportunity_metrics GIN index missing'
    END AS test_result
FROM pg_indexes
WHERE tablename = 'opportunity_metrics'
AND indexname = 'idx_opportunity_metrics_metrics_jsonb';

-- Test 3.5: Indexes on lead_tasks
SELECT
    CASE
        WHEN COUNT(*) >= 2 THEN 'PASS: lead_tasks has expected indexes'
        ELSE 'FAIL: lead_tasks missing indexes (found: ' || COUNT(*) || ', expected: 2+)'
    END AS test_result
FROM pg_indexes
WHERE tablename = 'lead_tasks'
AND indexname IN ('idx_lead_tasks_opportunity', 'idx_lead_tasks_status_priority');

-- Test 3.6: Indexes on etl_logs
SELECT
    CASE
        WHEN COUNT(*) >= 2 THEN 'PASS: etl_logs has expected indexes'
        ELSE 'FAIL: etl_logs missing indexes (found: ' || COUNT(*) || ', expected: 2+)'
    END AS test_result
FROM pg_indexes
WHERE tablename = 'etl_logs'
AND indexname IN ('idx_etl_logs_run_id', 'idx_etl_logs_created_at');

-- =============================================================================
-- SECTION 4: THRESHOLD DATA VALIDATION
-- =============================================================================

-- Test 4.1: Threshold records count
SELECT
    CASE
        WHEN COUNT(*) = 7 THEN 'PASS: opportunity_thresholds has 7 seeded records'
        ELSE 'FAIL: opportunity_thresholds has ' || COUNT(*) || ' records (expected: 7)'
    END AS test_result,
    COUNT(*) as actual_count
FROM opportunity_thresholds
WHERE environment = 'production';

-- Test 4.2: Threshold value ranges validation
SELECT
    metric,
    threshold_value,
    CASE
        WHEN metric = 'review_velocity' AND threshold_value = 10.0 THEN 'PASS'
        WHEN metric = 'provider_density' AND threshold_value = 12.0 THEN 'PASS'
        WHEN metric = 'incumbent_ratio' AND threshold_value = 0.35 THEN 'PASS'
        WHEN metric = 'sentiment_balance' AND threshold_value = -10.0 THEN 'PASS'
        WHEN metric = 'channel_presence_score' AND threshold_value = 0.5 THEN 'PASS'
        WHEN metric = 'high_ticket_confidence' AND threshold_value = 0.7 THEN 'PASS'
        WHEN metric = 'lead_viability' AND threshold_value = 3.0 THEN 'PASS'
        ELSE 'FAIL: Unexpected threshold value'
    END AS test_result
FROM opportunity_thresholds
WHERE environment = 'production'
ORDER BY metric;

-- Test 4.3: Mandatory flags validation
SELECT
    CASE
        WHEN COUNT(*) = 6 THEN 'PASS: 6 mandatory thresholds configured correctly'
        ELSE 'FAIL: Expected 6 mandatory thresholds, found ' || COUNT(*)
    END AS test_result
FROM opportunity_thresholds
WHERE environment = 'production'
AND mandatory = TRUE;

-- =============================================================================
-- SECTION 5: JSONB STRUCTURE VALIDATION
-- =============================================================================

-- Test 5.1: JSONB columns exist and accept valid JSON
DO $$
DECLARE
    test_uuid UUID := gen_random_uuid();
BEGIN
    -- Test orchestrator_run_log.error JSONB
    INSERT INTO orchestrator_run_log (run_id, stage, status, error)
    VALUES (test_uuid, 'test_stage', 'test', '{"error_type": "validation", "message": "test"}'::jsonb);

    -- Test etl_logs.metadata JSONB
    INSERT INTO etl_logs (run_id, stage, severity, message, metadata)
    VALUES (test_uuid, 'test_stage', 'info', 'test', '{"node": "test_node"}'::jsonb);

    -- Cleanup
    DELETE FROM orchestrator_run_log WHERE run_id = test_uuid;
    DELETE FROM etl_logs WHERE run_id = test_uuid;

    RAISE NOTICE 'TEST PASS: JSONB columns accept valid JSON structures';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TEST FAIL: JSONB column validation error: %', SQLERRM;
END $$;

-- =============================================================================
-- SECTION 6: CASCADE DELETE VALIDATION
-- =============================================================================

DO $$
DECLARE
    test_hyp_id UUID := gen_random_uuid();
    test_opp_id UUID := gen_random_uuid();
    run_count INTEGER;
    opp_count INTEGER;
    metric_count INTEGER;
BEGIN
    -- Create test hypothesis
    INSERT INTO opportunity_hypotheses (hypothesis_id, niche, city, state, status)
    VALUES (test_hyp_id, 'test_niche', 'test_city', 'TS', 'new');

    -- Create test run
    INSERT INTO opportunity_runs (hypothesis_id, run_stage)
    VALUES (test_hyp_id, 'test');

    -- Create test opportunity
    INSERT INTO opportunities (opportunity_id, hypothesis_id, status, summary)
    VALUES (test_opp_id, test_hyp_id, 'validated', 'test');

    -- Create test metrics
    INSERT INTO opportunity_metrics (opportunity_id, metrics)
    VALUES (test_opp_id, '{}'::jsonb);

    -- Delete hypothesis and check cascades
    DELETE FROM opportunity_hypotheses WHERE hypothesis_id = test_hyp_id;

    SELECT COUNT(*) INTO run_count FROM opportunity_runs WHERE hypothesis_id = test_hyp_id;
    SELECT COUNT(*) INTO opp_count FROM opportunities WHERE hypothesis_id = test_hyp_id;
    SELECT COUNT(*) INTO metric_count FROM opportunity_metrics WHERE opportunity_id = test_opp_id;

    IF run_count = 0 AND opp_count = 0 AND metric_count = 0 THEN
        RAISE NOTICE 'TEST PASS: CASCADE DELETE working correctly';
    ELSE
        RAISE NOTICE 'TEST FAIL: CASCADE DELETE not working (runs: %, opps: %, metrics: %)',
            run_count, opp_count, metric_count;
    END IF;
END $$;

-- =============================================================================
-- SECTION 7: COMMON QUERY PERFORMANCE VALIDATION
-- =============================================================================

-- Test 7.1: Query hypothesis by status (uses index)
EXPLAIN (FORMAT TEXT)
SELECT * FROM opportunity_hypotheses WHERE status = 'validated';

-- Test 7.2: Query runs by hypothesis (uses index)
EXPLAIN (FORMAT TEXT)
SELECT * FROM opportunity_runs WHERE hypothesis_id = gen_random_uuid();

-- Test 7.3: JSONB query on opportunity_metrics (uses GIN index)
EXPLAIN (FORMAT TEXT)
SELECT * FROM opportunity_metrics WHERE metrics @> '{"review_velocity": 15}'::jsonb;

-- =============================================================================
-- SUMMARY
-- =============================================================================

SELECT
    '========================================' AS summary_header,
    'VALIDATION COMPLETE' AS summary_title,
    '========================================' AS summary_footer;

-- View final table counts
SELECT
    table_name,
    (SELECT COUNT(*) FROM information_schema.tables t WHERE t.table_name = c.table_name AND t.table_schema = 'public') as exists
FROM (
    VALUES
        ('orchestrator_run_log'),
        ('opportunity_hypotheses'),
        ('opportunity_runs'),
        ('opportunities'),
        ('opportunity_metrics'),
        ('newsletter_issues'),
        ('lead_tasks'),
        ('lead_transactions'),
        ('opportunity_thresholds'),
        ('etl_logs')
) AS c(table_name)
ORDER BY table_name;
