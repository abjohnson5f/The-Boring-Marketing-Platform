# Neon GitHub Actions Setup Guide

**Purpose**: Configure Neon's official GitHub Actions workflow for automatic database branching per pull request

**What this does**:
- ✅ Creates a fresh Neon database branch for each PR
- ✅ Runs migrations automatically on the preview branch
- ✅ Posts schema diff comments to PR
- ✅ Deletes preview branch when PR closes
- ✅ Branch expires automatically after 2 weeks

**Time Required**: 10 minutes

---

## Step 1: Get Your Neon Project ID

### Via Neon Dashboard

1. Go to: https://console.neon.tech/app/projects
2. Select your project
3. Click **Settings** in the sidebar
4. Look for **Project ID** (format: `something-like-ep-soft-band-ae2scn9v`)
5. Copy it

### Via URL

Your Project ID is in the URL when viewing your Neon project:
```
https://console.neon.tech/app/projects/[YOUR_PROJECT_ID]/branches
```

---

## Step 2: Get Your Neon API Key

1. Go to: https://console.neon.tech/app/settings/api-keys
2. Click **"Create new API key"**
3. Name: `GitHub Actions`
4. Click **"Create"**
5. **Copy the API key immediately** (you won't see it again!)

**Format**: `neon_api_...` (long string)

---

## Step 3: Add NEON_PROJECT_ID as GitHub Variable

GitHub Variables are for non-secret configuration values.

### Via GitHub CLI

```bash
cd ~/IDE\ Work/BoringBusinessesMarketing

# Add the variable (paste your Project ID when prompted)
gh variable set NEON_PROJECT_ID
```

### Via GitHub Web UI

1. Go to: https://github.com/abjohnson5f/The-Boring-Marketing-Platform/settings/variables/actions
2. Click **"New repository variable"**
3. Name: `NEON_PROJECT_ID`
4. Value: Paste your Project ID
5. Click **"Add variable"**

---

## Step 4: Add NEON_API_KEY as GitHub Secret

GitHub Secrets are for sensitive credentials.

### Via GitHub CLI

```bash
cd ~/IDE\ Work/BoringBusinessesMarketing

# Add the secret (paste your API key when prompted)
gh secret set NEON_API_KEY
```

### Via GitHub Web UI

1. Go to: https://github.com/abjohnson5f/The-Boring-Marketing-Platform/settings/secrets/actions
2. Click **"New repository secret"**
3. Name: `NEON_API_KEY`
4. Value: Paste your API key
5. Click **"Add secret"**

---

## Step 5: Verify Configuration

```bash
# Check that variable exists
gh variable list | grep NEON_PROJECT_ID

# Check that secret exists
gh secret list | grep NEON_API_KEY
```

**Expected output**:
```
NEON_PROJECT_ID     Updated 2025-10-25
NEON_API_KEY        Updated 2025-10-25
```

---

## Step 6: Test the Workflow

### Create a Test Pull Request

```bash
cd ~/IDE\ Work/BoringBusinessesMarketing

# Create a test branch
git checkout -b test-neon-workflow

# Make a small change
echo "# Test" >> README.md
git add README.md
git commit -m "Test: Verify Neon workflow creates preview branch"
git push origin test-neon-workflow

# Create PR
gh pr create --title "Test: Neon Preview Branch Workflow" --body "Testing automatic Neon branch creation and migration execution"
```

### What Should Happen

1. **GitHub Action triggers** when PR is created
2. **Neon branch created**: `preview/pr-[number]-test-neon-workflow`
3. **Migrations run automatically**:
   - `001_create_orchestrator_log.sql`
   - `002_opportunity_tables.sql`
   - `003_threshold_seed.sql`
   - `004_runtime_logging.sql`
4. **Validation tests run**: `001_constraint_validation.sql`
5. **Schema diff posted** as PR comment
6. **When you close PR**: Branch automatically deleted

### View the Results

1. **GitHub Actions**: https://github.com/abjohnson5f/The-Boring-Marketing-Platform/actions
2. **Neon Branches**: https://console.neon.tech/app/projects/[YOUR_PROJECT_ID]/branches
3. **PR Comment**: Check your PR for schema diff

---

## How It Works

`★ Insight ─────────────────────────────────────`
**Neon's branching model treats databases like Git branches:**

- **Main branch**: Your production database
- **PR preview branches**: Isolated copies for testing
- **Automatic cleanup**: Branches deleted when PR closes
- **Cost-free testing**: Preview branches don't increase costs during development
- **Schema validation**: Diff shows exactly what changed

This lets you test database migrations safely before merging to production!
`─────────────────────────────────────────────────`

### Workflow Triggers

**Creates branch when**:
- PR opened
- PR reopened
- New commits pushed to PR

**Deletes branch when**:
- PR closed (merged or not)

**Branch expires**:
- Automatically after 2 weeks (configurable)

### What Runs on Each Branch

1. **Checkout repository** - Get latest code
2. **Create Neon branch** - Fresh database copy
3. **Run migrations** - Apply all 4 Day 1 migrations
4. **Run validation tests** - Verify schema is correct
5. **Post schema diff** - Comment on PR with changes

---

## Troubleshooting

### Error: "Project ID not found"

**Cause**: Wrong project ID format or typo

**Solution**:
```bash
# Verify your project ID
gh variable list | grep NEON_PROJECT_ID

# Update if wrong
gh variable set NEON_PROJECT_ID
```

### Error: "API key invalid"

**Cause**: Wrong API key or expired

**Solution**:
1. Go to https://console.neon.tech/app/settings/api-keys
2. Delete old key
3. Create new key
4. Update secret:
   ```bash
   gh secret set NEON_API_KEY
   ```

### Error: "Branch already exists"

**Cause**: Previous test didn't clean up

**Solution**:
1. Go to Neon dashboard: https://console.neon.tech/app/projects
2. Navigate to **Branches**
3. Delete the preview branch manually
4. Re-run the workflow

### Workflow doesn't trigger

**Cause**: File in wrong location or syntax error

**Solution**:
```bash
# Verify file exists
ls -la .github/workflows/neon-branch-per-pr.yml

# Check syntax
cat .github/workflows/neon-branch-per-pr.yml | head -20
```

### Migrations fail

**Cause**: SQL files have errors or missing

**Solution**:
```bash
# Verify all migration files exist
ls -la sql/00*.sql

# Check for syntax errors
cat sql/001_create_orchestrator_log.sql
```

---

## Configuration Options

### Change Branch Expiration Time

Edit `.github/workflows/neon-branch-per-pr.yml`:

```yaml
# Default: 14 days
run: echo "EXPIRES_AT=$(date -u --date '+14 days' +'%Y-%m-%dT%H:%M:%SZ')" >> "$GITHUB_ENV"

# Change to 7 days
run: echo "EXPIRES_AT=$(date -u --date '+7 days' +'%Y-%m-%dT%H:%M:%SZ')" >> "$GITHUB_ENV"

# Change to 30 days
run: echo "EXPIRES_AT=$(date -u --date '+30 days' +'%Y-%m-%dT%H:%M:%SZ')" >> "$GITHUB_ENV"
```

### Add More Migrations

Edit the "Run Database Migrations" step:

```yaml
- name: Run Database Migrations
  run: |
    # Existing migrations
    psql "${{ steps.create_neon_branch.outputs.db_url_with_pooler }}" -f sql/001_create_orchestrator_log.sql
    psql "${{ steps.create_neon_branch.outputs.db_url_with_pooler }}" -f sql/002_opportunity_tables.sql
    psql "${{ steps.create_neon_branch.outputs.db_url_with_pooler }}" -f sql/003_threshold_seed.sql
    psql "${{ steps.create_neon_branch.outputs.db_url_with_pooler }}" -f sql/004_runtime_logging.sql

    # Add new Day 2 migrations
    psql "${{ steps.create_neon_branch.outputs.db_url_with_pooler }}" -f sql/005_new_migration.sql
```

### Disable Schema Diff Comments

Comment out or remove this step:

```yaml
# - name: Post Schema Diff Comment to PR
#   uses: neondatabase/schema-diff-action@v1
#   with:
#     project_id: ${{ vars.NEON_PROJECT_ID }}
#     compare_branch: preview/pr-${{ github.event.number }}-${{ needs.setup.outputs.branch }}
#     api_key: ${{ secrets.NEON_API_KEY }}
```

---

## Benefits

### For Development

- ✅ **Safe testing**: Changes isolated in preview branch
- ✅ **Fast feedback**: See migration results in minutes
- ✅ **Schema validation**: Diff shows exactly what changed
- ✅ **Automatic cleanup**: No manual branch management

### For Production

- ✅ **Confidence**: Migrations tested before merge
- ✅ **Rollback safety**: Preview branch shows what will happen
- ✅ **Team collaboration**: Everyone sees schema changes in PR
- ✅ **Audit trail**: GitHub Actions logs all migrations

---

## Cost Implications

**Neon branching is FREE** during development:
- Preview branches don't count toward compute limits
- Only charged for active compute time
- Automatic cleanup prevents waste
- 2-week expiration prevents forgotten branches

**Pro tip**: Neon's branch-per-PR workflow is designed to be cost-free for development!

---

## Next Steps After Setup

1. ✅ Create test PR to verify workflow
2. ✅ Check Neon dashboard for new preview branch
3. ✅ Verify migrations ran successfully (check Actions logs)
4. ✅ Review schema diff comment on PR
5. → Close test PR (branch should auto-delete)
6. → Start using this for all future database changes!

---

## Reference Documentation

- **Neon Branching Guide**: https://neon.tech/docs/guides/branching
- **GitHub Actions Integration**: https://neon.tech/docs/guides/github-actions
- **Create Branch Action**: https://github.com/neondatabase/create-branch-action
- **Delete Branch Action**: https://github.com/neondatabase/delete-branch-action
- **Schema Diff Action**: https://github.com/neondatabase/schema-diff-action

---

**Setup Complete!** 🎉

You now have automated database branching for every pull request using Neon's official workflow.
