# 5-Day Implementation Sprint - GitHub Issues

**Purpose**: Complete issue descriptions for Claude Code web/mobile autonomous execution
**Platform**: GitHub Actions + Cloud-based Claude Code
**Duration**: 5 days (4-8 hours per day)

---

## 📋 How to Use These Issues

### Step 1: Install Claude GitHub App (REQUIRED FIRST)

Follow: `.claude/CLAUDE-CODE-WEB-MOBILE-SETUP.md`

Quick method:
```bash
# In Claude Code terminal
/install-github-app
```

This configures:
- GitHub App installation
- Repository access for `abjohnson5f/BoringBusinessesMarketing`
- `ANTHROPIC_API_KEY` secret
- `.github/workflows/claude.yml` workflow file

### Step 2: Create GitHub Issues

**Copy each day's content** from these files to GitHub issues:

1. **Day 1**: [DAY-1-DATABASE-FOUNDATION.md](./DAY-1-DATABASE-FOUNDATION.md)
   - Title: "Day 1: Database Foundation & Hardening"
   - Labels: `sprint`, `day-1`, `database`

2. **Day 2**: [DAY-2-APIFY-WORKFLOW.md](./DAY-2-APIFY-WORKFLOW.md)
   - Title: "Day 2: Apify Data Collection Workflow"
   - Labels: `sprint`, `day-2`, `workflows`

3. **Day 3**: [DAY-3-ORCHESTRATOR.md](./DAY-3-ORCHESTRATOR.md)
   - Title: "Day 3: Orchestrator Workflow (JAMES-PLAYBOOK)"
   - Labels: `sprint`, `day-3`, `orchestrator`

4. **Day 4**: [DAY-4-RAG-ENHANCEMENT.md](./DAY-4-RAG-ENHANCEMENT.md)
   - Title: "Day 4: RAG & Newsletter Generation"
   - Labels: `sprint`, `day-4`, `rag`, `ai`

5. **Day 5**: [DAY-5-TESTING-DASHBOARDS.md](./DAY-5-TESTING-DASHBOARDS.md)
   - Title: "Day 5: End-to-End Testing & Dashboards"
   - Labels: `sprint`, `day-5`, `testing`, `production`

### Step 3: Configure Credentials (GitHub Secrets)

**Required Secrets** (add to repository):
- `ANTHROPIC_API_KEY` - From https://console.anthropic.com
- `NEON_CONNECTION_STRING` - From Neon Postgres dashboard
- `SLACK_WEBHOOK_URL` - From Slack webhook configuration (optional)
- `N8N_API_KEY` - From n8n instance (if needed)

**Add secrets**:
1. Go to: https://github.com/abjohnson5f/BoringBusinessesMarketing/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret above

### Step 4: Execution Methods

#### Method A: Sequential Execution (SAFE - Recommended for First Run)

Create issues one at a time:
1. Create **Day 1 issue only**
2. Wait for Claude to complete (GitHub Actions will trigger)
3. Review PR, merge when satisfied
4. Create **Day 2 issue**, repeat

**Pros**:
- Each day's output validates before next begins
- Easier to catch errors early
- Lower risk of cascading failures

**Cons**:
- Takes 5 days (one per day)
- Less time savings from parallelization

---

#### Method B: Parallel Execution (FAST - Requires Monitoring)

Create **all 5 issues at once**:
1. Copy-paste Day 1 → GitHub issue
2. Copy-paste Day 2 → GitHub issue
3. Copy-paste Day 3 → GitHub issue
4. Copy-paste Day 4 → GitHub issue
5. Copy-paste Day 5 → GitHub issue

**Claude Code will execute all 5 simultaneously** (cloud sandboxes).

**Pros**:
- All 5 days complete in ~8 hours (vs 5 days sequential)
- Maximum time savings
- Demonstrates full power of cloud execution

**Cons**:
- Must monitor all 5 PRs
- If Day 1 fails, Days 2-5 may produce incorrect code
- Higher cognitive load reviewing multiple PRs

**When to use**:
- You have time to monitor all 5 PRs actively
- You're confident in the specifications
- You want fastest possible completion

---

#### Method C: Hybrid (RECOMMENDED)

**Phase 1**: Days 1-2 sequential (foundation)
- Create Day 1 issue
- Wait for completion, review, merge
- Create Day 2 issue
- Wait for completion, review, merge

