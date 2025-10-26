-- 004_runtime_logging.sql
-- Purpose: create auxiliary ETL logging table for ingestion workflows

CREATE TABLE IF NOT EXISTS etl_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id UUID,
    stage TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'info',
    message TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_etl_logs_run_id
    ON etl_logs (run_id);

CREATE INDEX IF NOT EXISTS idx_etl_logs_created_at
    ON etl_logs (created_at DESC);

COMMENT ON TABLE etl_logs IS 'Captures stage-level logging and alerts from ingestion/orchestrator workflows.';
COMMENT ON COLUMN etl_logs.metadata IS 'Optional JSON metadata for downstream debugging (e.g., node payloads, HTTP status codes).';



