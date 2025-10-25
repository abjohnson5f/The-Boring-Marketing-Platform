-- 001_create_orchestrator_log.sql
-- Purpose: establish the orchestrator runtime logging table used across workflows

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS orchestrator_run_log (
    run_id UUID PRIMARY KEY,
    hypothesis_id UUID,
    stage TEXT NOT NULL,
    status TEXT NOT NULL,
    duration_ms INTEGER CHECK (duration_ms IS NULL OR duration_ms >= 0),
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    error JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_orchestrator_run_log_hypothesis
    ON orchestrator_run_log (hypothesis_id);

CREATE INDEX IF NOT EXISTS idx_orchestrator_run_log_started_at
    ON orchestrator_run_log (started_at DESC);

COMMENT ON TABLE orchestrator_run_log IS 'Stores orchestrator stage runtimes and errors for hypothesis runs.';
COMMENT ON COLUMN orchestrator_run_log.run_id IS 'Unique identifier for each orchestrator run segment.';
COMMENT ON COLUMN orchestrator_run_log.hypothesis_id IS 'Optional reference to the associated hypothesis; populated after Day 3 schema migration.';

