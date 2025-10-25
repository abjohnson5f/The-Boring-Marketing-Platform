# Day 1: Database Foundation & Hardening

**Estimated Duration**: 4-6 hours
**Dependencies**: Neon Postgres credentials
**Output**: Working database schema, validated migrations

---

@claude Execute Day 1 of the 5-day implementation sprint per Technical Implementation Plan Section 2.

## Context Documents (Auto-Loaded)

- **PRD**: `docs/prd/Boring-Businesses-Platform-PRD.md`
- **Technical Plan**: `docs/prd/Boring-Businesses-Technical-Implementation-Plan.md`
- **Business Context**: `docs/business-context.md`
- **Glossary**: `.claude/GLOSSARY.md`
- **Error Protocol**: `.claude/ERROR-HANDLING-PROTOCOL.md`

## Primary Tasks

### 1. Apply SQL Migrations to Neon Postgres

Execute migrations in order:
- `sql/001_create_orchestrator_log.sql` - Runtime logging table
- `sql/002_opportunity_tables.sql` - Core business tables
- `sql/003_threshold_seed.sql` - Metric thresholds
- `sql/004_runtime_logging.sql` - ETL logging

**Credentials**: Use GitHub Secrets `NEON_CONNECTION_STRING`

**Validation Required**:
```sql
-- Verify all tables created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Expected: 8 tables (hypotheses, runs, opportunities, etc.)
```

### 2. Test Data Quality Constraints

**Create test script**: `sql/tests/001_constraint_validation.sql`

Test cases:
- [ ] Unique constraint on `hypothesis_id`
- [ ] Foreign key integrity (runs → hypotheses)
- [ ] Threshold value ranges (0-100%)
- [ ] JSONB structure validation
- [ ] Index performance on common queries

### 3. Documentation

**Create**: `docs/runbooks/database-setup.md`

Must include:
- Connection instructions
- Migration rollback procedures
- Common troubleshooting (connection failures, permission errors)
- Backup/restore procedures

## Success Criteria (Binary)

- [ ] All 4 migrations executed without errors
- [ ] 8 tables exist in Neon database
- [ ] All constraints working (test SQL passes)
- [ ] Indexes created and functional
- [ ] Runbook created with rollback procedures
- [ ] Test queries return expected row counts

## Outputs

**Files to Create/Modify**:
- `sql/tests/001_constraint_validation.sql` (NEW)
- `docs/runbooks/database-setup.md` (NEW)
- GitHub comment with validation results

**PR Title**: "Day 1 Complete: Database Foundation"

**PR Description Template**:
```markdown
## Migration Results
- ✅ 001_create_orchestrator_log.sql (X rows)
- ✅ 002_opportunity_tables.sql (X tables)
- ✅ 003_threshold_seed.sql (X threshold rows)
- ✅ 004_runtime_logging.sql (X rows)

## Validation
[Paste test query results]

## Tables Created
[List of 8 tables with row counts]
```

## Error Handling

If migration fails:
1. Capture full error message
2. Check `.claude/ERROR-HANDLING-PROTOCOL.md` Section 3.1
3. Create `docs/testing/migration-errors-YYYYMMDD.md`
4. DO NOT proceed to Day 2
5. Comment on this issue with blocker details

## Agent Configuration

**Use**:
- `/sql-migrations` agent for migration work
- `/documentation-writer` for runbook
- `/testing-agent` for validation queries

**Follow**: Building block patterns from reference files

---

**When complete**: Close this issue, create PR, tag Alex for review.
