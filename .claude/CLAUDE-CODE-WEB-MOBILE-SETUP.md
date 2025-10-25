# Claude Code Web & Mobile Setup Guide

**For**: Alex Johnson - Enabling cloud-based coding across devices
**Platform**: claude.com/code (web) + iOS app (mobile)
**Benefit**: Work on hypotheses from anywhere, parallel task execution

---

## 🎯 What This Unlocks (Business Value)

### Before (CLI Only)
- ❌ Tied to your MacBook for all development work
- ❌ Sequential tasks (one agent at a time)
- ❌ Can't review/approve workflows on mobile
- ❌ Team collaboration requires sharing terminal access

### After (Web + Mobile)
- ✅ **Work from anywhere**: Browser + iOS app
- ✅ **Parallel execution**: Run multiple hypothesis validations simultaneously
- ✅ **On-the-go reviews**: Approve PRs from phone while traveling
- ✅ **Team ready**: Share GitHub access, not your laptop
- ✅ **Auto-PR creation**: Tag `@claude` in issues, get working code

**Use Case**: You're at a conference in Nashville, discover diesel mechanics as potential niche. Open Claude Code on phone, create hypothesis, trigger validation workflow, review results - all without laptop.

---

## 📋 Prerequisites (What You Need)

### Account Requirements
- [ ] Claude Pro or Max subscription (required)
- [ ] GitHub account (required for repository access)
- [ ] Anthropic API key (get from console.anthropic.com)

### Repository Setup
- [ ] GitHub repo: `abjohnson5f/OnboardIO-Dev` (or your repo)
- [ ] Repo must be public OR you have admin access for private repos
- [ ] `.claude/` directory with agents already configured ✅ (you have this!)

---

## 🚀 Setup Method 1: Quick Setup (CLI - RECOMMENDED)

**Fastest way** - Uses your existing terminal setup to configure GitHub integration.

### Step 1: Install GitHub App via CLI

1. **Open Terminal** and navigate to project:
   ```bash
   cd "/Users/alexjohnson/IDE Work/BoringBusinessesMarketing"
   ```

2. **Launch Claude Code** (if not already running):
   ```bash
   claude
   ```

3. **Run the installer**:
   ```
   /install-github-app
   ```

4. **Follow the prompts**:
   - Authenticate with GitHub (browser will open)
   - Select repository: `OnboardIO-Dev` (or your repo)
   - Grant permissions:
     - ✅ Contents (Read & Write)
     - ✅ Issues (Read & Write)
     - ✅ Pull Requests (Read & Write)
   - Claude will automatically:
     - Install the GitHub app
     - Add `ANTHROPIC_API_KEY` to repository secrets
     - Create `.github/workflows/claude.yml`

5. **Verify installation**:
   ```bash
   # Check that workflow file was created
   ls -la .github/workflows/claude.yml
   # Should show the file exists
   ```

### Step 2: Test GitHub Integration

1. **Create a test issue**:
   - Go to https://github.com/abjohnson5f/OnboardIO-Dev/issues
   - Click "New Issue"
   - Title: "Test Claude Code Integration"
   - Body: `@claude Create a hello world test file in docs/testing/`
   - Click "Submit"

2. **Watch Claude work**:
   - GitHub Actions will trigger (check "Actions" tab)
   - Claude will respond in the issue comments
   - New file will be created via PR

3. **Expected result**:
   - ✅ Claude comments on issue
   - ✅ PR created automatically
   - ✅ Changes are correct

### Step 3: Access Web Interface

1. **Go to**: https://claude.com/code
2. **Sign in** with your Claude Pro/Max account
3. **Connect repository**:
   - Click "Connect Repository"
   - Select: `OnboardIO-Dev`
   - Grant access
4. **You're ready!** Web interface now has access to your repo

### Step 4: iOS App Setup (Optional)

1. **Download**: Claude app from App Store
2. **Sign in** with same account
3. **Navigate to Code** section (beta feature)
4. **Connect repository** (same as web)

---

## 🔧 Setup Method 2: Manual Setup (If CLI Method Fails)

### Step 1: Install Claude GitHub App

