# Neon PostgreSQL Database Setup Guide

**Purpose**: Configure Neon Postgres connection for local development and GitHub Actions

**Time Required**: 5 minutes

**Prerequisites**: Neon account with project created

---

## Quick Start (TL;DR)

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Get connection string from Neon dashboard (see below)
# 3. Paste into .env under NEON_CONNECTION_STRING
# 4. Test connection
source scripts/load-env.sh
psql "$NEON_CONNECTION_STRING" -c "SELECT version();"

# 5. Update GitHub Secret (if different)
gh secret set NEON_CONNECTION_STRING
```

---

## Detailed Setup Instructions

### Step 1: Access Your Neon Dashboard

1. Go to: https://console.neon.tech/app/projects
2. Select your project (or create one if needed)
3. You should see a **"Connect to your database"** dialog

### Step 2: Get Your Connection String

In the Neon dashboard connection dialog:

1. **Branch**: Select `development` (should show "DEFAULT" badge)
2. **Compute**: Select `Primary` (should show "IDLE" when not in use)
3. **Database**: Select `neondb` (or your database name)
4. **Role**: Select `neondb_owner` (or your role name)
5. **Connection Format**: Click the dropdown and select **`psql`**
6. **Tab**: Click on **"connection string"** tab (NOT "passwordless auth")

You should see something like:

```
postgresql://neondb_owner:npg_XnZwzfpu36Tb6ep-soft-band-ae2scn9v@ep-soft-band-ae2scn9v.c-2.us-east-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

### Step 3: Two Connection Methods

#### Method A: Connection String (Recommended for Automation)

**Use this for**: GitHub Actions, CI/CD, scripts

**Format**:
```
postgresql://[user]:[password]@[host]/[database]?sslmode=require&channel_binding=require
```

**Pros**:
- ✅ Works in GitHub Actions
- ✅ Works with all PostgreSQL clients
- ✅ Single environment variable
- ✅ Easy to rotate credentials

**Cons**:
- ⚠️ Contains password (must keep secret)

#### Method B: Passwordless Auth (CLI Only)

**Use this for**: Quick local testing via psql

**Format**:
```bash
psql -h pg.neon.tech
```

**Pros**:
- ✅ No password to manage
- ✅ Uses Neon's OAuth

**Cons**:
- ❌ Only works with `psql` command
- ❌ Doesn't work in GitHub Actions
- ❌ Doesn't work with most database clients
- ❌ Requires Neon CLI setup

**Recommendation**: **Use Method A (Connection String)** for this project since we use GitHub Actions.

---

## Local Development Setup

### 1. Create Local .env File

```bash
# From project root
cd ~/IDE\ Work/BoringBusinessesMarketing

# Copy template
cp .env.example .env
```

### 2. Edit .env File

Open `.env` in your editor and paste your connection string:

```bash
# Option 1: Using cursor/code
cursor .env

# Option 2: Using vim
vim .env

# Option 3: Using nano
nano .env
```

Find this line:
```bash
NEON_CONNECTION_STRING=
```

Paste your full connection string after the `=`:
```bash
NEON_CONNECTION_STRING=postgresql://neondb_owner:npg_XnZwzfpu36Tb6ep-soft-band-ae2scn9v@ep-soft-band-ae2scn9v.c-2.us-east-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

**Save and close** the file.

### 3. Load Environment Variables

```bash
# Load .env into your shell
source scripts/load-env.sh

# Verify it worked
echo $NEON_CONNECTION_STRING
```

**Expected output**: Your full connection string

### 4. Test Database Connection

```bash
# Test connection with simple query
psql "$NEON_CONNECTION_STRING" -c "SELECT version();"
```

**Expected output**:
```
                                                 version
---------------------------------------------------------------------------------------------------------
 PostgreSQL 17.0 on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit
(1 row)
```

✅ **If you see this**, your local connection is working!

---

## GitHub Actions Setup

Your GitHub Actions workflow needs the same connection string in **GitHub Secrets**.

### Verify Current Secret

```bash
# Check if secret exists
gh secret list | grep NEON_CONNECTION_STRING
```

**Expected output**:
```
NEON_CONNECTION_STRING  Updated 2025-10-25
```

### Update GitHub Secret (If Needed)

If the secret is old or you got a new connection string:

```bash
# Set/update the secret
gh secret set NEON_CONNECTION_STRING
```

**Paste your connection string when prompted** and press Enter.

**Verify update**:
```bash
gh secret list | grep NEON_CONNECTION_STRING
```

You should see today's date in the "Updated" column.

---

## Running Migrations

Once your connection is configured, run the Day 1 migrations:

### Local Execution

```bash
# Load environment
source scripts/load-env.sh

