# Claude Code Configuration for Boring Businesses

This directory contains Claude Code-specific configurations including specialized agents (slash commands) and automated hooks.

## 🎯 Purpose

This setup replicates the Cursor IDE agent functionality for Claude Code, providing:
- **4 specialized agents** as slash commands
- **3 automated hooks** for security, validation, and notifications
- **Project-specific memory** via CLAUDE.md

## 📂 Directory Structure

```
.claude/
├── CLAUDE.md                          # Project memory (auto-loaded)
├── README.md                          # This file
├── commands/                          # Slash command agents
│   ├── documentation-writer.md        # /documentation-writer
│   ├── sql-migrations.md              # /sql-migrations
│   ├── testing-agent.md               # /testing-agent
│   └── workflow-editor.md             # /workflow-editor
└── hooks/                             # Automated validation hooks
    ├── user-prompt-submit.sh          # Security: blocks dangerous commands
    ├── tool-use-complete.sh           # Validation: JSON checks + logging
    └── agent-finish.sh                # Notifications: Slack integration
```

## 🤖 Specialized Agents (Slash Commands)

### `/documentation-writer`
**Purpose**: Create SOPs, runbooks, and technical documentation

**Usage**:
```
/documentation-writer

Create an SOP for deploying n8n workflows to production, including:
- Pre-deployment checklist
- Credential configuration steps
- Rollback procedures
```

**Outputs**: `docs/runbooks/` or `docs/dashboards/`

---

### `/sql-migrations`
**Purpose**: Author Postgres migrations with proper versioning

**Usage**:
```
/sql-migrations

Create a migration to add GIN indexes for JSONB search on the businesses table.
Include rollback instructions.
```

**Outputs**: `sql/NNN_descriptive_name.sql` (numbered sequentially)

---

### `/testing-agent`
**Purpose**: Execute and validate workflows and data transformations

**Usage**:
```
/testing-agent

Test the RAG chat workflow end-to-end:
1. Trigger webhook with sample query
2. Verify database queries execute
3. Validate response structure
4. Measure response time
```

**Outputs**: `docs/testing/test-results-YYYY-MM-DD-HH-MM-SS.md`

---

### `/workflow-editor`
**Purpose**: Modify n8n workflow JSON with precision

**Usage**:
```
/workflow-editor

Update the Apify data collection workflow to:
- Add retry logic for HTTP failures
- Include execution time tracking
- Add Sticky Note documenting rate limits
```

**Outputs**: `workflows/` (preserves original filename)

---

## 🔒 Automated Hooks

### 1. Security Hook: `user-prompt-submit.sh`
**Triggers**: Before any command execution
**Purpose**: Block dangerous operations

**Blocked patterns**:
- `rm -rf .` or `rm -rf ..`
- `cat .env`, `grep .env`, etc.
- Other destructive commands

**Example**:
```bash
# ❌ BLOCKED
User: "Run rm -rf . to clean up"
Hook: "Blocked command containing: rm -rf"

# ✅ ALLOWED
User: "List files in current directory"
Hook: (passes silently)
```

---

### 2. Validation Hook: `tool-use-complete.sh`
**Triggers**: After Edit or Write tool use
**Purpose**: Validate JSON and log changes

**Features**:
- **JSON Validation**: Workflow files automatically validated
- **Logging**: All edits logged to `docs/testing/hook-log.md`
- **Failure Prevention**: Invalid JSON blocks the operation

**Example log entry**:
```markdown
- 2025-10-23T14:30:45Z - ✅ Validated JSON: workflows/data-collection.json
- 2025-10-23T14:31:12Z - 📝 Edited file: docs/runbooks/deployment-sop.md
```

---

### 3. Notification Hook: `agent-finish.sh`
**Triggers**: When agent tasks complete
**Purpose**: Send Slack notifications

**Configuration**:
```bash
# Add to .env file (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Load environment
source scripts/load-env.sh
```

**Example notification**:
```
🤖 Claude Code agent run complete.

Modified files:
• workflows/rag-chat.json
• docs/testing/test-results-2025-10-23.md
```

---

## 🚀 Quick Start

### 1. Install (Already Complete)
The `.claude/` directory is already configured. No installation needed!

### 2. Use Slash Commands
```
# In Claude Code, type any of these commands:
/documentation-writer
/sql-migrations
/testing-agent
/workflow-editor
```

### 3. Enable Slack Notifications (Optional)
```bash
# Add to .env file
echo 'SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...' >> .env

# Load environment
source scripts/load-env.sh
```

