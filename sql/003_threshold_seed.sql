-- 003_threshold_seed.sql
-- Purpose: seed threshold configuration for opportunity scoring engine

INSERT INTO opportunity_thresholds (metric, threshold_value, mandatory, environment)
VALUES
    ('review_velocity', 10.0, TRUE, 'production'),
    ('provider_density', 12.0, TRUE, 'production'),
    ('incumbent_ratio', 0.35, TRUE, 'production'),
    ('sentiment_balance', -0.10, TRUE, 'production'),
    ('channel_presence', 0.50, TRUE, 'production'),
    ('high_ticket_confidence', 0.70, TRUE, 'production'),
    ('lead_viability', 3.0, FALSE, 'production')
ON CONFLICT (metric, environment)
DO UPDATE
SET threshold_value = EXCLUDED.threshold_value,
    mandatory = EXCLUDED.mandatory,
    updated_at = now();