# Run migrations
./scripts/run-migrations.sh
```

### Via GitHub Actions

Create an issue with:
```markdown
@claude Please run the Day 1 database migrations using the script at scripts/run-migrations.sh
```

---

## Troubleshooting

### Error: "connection to server failed"

**Possible Causes**:
1. Wrong connection string
2. Neon compute is scaled down to zero
3. Network/firewall issue

**Solution**:
```bash
# 1. Verify connection string is correct
echo "$NEON_CONNECTION_STRING"

# 2. Wake up Neon compute (visit dashboard)
# Go to: https://console.neon.tech/app/projects
# Your compute should auto-start

# 3. Test with verbose output
psql "$NEON_CONNECTION_STRING" -c "SELECT 1;" -v ON_ERROR_STOP=1
```

### Error: "FATAL: password authentication failed"

**Cause**: Connection string has wrong/expired password

**Solution**:
1. Go to Neon dashboard: https://console.neon.tech
2. Click "Reset password" (top right in connection dialog)
3. Copy the **new** connection string
4. Update `.env` and GitHub Secret

```bash
# Update local
vim .env  # paste new connection string

# Update GitHub
gh secret set NEON_CONNECTION_STRING  # paste new connection string
```

### Error: "SSL connection is required"

**Cause**: Missing `?sslmode=require` in connection string

**Solution**: Ensure your connection string ends with:
```
?sslmode=require&channel_binding=require
```

### Error: "database 'neondb' does not exist"

**Cause**: Wrong database name in connection string

**Solution**:
1. Check your Neon dashboard for actual database name
2. Update the database name in your connection string:
   ```
   postgresql://user:pass@host/[YOUR_DB_NAME]?sslmode=require
   ```

### Environment variable not loading

**Cause**: `.env` file not sourced

**Solution**:
```bash
# Always source before running scripts
source scripts/load-env.sh

# Verify
echo $NEON_CONNECTION_STRING

# If empty, check .env exists
ls -la .env
```

---

## Connection String Anatomy

Understanding the parts of your connection string:

```
postgresql://neondb_owner:npg_XnZwzfpu36Tb6ep-soft-band-ae2scn9v@ep-soft-band-ae2scn9v.c-2.us-east-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

Breaking it down:
- **Protocol**: `postgresql://`
- **User**: `neondb_owner`
- **Password**: `npg_XnZwzfpu36Tb6ep-soft-band-ae2scn9v`
- **Host**: `ep-soft-band-ae2scn9v.c-2.us-east-2.aws.neon.tech`
- **Database**: `neondb`
- **SSL Mode**: `sslmode=require` (mandatory for Neon)
- **Channel Binding**: `channel_binding=require` (extra security)

**Each part must be correct** for connection to work.

---

## Security Best Practices

### ✅ DO:
- Store connection string in `.env` (git-ignored)
- Use GitHub Secrets for CI/CD
- Rotate passwords every 90 days
- Use separate dev/prod databases

### ❌ DON'T:
- Commit `.env` to git
- Share connection strings in Slack/email
- Use production DB for testing
- Hardcode credentials in code

---

## Neon-Specific Features

### Auto-Scaling

Neon computes auto-scale to zero when idle:
- **Idle**: Compute stopped, no charges
- **Active**: Auto-starts on first query (<1 second)
- **Benefit**: Save money on dev databases

### Branching

Create database branches like git branches:
```bash
# Via Neon dashboard
1. Go to project
2. Click "Branches"
3. Create new branch from "development"
4. Get separate connection string
```

Use cases:
- Testing migrations before prod
- Separate feature branches
- CI/CD preview environments

---

## Next Steps

After setup:
1. ✅ Local `.env` configured and tested
2. ✅ GitHub Secret updated
3. ✅ Connection verified
4. → **Run Day 1 migrations** (see docs/runbooks/database-setup.md)
5. → **Validate schema** with test script (sql/tests/001_constraint_validation.sql)

---

## Additional Resources

- **Neon Documentation**: https://neon.tech/docs
- **Connection Pooling**: https://neon.tech/docs/connect/connection-pooling
- **Neon Branching**: https://neon.tech/docs/guides/branching
- **GitHub Actions with Neon**: https://neon.tech/docs/guides/github-actions

---

**Setup Complete! 🎉**

Your Neon database is now connected for both local development and GitHub Actions.
