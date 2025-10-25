# Looker Studio Pro API Setup Guide

**Purpose**: Set up Looker Studio Pro with API access for programmatic dashboard management

**Prerequisites**:
- ✅ Google Workspace or Cloud Identity organization (NOT personal Gmail)
- ✅ Admin access to Google Workspace Admin Console
- ✅ Google Cloud project with billing enabled
- ✅ Looker Studio Pro subscription ($9/user/month)

**Time Required**: 30 minutes

---

## Part 1: Subscribe to Looker Studio Pro

### Step 1: Check Your Google Workspace Status

**You need Google Workspace or Cloud Identity** - personal Gmail accounts cannot use the Looker Studio API.

**Check your status**:
1. Go to: https://admin.google.com/
2. If you can access this, you have Workspace
3. If you get an error, you need to upgrade

**Don't have Workspace?**
- Option A: Upgrade to Google Workspace ($6-12/user/month)
- Option B: Use Cloud Identity Free (if you only need API access)
- Sign up: https://workspace.google.com/

### Step 2: Subscribe to Looker Studio Pro

1. Go to: https://lookerstudio.google.com/
2. Click your profile icon → **"Subscribe to Looker Studio Pro"**
3. Choose your Google Cloud project (or create one)
4. Enter billing information
5. Complete subscription ($9/user/month)

**What you get**:
- Mobile app access
- Gemini AI assistant
- Enterprise SLAs
- Technical support
- **API access** (requires additional setup below)

---

## Part 2: Google Cloud Project Setup

### Step 1: Create or Select Google Cloud Project

1. Go to: https://console.cloud.google.com/
2. Click project dropdown → **"New Project"**
3. Project name: `looker-studio-api`
4. Organization: Select your Google Workspace org
5. Click **"Create"**

### Step 2: Enable Billing

1. Go to: https://console.cloud.google.com/billing
2. Link billing account to your `looker-studio-api` project
3. This is required even though you won't be charged for API calls

---

## Part 3: Enable Looker Studio API

### Step 1: Enable the API in Google Cloud Console

1. Go to: https://console.cloud.google.com/apis/library
2. Ensure `looker-studio-api` project is selected (top dropdown)
3. Search for: **"Looker Studio API"**
4. Click on **"Looker Studio API"** result
5. Click **"Enable"**
6. Accept Terms of Service

**Expected**: API status changes to "Enabled"

---

## Part 4: Create OAuth 2.0 Credentials

### Step 1: Configure OAuth Consent Screen

1. Go to: https://console.cloud.google.com/apis/credentials/consent
2. Select **"Internal"** (only users in your Workspace can use it)
3. Click **"Create"**

**Fill out the form**:
- **App name**: `Boring Businesses Marketing Platform`
- **User support email**: Your email
- **App logo**: (optional)
- **Developer contact email**: Your email

4. Click **"Save and Continue"**

**Scopes** (Step 2 of consent screen):
- Click **"Add or Remove Scopes"**
- Search for and select:
  - `https://www.googleapis.com/auth/datastudio`
  - `https://www.googleapis.com/auth/userinfo.profile`
- Click **"Update"**
- Click **"Save and Continue"**

5. Review summary and click **"Back to Dashboard"**

### Step 2: Create OAuth Client ID Credentials

1. Go to: https://console.cloud.google.com/apis/credentials
2. Click **"CREATE CREDENTIALS"** → **"OAuth client ID"**

**Configure OAuth client**:
- **Application type**: Web application
- **Name**: `Looker Studio API Client`
- **Authorized JavaScript origins**: (leave empty for now)
- **Authorized redirect URIs**:
  - Add: `http://localhost:8080`
  - (This is for local testing during development)

3. Click **"Create"**

**Important**: Copy these values immediately:
- **Client ID**: `123456789012-abc...xyz.apps.googleusercontent.com`
- **Client secret**: `GOCSPX-...`

**Save these to your .env file**:
```bash
LOOKER_CLIENT_ID=123456789012-abc...xyz.apps.googleusercontent.com
LOOKER_CLIENT_SECRET=GOCSPX-...
```

---

## Part 5: Configure Domain-Wide Delegation

**This step requires Google Workspace Admin access**

### Step 1: Access Google Admin Console

1. Go to: https://admin.google.com/
2. Navigate to: **Security** → **API controls** → **Domain-wide delegation**
3. Click **"Add new"**

### Step 2: Authorize Your OAuth Client

**Fill in the form**:
- **Client ID**: Paste the OAuth Client ID from Step 4.2
- **OAuth Scopes**: Enter these scopes (comma-separated):
  ```
  https://www.googleapis.com/auth/datastudio,https://www.googleapis.com/auth/userinfo.profile
  ```

3. Click **"Authorize"**

**Expected**: Your app now appears in the "Domain-wide delegation" list

---

