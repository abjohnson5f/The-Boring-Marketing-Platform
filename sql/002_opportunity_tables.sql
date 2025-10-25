-- 002_opportunity_tables.sql
-- Purpose: establish opportunity tracking schema including hypotheses, runs, opportunities, metrics, newsletter issues, lead tasks, lead transactions, thresholds

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS opportunity_hypotheses (
    hypothesis_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    niche TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    rationale TEXT,
    source_prompt TEXT,
    created_by TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    status TEXT NOT NULL DEFAULT 'new',
    last_run_at TIMESTAMPTZ,
    analyzed_at TIMESTAMPTZ,
    CONSTRAINT chk_opportunity_hypotheses_status
        CHECK (status IN ('new','ready_for_review','in_analysis','validated','needs_review','discarded','in_campaign','monetized','blocked'))
);

ALTER TABLE opportunity_hypotheses
    ADD COLUMN IF NOT EXISTS created_on DATE DEFAULT CURRENT_DATE;

UPDATE opportunity_hypotheses
SET created_on = created_at::date
WHERE created_on IS NULL;

ALTER TABLE opportunity_hypotheses
    ALTER COLUMN created_on SET NOT NULL,
    ALTER COLUMN created_on SET DEFAULT CURRENT_DATE;

CREATE UNIQUE INDEX IF NOT EXISTS uq_opportunity_hypotheses_niche_city_state_day
    ON opportunity_hypotheses (niche, city, state, created_on);

CREATE INDEX IF NOT EXISTS idx_opportunity_hypotheses_status
    ON opportunity_hypotheses (status);

CREATE TABLE IF NOT EXISTS opportunity_runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hypothesis_id UUID NOT NULL REFERENCES opportunity_hypotheses (hypothesis_id) ON DELETE CASCADE,
    apify_run_id TEXT,
    city TEXT,
    state TEXT,
    search_terms TEXT[],
    records_ingested INTEGER,
    warnings TEXT[],
    duration_ms INTEGER,
    run_stage TEXT NOT NULL DEFAULT 'ingestion',
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    last_error TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_opportunity_runs_hypothesis
    ON opportunity_runs (hypothesis_id);

CREATE INDEX IF NOT EXISTS idx_opportunity_runs_started_at
    ON opportunity_runs (started_at DESC);

CREATE TABLE IF NOT EXISTS opportunities (
    opportunity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hypothesis_id UUID NOT NULL REFERENCES opportunity_hypotheses (hypothesis_id) ON DELETE CASCADE,
    analysis_version INTEGER NOT NULL DEFAULT 1,
    status TEXT NOT NULL,
    summary TEXT,
    recommended_actions JSONB,
    top_targets JSONB,
    analyzed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_opportunities_status
        CHECK (status IN ('validated','needs_review','discarded'))
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_opportunities_hypothesis_version
    ON opportunities (hypothesis_id, analysis_version);

CREATE TABLE IF NOT EXISTS opportunity_metrics (
    metrics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities (opportunity_id) ON DELETE CASCADE,
    metrics JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_opportunity_metrics_opportunity
    ON opportunity_metrics (opportunity_id);

CREATE INDEX IF NOT EXISTS idx_opportunity_metrics_metrics_jsonb
    ON opportunity_metrics USING GIN (metrics);

CREATE TABLE IF NOT EXISTS newsletter_issues (
    issue_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities (opportunity_id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'draft',
    publish_target_date DATE,
    subject_lines JSONB,
    content JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_newsletter_issue_status
        CHECK (status IN ('draft','scheduled','sent'))
);

CREATE INDEX IF NOT EXISTS idx_newsletter_issues_opportunity
    ON newsletter_issues (opportunity_id);

CREATE TABLE IF NOT EXISTS lead_tasks (
    task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities (opportunity_id) ON DELETE CASCADE,
    business_id UUID,
    contact_priority INTEGER,
    outreach_channels TEXT[],
    status TEXT NOT NULL DEFAULT 'pending',
    assigned_to TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_lead_tasks_status
        CHECK (status IN ('pending','in_progress','completed','cancelled'))
);

CREATE INDEX IF NOT EXISTS idx_lead_tasks_opportunity
    ON lead_tasks (opportunity_id);

CREATE INDEX IF NOT EXISTS idx_lead_tasks_status_priority
    ON lead_tasks (status, contact_priority DESC);

CREATE TABLE IF NOT EXISTS lead_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities (opportunity_id) ON DELETE CASCADE,
    partner_id UUID,
    amount NUMERIC(12,2),
    lead_volume INTEGER,
    conversion_rate NUMERIC(5,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_lead_transactions_opportunity
    ON lead_transactions (opportunity_id);

CREATE INDEX IF NOT EXISTS idx_lead_transactions_partner
    ON lead_transactions (partner_id);

CREATE TABLE IF NOT EXISTS opportunity_thresholds (
    threshold_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric TEXT NOT NULL,
    threshold_value NUMERIC(10,4) NOT NULL,
    mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    environment TEXT NOT NULL DEFAULT 'production',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (metric, environment)
);

COMMENT ON TABLE opportunity_hypotheses IS 'Registry of niche/city hypotheses and their status through the pipeline.';
COMMENT ON COLUMN opportunity_hypotheses.status IS 'Represents the current lifecycle stage of the hypothesis; human approval required for in_analysis onwards.';

COMMENT ON TABLE opportunity_runs IS 'Historical log of ingestion/analysis runs associated with each hypothesis.';
COMMENT ON COLUMN opportunity_runs.run_stage IS 'Indicates the workflow stage recorded by this run entry (ingestion, rag_analysis, activation, etc.).';

COMMENT ON TABLE opportunities IS 'Stores the derived opportunity snapshot produced from orchestrated analysis.';
COMMENT ON COLUMN opportunities.recommended_actions IS 'JSON array of recommended next actions for operators and content teams.';
COMMENT ON COLUMN opportunities.top_targets IS 'JSON array of top target businesses with contact priority metadata.';

COMMENT ON TABLE opportunity_metrics IS 'Structured metrics per opportunity; metrics column retains raw calculations and status flags.';

COMMENT ON TABLE newsletter_issues IS 'Generated newsletter briefs tied to validated opportunities.';

COMMENT ON TABLE lead_tasks IS 'Lead outreach tasks generated from validated opportunities.';
COMMENT ON COLUMN lead_tasks.outreach_channels IS 'Array of prioritized outreach channels (e.g., phone, email, linkedin).';

COMMENT ON TABLE lead_transactions IS 'Records of monetization events for sold leads or partnerships.';

COMMENT ON TABLE opportunity_thresholds IS 'Static thresholds used by the scoring engine to evaluate opportunity metrics by environment.';

