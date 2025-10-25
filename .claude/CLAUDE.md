# Boring Businesses Marketing - Claude Code Configuration

## Business Context (Auto-Loaded)
@../docs/business-context.md
@../docs/prd/Boring-Businesses-Platform-PRD.md
@../docs/prd/Boring-Businesses-Technical-Implementation-Plan.md

## Project Overview
Boring Businesses platform operationalizes James "The Boring Marketer" playbook: discover underserved, high-ticket niches in tier 2/3 cities; validate market gaps using Google Maps intelligence; spin up media-led assets (newsletters, directories) that monetize via lead resale ($100-200/lead) or partnerships; and provide a path to owning operations when warranted.

**Core Strategy**: Media-led GTM (newsletters, directories) → Lead monetization → (Optional) Operational ownership.
**Proof Point**: Diesel Dudes ($30k/mo, $1.6k/job, 10 inbound calls/day) demonstrates model viability.

## Architecture
- **Database**: Postgres (Neon) with JSONB for flexible business/review storage
- **Workflows**: n8n for orchestration and RAG chat
- **Data Source**: Apify API for Google Maps business/review scraping
- **AI Layer**: OpenAI/OpenRouter models via n8n LangChain nodes

## Specialized Sub-Agents

**Location**: `.claude/agents/` (YAML frontmatter + Markdown)
**Invocation**: Automatic (Claude detects when needed) or explicit (`"Use the X agent"`)

### `documentation-writer`
Draft SOPs, runbooks, and technical documentation from implementation notes.
- **Description**: Use PROACTIVELY after code changes or when documentation requested
- **Tools**: Read, Grep, Glob, Write
- **Outputs to**: `docs/runbooks/` or `docs/dashboards/`
- **Forbidden**: Modifying `docs/Reference files/`

### `sql-migrations`
Author Postgres migrations with proper schema versioning.
- **Description**: Use PROACTIVELY when schema changes needed
- **Tools**: Read, Write, Bash
- **Outputs to**: `sql/` directory with incremental numbering
- **Requirements**: Idempotent migrations with rollback guidance

### `testing-agent`
Execute and validate workflows and data transformations.
- **Description**: Use PROACTIVELY after implementation changes
- **Tools**: Read, Bash, Grep, Glob
- **Outputs to**: `docs/testing/` with timestamped results
- **Requirements**: Pass/fail metrics, runtime durations, evidence

### `workflow-editor`
Modify n8n workflow JSON files with surgical precision.
- **Description**: Use PROACTIVELY when workflow modifications needed
- **Tools**: Read, Write, Grep, Glob, Bash
- **Outputs to**: `workflows/` directory
- **Validation**: JSON structure validation via hooks

## Parallel Sub-Agent Execution

**Capability**: Run up to **10 sub-agents concurrently** for dramatic speed improvements.

**Use Cases**:
- Exploratory codebase analysis (4-8 agents analyzing different directories)
- Multi-component testing (5-10 agents testing independent systems)
- Parallel documentation (3-6 agents creating different runbooks)
- Code review (3-5 agents reviewing independent features)

**Example**:
```
Explore this codebase using 4 agents in parallel:
- Agent 1: Analyze database schema in sql/
- Agent 2: Review n8n workflows in workflows/
- Agent 3: Examine documentation in docs/
- Agent 4: Investigate reference files

Each agent should produce a summary of findings.
```

**Performance**: Up to **10x faster** for truly independent tasks.

**See**: [PARALLEL-EXECUTION-GUIDE.md](.claude/PARALLEL-EXECUTION-GUIDE.md) for detailed patterns and best practices.

## Hooks Configuration

### Security Hook: `user-prompt-submit.sh`
**Blocks dangerous commands before execution:**
- `rm -rf` operations
- `.env` file access attempts
- Other destructive patterns

### Validation Hook: `tool-use-complete.sh`
**Runs after file edits:**
- Validates JSON syntax for workflow files
- Logs all file changes to `docs/testing/hook-log.md`
- Prevents invalid workflow commits

### Notification Hook: `agent-finish.sh`
**Runs when agent tasks complete:**
- Sends Slack notifications (if `SLACK_WEBHOOK_URL` configured)
- Lists modified files from git status
- Silent if webhook not configured

## Environment Variables
- `SLACK_WEBHOOK_URL`: Optional Slack integration for completion notifications
- Load via: `source scripts/load-env.sh .env`

## Directory Structure Rules

### Read-Only Paths
- `docs/Reference files/` - Never modify, only read

### Output Directories
- `docs/runbooks/` - Documentation outputs
- `docs/dashboards/` - Dashboard documentation
- `docs/testing/` - Test results and logs
- `sql/` - Migration files (numbered: 001_, 002_, etc.)
- `workflows/` - n8n workflow JSON files

## Key Architectural Principles

### Database Design
- JSONB for business dimensions (flexible, RAG-friendly)
- Idempotent UPSERT on `apify_place_id` (no duplicates)
- Atomic batch inserts for reviews
- Execution tracking via `market_executions` table

### n8n Patterns
- Follow building block templates from reference files
- Preserve credential references (don't alter IDs)
- Use Sticky Notes for inline documentation
- Validate JSON before committing

### Testing Standards
- Binary success criteria (PASS/FAIL, not subjective)
- Automated test execution via SQL
- Performance benchmarks with EXPLAIN ANALYZE
- Self-contained with cleanup (idempotent tests)

## Common Workflows

### Creating Documentation
```bash
# Use the documentation writer agent
/documentation-writer

# Request: "Create SOP for deploying n8n workflows to production"
```

### Writing Migrations
```bash
# Use SQL migration agent
/sql-migrations

# Request: "Add indexes for business search queries"
```

### Testing Features
```bash
# Use testing agent
/testing-agent

# Request: "Validate RAG chat workflow end-to-end"
```

### Editing Workflows
```bash
# Use workflow editor agent
/workflow-editor

# Request: "Add error handling to Apify data collection workflow"
```

## Quality Gates
- ✅ All JSON files validated before commit
- ✅ Dangerous commands blocked automatically
- ✅ File changes logged for audit trail
- ✅ Reference files protected from modification
- ✅ Migrations numbered sequentially

## Success Metrics
- API response: <300ms P95
- Relevance scores: >0.8 average
- Error rate: <1% in production
- Test coverage: Binary pass/fail criteria