**Phase 2**: Days 3-5 parallel (build)
- Create Day 3, 4, 5 issues simultaneously
- Review all 3 PRs
- Merge when all pass validation

**Pros**:
- Foundation validated before complex builds
- Still saves ~2 days vs full sequential
- Lower risk than full parallel

**Recommended for**: First-time sprint execution

---

## 🔐 Context Preservation (No Context Loss)

**How Claude Maintains Context**:

Each GitHub issue automatically loads:
1. **Project Memory**: `.claude/CLAUDE.md` (business context, agents, architecture)
2. **PRD**: `docs/prd/Boring-Businesses-Platform-PRD.md`
3. **Technical Plan**: `docs/prd/Boring-Businesses-Technical-Implementation-Plan.md`
4. **Glossary**: `.claude/GLOSSARY.md` (prevents terminology drift)
5. **Error Protocol**: `.claude/ERROR-HANDLING-PROTOCOL.md` (prevents shortcuts)
6. **Business Context**: `docs/business-context.md` (James playbook)

**Result**: Every cloud execution has **full project context** - no degradation over time!

---

## 📊 Monitoring Progress

### GitHub Actions Tab
- https://github.com/abjohnson5f/BoringBusinessesMarketing/actions
- Shows: Running workflows, completion status, logs

### Pull Requests
- Each day creates a PR automatically
- Review changes before merging
- Comment on PR to request modifications

### Issue Comments
- Claude updates issue with progress
- Links to PR when complete
- Reports blockers if encountered

---

## 🛠️ Troubleshooting

### Issue: Claude not responding
**Check**:
1. GitHub App installed? (https://github.com/settings/installations)
2. Repository in allowed list?
3. `@claude` tag in issue body?

**Fix**: Re-run `/install-github-app` in terminal

---

### Issue: GitHub Actions not triggering
**Check**:
1. Workflow file exists: `.github/workflows/claude.yml`
2. Actions enabled in repo settings
3. Issue has `@claude` mention

**Fix**: Create workflow file manually (see `CLAUDE-CODE-WEB-MOBILE-SETUP.md`)

---

### Issue: API key authentication failed
**Check**:
1. Secret `ANTHROPIC_API_KEY` exists
2. Key is valid (test at console.anthropic.com)

**Fix**: Re-add secret with correct value

---

### Issue: Day 2-5 fail because Day 1 not complete
**Cause**: Parallel execution, database not ready

**Fix**:
1. Let Day 1 PR merge first
2. Close Day 2-5 issues
3. Recreate Day 2-5 issues after Day 1 merged
4. Or: Use Sequential/Hybrid execution method

---

## ✅ Success Checklist (After All 5 Days)

**Database**:
- [ ] 8 tables exist in Neon
- [ ] Migrations 001-004 applied
- [ ] Constraints and indexes functional

**Workflows**:
- [ ] 01-apify-data-collection.json deployed
- [ ] 02-orchestrator-james-playbook.json deployed
- [ ] 03-rag-analysis-enhanced.json deployed
- [ ] 04-newsletter-generator.json deployed
- [ ] Error handlers configured

**Testing**:
- [ ] 3 hypotheses validated end-to-end
- [ ] SLA metrics documented
- [ ] All validation queries pass

**Dashboards**:
- [ ] Looker dashboard accessible
- [ ] 5 Looks configured
- [ ] Alerts configured

**Documentation**:
- [ ] 4 runbooks created
- [ ] 4 diagrams saved
- [ ] IMPLEMENTATION-COMPLETE.md exists

---

## 🎯 Expected Timeline

| Method | Days to Complete | Active Monitoring | Risk Level |
|--------|------------------|-------------------|------------|
| **Sequential** | 5 days | Low (1 PR at a time) | Low |
| **Hybrid** | 3 days | Medium (3 PRs final day) | Medium |
| **Parallel** | 1 day | High (5 PRs simultaneously) | Higher |

**Recommended**: Hybrid (Days 1-2 sequential, Days 3-5 parallel)

---

## 📞 Support

**Issue with GitHub setup**: See `.claude/CLAUDE-CODE-WEB-MOBILE-SETUP.md`
**Issue with specifications**: Review Technical Implementation Plan
**Issue with context loss**: Verify `.claude/CLAUDE.md` auto-loading
**General questions**: Tag Alex in GitHub issue comments

---

**Ready to begin?** Install GitHub App, create Day 1 issue, watch Claude build your platform!

🤖 All issues designed for Claude Code autonomous execution