### 4. Verify Hooks Are Working
```bash
# Check hook log (created after first file edit)
cat docs/testing/hook-log.md

# Example output:
# - 2025-10-23T14:30:45Z - ✅ Validated JSON: workflows/test.json
```

---

## 🔄 Cursor → Claude Code Migration

### What Changed?

| Cursor | Claude Code | Notes |
|--------|-------------|-------|
| `.cursor/agents/*.json` | `.claude/commands/*.md` | Agents → Slash commands |
| `hooks.json` | `.claude/hooks/*.sh` | JSON config → Bash scripts |
| `beforeCommand.js` | `user-prompt-submit.sh` | Node.js → Bash |
| `afterFileEdit.js` | `tool-use-complete.sh` | Node.js → Bash |
| `onAgentFinish.js` | `agent-finish.sh` | Node.js → Bash |

### What Stayed the Same?

✅ **Agent logic**: Identical prompts and rules
✅ **Hook behavior**: Same security/validation
✅ **Directory structure**: Compatible outputs
✅ **Environment**: Same `.env` file usage

---

## 📋 Testing Checklist

### Verify Agent Functionality
```bash
# 1. Test documentation writer
/documentation-writer
# Request: "Create a quick test document"
# Expected: New file in docs/runbooks/

# 2. Test SQL migrations
/sql-migrations
# Request: "Create a simple test migration"
# Expected: New file in sql/

# 3. Test workflow editor
/workflow-editor
# Request: "Add a comment to any workflow file"
# Expected: Workflow updated, JSON validated

# 4. Test testing agent
/testing-agent
# Request: "Document test execution process"
# Expected: New file in docs/testing/
```

### Verify Hook Behavior
```bash
# 1. Security hook (should block)
# Ask Claude: "Run cat .env"
# Expected: ❌ Blocked command containing: cat .env

# 2. Validation hook (check log)
cat docs/testing/hook-log.md
# Expected: Timestamped entries for file edits

# 3. Notification hook (requires Slack webhook)
# Configure SLACK_WEBHOOK_URL and complete an agent task
# Expected: Slack message with modified files
```

---

## 🛠️ Troubleshooting

### Hooks Not Running?
```bash
# Ensure hooks are executable
ls -la .claude/hooks/
# Should show: -rwxr-xr-x (executable permissions)

# If not executable:
chmod +x .claude/hooks/*.sh
```

### Slash Commands Not Found?
```bash
# Verify commands directory exists
ls .claude/commands/
# Expected: 4 .md files

# Check file naming (must be .md, not .txt)
```

### JSON Validation Failing?
```bash
# Manually validate JSON
python3 -m json.tool workflows/your-workflow.json

# Check hook log for details
cat docs/testing/hook-log.md | grep "❌"
```

### Slack Notifications Not Sending?
```bash
# Verify webhook URL is set
echo $SLACK_WEBHOOK_URL
# Should output your webhook URL

# Test manually
curl -X POST $SLACK_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d '{"text": "Test from terminal"}'
```

---

## 📚 Additional Resources

### Project Documentation
- [Technical Implementation Plan](../docs/prd/Boring-Businesses-Technical-Implementation-Plan.md)
- [Platform PRD](../docs/prd/Boring-Businesses-Platform-PRD.md)

### Reference Workflows
- `docs/Reference files/` - Read-only n8n templates

### Hook Logs
- `docs/testing/hook-log.md` - Audit trail of file changes

---

## 🎓 Best Practices

### Agent Usage
1. **Always specify output format**: "Create as markdown table" vs "Create documentation"
2. **Reference file paths**: "Update workflows/data-collection.json" vs "Update the workflow"
3. **Binary success criteria**: "Verify test passes" vs "Make sure it works"

### Hook Management
1. **Never bypass security hooks**: They protect against data loss
2. **Check hook logs regularly**: Monitor for unexpected validation failures
3. **Keep hooks executable**: Git doesn't always preserve permissions

### Project Organization
1. **Use sequential migration numbering**: 001_, 002_, 003_
2. **Timestamp test results**: Include date in filename
3. **Document in README**: Keep runbooks discoverable

---

## ✅ Migration Complete

Your Cursor agent setup has been successfully replicated for Claude Code!

**What you can do now**:
- Use `/documentation-writer` for SOPs
- Use `/sql-migrations` for database changes
- Use `/testing-agent` for validation
- Use `/workflow-editor` for n8n workflows
- All hooks automatically protect and validate your work

**Questions?** See troubleshooting section above or check `CLAUDE.md` for project-specific details.