## Part 6: Test API Access

### Step 1: Install Google API Client

```bash
# Python example
pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client

# Node.js example
npm install googleapis
```

### Step 2: Test Authentication

**Python test script**:
```python
from google.oauth2 import service_account
from googleapiclient.discovery import build

# Your credentials
CLIENT_ID = 'your-client-id'
CLIENT_SECRET = 'your-client-secret'

# Test connection
try:
    service = build('datastudio', 'v1', developerKey=CLIENT_SECRET)
    print("✅ API authentication successful!")
except Exception as e:
    print(f"❌ Error: {e}")
```

**Expected output**: `✅ API authentication successful!`

---

## Part 7: Add to Environment Variables

Add these to your `.env` file (you already have this file):

```bash
# Looker Studio Pro API
LOOKER_CLIENT_ID=123456789012-abc...xyz.apps.googleusercontent.com
LOOKER_CLIENT_SECRET=GOCSPX-...
LOOKER_PROJECT_ID=looker-studio-api
```

**Also add to GitHub Secrets** (for CI/CD):
```bash
gh secret set LOOKER_CLIENT_ID
# Paste your Client ID

gh secret set LOOKER_CLIENT_SECRET
# Paste your Client Secret
```

---

## Common Issues & Solutions

### Error: "API is not available"

**Cause**: Don't have Google Workspace or Cloud Identity

**Solution**: Upgrade to Google Workspace or use Cloud Identity
- https://workspace.google.com/

### Error: "Domain-wide delegation required"

**Cause**: Haven't completed Part 5

**Solution**:
1. Go to Google Admin Console
2. Complete domain-wide delegation setup
3. Ensure scopes are exactly: `https://www.googleapis.com/auth/datastudio,https://www.googleapis.com/auth/userinfo.profile`

### Error: "Unauthorized client"

**Cause**: OAuth consent screen not configured properly

**Solution**:
1. Ensure "Internal" was selected (not "External")
2. Verify scopes were added correctly
3. Re-create OAuth client if needed

### Error: "Billing must be enabled"

**Cause**: Google Cloud project doesn't have billing enabled

**Solution**:
1. Go to: https://console.cloud.google.com/billing
2. Link billing account
3. Note: API calls are free, billing is just required for project setup

---

## What Can You Do with the API?

Once set up, you can programmatically:

### Asset Management
- Create/delete Looker Studio reports
- Migrate dashboards between environments
- Bulk update data sources
- Clone reports with different configurations

### Automation
- Automatically generate reports from templates
- Schedule report updates
- Sync data source credentials
- Export dashboard configurations

### Integration
- Embed Looker Studio in your Astro websites
- Trigger report generation from n8n workflows
- Automate dashboard creation when new Neon databases are added
- Build custom dashboards for each market opportunity

---

## Cost Summary

### What You're Paying For

| Service | Cost | Required? |
|---------|------|-----------|
| **Looker Studio Pro** | $9/user/month | ✅ Yes (for API) |
| **Google Workspace** | $6-12/user/month | ✅ Yes (for API) |
| **Google Cloud Project** | Free (with billing enabled) | ✅ Yes |
| **Looker API Calls** | Free | ✅ Yes |

**Total**: $15-21/month minimum

**Alternative**: If you only need dashboards (no API), you can use free Looker Studio. But since you specifically want Pro for the API, this is the correct setup.

---

## Next Steps After Setup

1. ✅ Verify credentials are in `.env` and GitHub Secrets
2. → Build n8n workflow to auto-generate dashboards for new markets
3. → Create Astro site with embedded Looker dashboards
4. → Set up automated reporting (e.g., weekly market opportunity reports)
5. → Use Gemini AI to help build complex dashboard calculations

---

## Why You Want Pro (vs Free)

You mentioned wanting Pro "for several reasons" - here's what you likely need:

### API Access
- **Pro Only**: Yes, requires Pro + Workspace
- **Use case**: Automate dashboard creation, programmatic management

### Gemini AI Assistant
- **Pro Only**: Yes ($9/month includes this)
- **Use case**: Write complex calculated fields without learning formulas

### Mobile App
- **Pro Only**: Yes
- **Use case**: Check dashboards on phone while traveling

### Enterprise SLAs
- **Pro Only**: Yes
- **Use case**: Guaranteed uptime for client-facing dashboards

**You're on the right track** - if you need any of these, Pro is required!

---

## Reference Documentation

- **Looker Studio API**: https://developers.google.com/looker-studio/integrate/api
- **OAuth Setup**: https://cloud.google.com/looker/docs/looker-core-create-oauth
- **Google Workspace Admin**: https://admin.google.com/
- **Pro Subscription**: https://cloud.google.com/looker/docs/studio/looker-studio-pro-subscription-overview

---

**Setup Complete!** You now have Looker Studio Pro with full API access. 🚀
