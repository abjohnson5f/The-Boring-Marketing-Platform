-- 001_create_orchestrator_log.sql
-- Purpose: create orchestrator run logging table for n8n workflows

CREATE TABLE IF NOT EXISTS orchestrator_run_log (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id UUID NOT NULL,
    hypothesis_id UUID,
    stage TEXT NOT NULL,
    status TEXT NOT NULL,
    duration_ms INTEGER,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    error JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_orchestrator_run_log_run_id
    ON orchestrator_run_log (run_id);

CREATE INDEX IF NOT EXISTS idx_orchestrator_run_log_stage
    ON orchestrator_run_log (stage);

COMMENT ON TABLE orchestrator_run_log IS 'Stores orchestrator stage runtimes and statuses for SLA tracking and debugging.';
COMMENT ON COLUMN orchestrator_run_log.run_id IS 'Unique identifier for each orchestrator run segment.';
COMMENT ON COLUMN orchestrator_run_log.hypothesis_id IS 'Optional reference to the associated hypothesis; populated after Day 3 schema migration.';



