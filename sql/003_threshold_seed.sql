-- 003_threshold_seed.sql
-- Purpose: seed initial opportunity threshold configuration per PRD Table 1

INSERT INTO opportunity_thresholds (metric, threshold_value, mandatory, environment)
VALUES
    ('review_velocity', 10.0, TRUE, 'production'),
    ('provider_density', 12.0, TRUE, 'production'),
    ('incumbent_ratio', 0.35, TRUE, 'production'),
    ('sentiment_balance', -10.0, TRUE, 'production'),
    ('channel_presence_score', 0.5, TRUE, 'production'),
    ('high_ticket_confidence', 0.7, TRUE, 'production'),
    ('lead_viability', 3.0, FALSE, 'production')
ON CONFLICT (metric, environment) DO UPDATE
SET threshold_value = EXCLUDED.threshold_value,
    mandatory = EXCLUDED.mandatory,
    updated_at = now();