1. **Go to**: https://github.com/apps/claude
2. **Click**: "Install" or "Configure"
3. **Select account**: Your personal account or organization
4. **Choose repositories**:
   - Select: "Only select repositories"
   - Pick: `OnboardIO-Dev`
5. **Review permissions** (required):
   - Contents: Read & Write
   - Issues: Read & Write
   - Pull Requests: Read & Write
6. **Click**: "Install"

### Step 2: Add GitHub Secrets

1. **Go to your repo**: https://github.com/abjohnson5f/OnboardIO-Dev/settings/secrets/actions
2. **Click**: "New repository secret"
3. **Add**:
   - **Name**: `ANTHROPIC_API_KEY`
   - **Value**: Your API key from console.anthropic.com
   - Click "Add secret"

### Step 3: Create Workflow File

1. **Create directory** (if doesn't exist):
   ```bash
   mkdir -p .github/workflows
   ```

2. **Create file**: `.github/workflows/claude.yml`

3. **Add this content**:
   ```yaml
   name: Claude Code

   permissions:
     contents: write
     pull-requests: write
     issues: write

   on:
     issue_comment:
       types: [created]
     pull_request_review_comment:
       types: [created]
     issues:
       types: [opened, assigned]

   jobs:
     claude:
       if: |
         (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
         (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
         (github.event_name == 'issues' && contains(github.event.issue.body, '@claude'))
       runs-on: ubuntu-latest
       steps:
         - uses: anthropics/claude-code-action@v1
           with:
             anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
   ```

4. **Commit and push**:
   ```bash
   git add .github/workflows/claude.yml
   git commit -m "Add Claude Code GitHub Actions integration"
   git push
   ```

### Step 4: Test (Same as Method 1, Step 2)

---

## 📱 How to Use Claude Code Web/Mobile

### Scenario 1: Create Hypothesis from Mobile

**Use Case**: You're traveling, hear about a niche opportunity

**Mobile Workflow**:
1. Open Claude iOS app
2. Navigate to: Projects → OnboardIO-Dev
3. Type: `Create a new hypothesis for [niche] in [city] based on James playbook`
4. Claude creates files, commits, opens PR
5. Review on phone, merge when ready

**Web Workflow** (same from browser):
1. Go to: claude.com/code
2. Select: OnboardIO-Dev
3. Type same prompt
4. Review changes in browser

---

### Scenario 2: Tag Claude in GitHub Issues

**Use Case**: You want workflow modifications but don't want to code

**Workflow**:
1. **Create issue** on GitHub:
   - Title: "Add error handling to Apify workflow"
   - Body:
     ```
     @claude Add retry logic to the Apify HTTP Request node in the
     data collection workflow. Should retry 3 times with exponential
     backoff on HTTP 429/500/503 errors.

     Reference: workflows/data-collection.json
     PRD: docs/prd/Boring-Businesses-Technical-Implementation-Plan.md
     ```
2. **GitHub Actions triggers**
3. **Claude responds**:
   - Comments on issue with plan
   - Creates PR with changes
   - Links PR in issue
4. **You review PR**:
   - Check changes on GitHub
   - Approve or request modifications
   - Merge when satisfied

---

### Scenario 3: PR Review Assistance

**Use Case**: You receive a PR from Vlad, want Claude to review

**Workflow**:
1. **Navigate to PR** on GitHub
2. **Add review comment**:
   ```
   @claude Review this PR for:
   - Alignment with PRD requirements
   - Security issues (credentials, SQL injection)
   - Performance concerns (query optimization)
   - Business logic correctness
   ```
3. **Claude analyzes**:
   - Reads all changed files
   - Checks against PRD, GLOSSARY.md, CLAUDE.md
   - Comments on specific lines with issues
   - Provides summary review
4. **You decide**:
   - Address Claude's feedback
   - Approve and merge
   - Request changes

---

### Scenario 4: Parallel Hypothesis Validation

**Use Case**: You want to test 3 hypotheses simultaneously

**Web Workflow**:
1. **Open**: claude.com/code
2. **Create 3 separate tasks** (tab for each):
   - Tab 1: "Validate hypothesis: Charlotte luxury tax"
   - Tab 2: "Validate hypothesis: Nashville diesel mechanics"
   - Tab 3: "Validate hypothesis: Denver exotic car wraps"
3. **All run in parallel** (cloud sandboxes)
4. **Review results** as they complete
5. **Merge best hypotheses** first

---

## 🔐 Security Model (How It Works)

### Isolated Sandboxes
- **Each task** runs in separate container
- **Network restrictions**: Can only access authorized repos
- **Filesystem isolation**: No cross-task access
- **Automatic cleanup**: Containers destroyed after task

### Git Proxy Service
- **Claude never has direct repo access**
- **All git operations** go through secure proxy
- **Authorization checked** on every operation
- **Audit log** of all repo interactions

### Credential Management
- **API keys** stored in GitHub Secrets (encrypted)
- **Never visible** in logs or workflow files
- **Scoped access**: Only to specified repositories
- **Rotatable**: Change keys without workflow edits

---

## 💰 Cost Considerations

### GitHub Actions Minutes
- **Free tier**: 2,000 minutes/month (personal accounts)
- **Claude Code usage**: ~5-15 minutes per task
- **Your capacity**: 130-400 tasks/month on free tier
- **Upgrade**: If exceeded, GitHub charges $0.008/minute

**Estimation for Boring Businesses**:
- 5 hypotheses/month × 10 min/hypothesis = 50 min/month
- Well within free tier ✅

### Anthropic API Costs
- **Each Claude interaction** consumes tokens
- **Cost**: ~$0.10-0.50 per hypothesis validation
- **Monthly**: 5 hypotheses × $0.30 avg = $1.50/month
- **Volume discount**: Available at higher usage

**Combined monthly cost**: ~$1.50 (mostly API, GitHub free tier)

---

## 🎯 Best Practices

### 1. Use CLAUDE.md for Standards

**Your `.claude/CLAUDE.md` is already configured!**

When Claude works on web/mobile, it automatically reads:
- Business context (James playbook)
- Glossary (terminology standards)
- Agent configurations
- Error-handling protocol

**No extra configuration needed** - your setup already follows best practices!

---

### 2. Issue Templates for Consistency

**Create**: `.github/ISSUE_TEMPLATE/hypothesis-validation.md`

```markdown
---
name: Hypothesis Validation
about: Request Claude to validate a new market hypothesis
title: 'Validate: [NICHE] in [CITY]'
labels: hypothesis, automation
assignees: ''
---

## Hypothesis Details

**Niche**: [e.g., luxury tax advisory]
**City**: [e.g., Charlotte]
**State**: [e.g., NC]

**Rationale**:
[Why this niche/city combination looks promising]

## Validation Request

@claude Run the orchestrator workflow to validate this hypothesis:

1. Run manual Apify crawl (if not done): [Dataset ID or "NEEDED"]
2. Process via orchestrator workflow
3. Report metrics against PRD thresholds:
   - Review Velocity (target: ≥10)
   - Provider Density (target: ≤12)
   - Incumbent Ratio (target: ≤0.35)
   - Sentiment Balance (target: ≤-10%)
   - High-Ticket Confidence (target: ≥0.7)

4. Recommend: Validated / Needs Review / Discarded

## Reference
- PRD Section 6.2: Orchestrator Workflow
- PRD Table 1: Thresholds
```

---

### 3. PR Review Checklist

**Create**: `.github/pull_request_template.md`

```markdown
## Changes Summary
[Brief description of changes]

## PRD Alignment
- [ ] Meets requirements from PRD Section: ___
- [ ] Uses terminology from GLOSSARY.md
- [ ] Follows James playbook principles

## Testing
- [ ] Manual testing completed
- [ ] Automated tests pass
- [ ] Performance meets SLA targets

## Business Impact
**Revenue Impact**: [$ value or "None"]
**Hypothesis Processing**: [Affects validation? Yes/No]

## Review Request
@claude Review for:
- PRD compliance
- Security issues
- Performance concerns
- Business logic correctness
```

---

## 🐛 Troubleshooting

### Issue: Claude not responding to @claude tags

**Diagnosis**:
```bash
# Check if GitHub App is installed
# Go to: https://github.com/settings/installations
# Look for: "Claude" app
```

**Fix**:
- If not installed: Run `/install-github-app` in CLI
- If installed but not working: Check repository is in allowed list

---

### Issue: GitHub Actions not triggering

**Diagnosis**:
```bash
# Check workflow file exists
ls -la .github/workflows/claude.yml

# Check GitHub Actions are enabled
# Go to: Repo Settings → Actions → General
# Ensure: "Allow all actions and reusable workflows" is selected
```

**Fix**:
- Create workflow file if missing (see Manual Setup)
- Enable Actions in repo settings

---

### Issue: API key authentication failed

**Diagnosis**:
```bash
# Check secret exists
# Go to: Repo Settings → Secrets and variables → Actions
# Look for: ANTHROPIC_API_KEY
```

**Fix**:
1. Verify API key is valid: https://console.anthropic.com
2. Re-add secret with correct value
3. Re-run workflow

---

## 📊 Comparison: CLI vs Web/Mobile

| Feature | CLI (Local) | Web/Mobile (Cloud) |
|---------|-------------|---------------------|
| **Access** | MacBook only | Any device, anywhere |
| **Parallelism** | Limited (local resources) | Up to 10 tasks simultaneously |
| **Setup** | Terminal required | Browser or iOS app |
| **Team collaboration** | Share terminal access ❌ | GitHub-based ✅ |
| **Auto-PR creation** | Manual | Tag `@claude` in issues |
| **Offline work** | Yes ✅ | No (requires internet) |
| **Cost** | Free (local compute) | ~$1.50/month (API + GitHub) |
| **Security** | Local files | Isolated sandboxes |
| **Best for** | Deep coding sessions | Quick reviews, mobile work, parallel tasks |

**Recommendation**: **Use both!**
- CLI for deep implementation work (Day 1-5 sprint)
- Web/Mobile for reviews, monitoring, mobile hypothesis creation

---

## ✅ Setup Verification Checklist

Before considering setup complete:

### GitHub Integration
- [ ] Claude GitHub App installed
- [ ] Repository access granted (`OnboardIO-Dev`)
- [ ] Workflow file exists (`.github/workflows/claude.yml`)
- [ ] `ANTHROPIC_API_KEY` secret configured
- [ ] Test issue created and Claude responded

### Web Access
- [ ] Logged into claude.com/code
- [ ] Repository connected
- [ ] Can create new task
- [ ] Task executed successfully

### Mobile Access (Optional)
- [ ] Claude iOS app installed
- [ ] Signed in
- [ ] Can view repository
- [ ] Can create tasks

### Testing
- [ ] Created test issue with `@claude` tag
- [ ] GitHub Actions triggered
- [ ] Claude created PR or comment
- [ ] Changes were correct

---

## 🎓 Next Steps After Setup

**Immediate**:
1. Create 3-5 issue templates for common tasks
2. Configure PR template with PRD checklist
3. Test parallel execution (3 hypotheses simultaneously)

**First Week**:
1. Use web interface for all hypothesis reviews
2. Test mobile app while away from desk
3. Refine `@claude` prompts based on results

**First Month**:
1. Evaluate cost vs value (should be ~$1.50/month)
2. Train Vlad on GitHub issue-based workflow
3. Consider upgrading to GitHub Team if hitting minute limits

---

## 📞 Support Resources

| Issue Type | Resource |
|------------|----------|
| GitHub Actions | https://docs.github.com/en/actions |
| Claude Code Action | https://github.com/anthropics/claude-code-action |
| API Keys | https://console.anthropic.com |
| Billing | https://claude.com/account/billing |
| General Support | https://support.anthropic.com |

---

**Setup Complete?** 🎉

You can now:
- Tag `@claude` in GitHub issues for automated implementation
- Work from any device (web browser or iOS)
- Run 3+ hypothesis validations in parallel
- Review and approve workflows from your phone

**Your Boring Businesses platform is now accessible from anywhere!**
