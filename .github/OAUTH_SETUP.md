# Claude MAX OAuth Setup for GitHub Actions

**Purpose**: Configure GitHub Actions to use your Claude MAX subscription instead of separate API billing.

**Official Guidance**: "Claude Max subscriptions are intended for a single user, and that applies here as well." — Anthropic (July 2025)

**Cost Savings**: Eliminates ~$7.50-$37.50/month in API costs by using your existing $200/month MAX subscription.

---

## Prerequisites

- ✅ Active Claude MAX subscription ($200/month)
- ✅ Claude Code installed locally (`claude` command available)
- ✅ Single-user personal repository (you are the only one using `@claude`)
- ✅ Admin access to this GitHub repository

---

## Step-by-Step Setup

### 1. Update Claude Code (Local Terminal)

```bash
# Ensure you have the latest version with OAuth support
claude update
```

**Expected Output**:
```
✓ Claude Code updated to latest version
```

---

### 2. Generate OAuth Token (Local Terminal)

```bash
# This generates a token linked to your MAX subscription
claude setup-token
```

**Expected Output**:
```
✓ OAuth token generated successfully
Copy this token to your GitHub repository secrets as CLAUDE_CODE_OAUTH_TOKEN:

eyJhbGc... [long token string] ...xyz123
```

**⚠️ IMPORTANT**: Copy the entire token string (it's very long). You'll need it in the next step.

---

### 3. Add Token to GitHub Secrets

#### Via GitHub Web Interface:

1. Go to your repository: https://github.com/abjohnson5f/The-Boring-Marketing-Platform
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Configure:
   - **Name**: `CLAUDE_CODE_OAUTH_TOKEN`
   - **Value**: Paste the token from step 2
5. Click **Add secret**

#### Via GitHub CLI (Alternative):

```bash
# Navigate to your repository
cd /Users/alexjohnson/IDE\ Work/BoringBusinessesMarketing

# Add the secret (paste token when prompted)
gh secret set CLAUDE_CODE_OAUTH_TOKEN
```

**Expected Output**:
```
✓ Set secret CLAUDE_CODE_OAUTH_TOKEN for abjohnson5f/The-Boring-Marketing-Platform
```

---

### 4. Verify Secret Configuration

```bash
# List all repository secrets
gh secret list
```

**Expected Output**:
```
CLAUDE_CODE_OAUTH_TOKEN  Updated 2025-10-25
ANTHROPIC_API_KEY        Updated 2025-10-24  (can be deleted)
NEON_CONNECTION_STRING   Updated 2025-10-24
```

---

### 5. Remove Old API Key (Optional Cleanup)

Since you're now using OAuth, you can remove the old API key secret:

```bash
# Delete the API key secret (no longer needed)
gh secret delete ANTHROPIC_API_KEY
```

**Why delete it?**
- Reduces confusion (only one authentication method)
- Eliminates risk of accidentally using paid API
- Cleaner secrets management

---

### 6. Test OAuth Authentication

Create a test issue to verify OAuth is working:

```bash
# Create a test issue
gh issue create \
  --title "Test OAuth Authentication" \
  --body "@claude Please confirm you're using OAuth authentication from my Claude MAX subscription and not the API."
```

**Expected Behavior**:
1. GitHub Action triggers on the `@claude` mention
2. Claude responds using your MAX subscription (not API)
3. No API charges appear in your Anthropic console
4. Response appears in the issue comment

---

## Workflow Configuration (Already Updated)

Your workflow file (`.github/workflows/claude.yml`) has been updated to use OAuth:

```yaml
- name: Run Claude Code
  uses: anthropics/claude-code-action@v1
  with:
    # Using Claude MAX OAuth (single-user personal repo)
    claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

**Key Changes**:
- ❌ Removed: `anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}`
- ✅ Added: `claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}`
- ✅ Added: `github_token: ${{ secrets.GITHUB_TOKEN }}`

---

## Verification Checklist

After setup, verify the following:

- [ ] `claude update` shows latest version
- [ ] `claude setup-token` generated a token successfully
- [ ] `gh secret list` shows `CLAUDE_CODE_OAUTH_TOKEN`
- [ ] Workflow file uses `claude_code_oauth_token` parameter
- [ ] Test issue with `@claude` triggers successfully
- [ ] No API charges appear in Anthropic console

---

## Troubleshooting

### Error: "OAuth token invalid or expired"

**Solution**:
```bash
# Regenerate token
claude setup-token

# Update GitHub secret with new token
gh secret set CLAUDE_CODE_OAUTH_TOKEN
```

### Error: "Action requires anthropic_api_key or claude_code_oauth_token"

**Cause**: GitHub secret not properly configured.

**Solution**:
```bash
# Verify secret exists
gh secret list | grep CLAUDE_CODE_OAUTH_TOKEN

# If missing, add it
gh secret set CLAUDE_CODE_OAUTH_TOKEN
```

### Workflow uses API instead of OAuth

**Cause**: Workflow still configured with `anthropic_api_key`.

**Solution**:
1. Check `.github/workflows/claude.yml`
2. Ensure it uses `claude_code_oauth_token` (not `anthropic_api_key`)
3. Commit and push changes

### Token expires periodically

**Cause**: OAuth tokens have expiration dates for security.

**Solution**:
```bash
# Regenerate token when it expires (you'll get an error notification)
claude setup-token

# Update GitHub secret
gh secret set CLAUDE_CODE_OAUTH_TOKEN
```

---

## Cost Comparison

### Before OAuth (Using API)
- **Claude MAX**: $200/month (local development only)
- **Anthropic API**: ~$0.75/run × 10-50 runs/month = **$7.50-$37.50/month**
- **Total**: $207.50-$237.50/month

### After OAuth (Using MAX for Everything)
- **Claude MAX**: $200/month (local + GitHub Actions)
- **Anthropic API**: $0.00/month
- **Total**: **$200/month**

**Savings**: **$7.50-$37.50/month** (or **$90-$450/year**)

---

## Additional Notes

### Single-User Restriction

This OAuth setup only works for **single-user repositories**. If you add collaborators who will also use `@claude`:
- You'll need to switch back to API key authentication
- Each user's `@claude` usage will bill to the API key
- Consider team-level authentication options

### Security Best Practices

- **Rotate tokens regularly** (every 90 days recommended)
- **Never commit tokens** to git (always use GitHub Secrets)
- **Monitor usage** in your Claude MAX dashboard
- **Revoke tokens** immediately if compromised

### Official Documentation

- [Claude Code GitHub Actions](https://docs.claude.com/en/docs/claude-code/github-actions)
- [OAuth Authentication Guide](https://wain.tokyo/en/claude-code-github-actions-max-support-8NB583zS/)

---

**Setup Complete! 🎉**

You can now use `@claude` in GitHub issues and pull requests without incurring separate API charges.
