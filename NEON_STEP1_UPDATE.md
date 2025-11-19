# Updated Step 1: Create Database Resource (Neon PostgreSQL)

**⚠️ IMPORTANT:** Retool doesn't have a direct "SQLite" resource option. We'll use Neon PostgreSQL instead.

## Your Neon Connection Details

- **Host:** `ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech`
- **Port:** `5432`
- **Database:** `neondb`
- **Username:** `neondb_owner`
- **SSL Required:** Yes

## Step 1A: Migrate SQLite Database to Neon

Before connecting Retool, you need to migrate your SQLite database to Neon.

### Option 1: Using Python Script (Recommended)

```bash
# Navigate to your project directory
cd "/Users/alexjohnson/IDE Work/govspend-faulconer-market-intelligence"

# Run the migration script
python3 /workspace/scripts/migrate-sqlite-to-neon.py \
  "./data/strategic_alignment.db"
```

The script will:
1. Export your SQLite database to PostgreSQL-compatible SQL
2. Prompt you for your Neon password
3. Import the data to Neon

### Option 2: Using Bash Script

```bash
# Set your Neon password as environment variable (optional)
export NEON_PASSWORD="your-password-here"

# Run the migration
/workspace/scripts/migrate-to-neon.sh \
  "/Users/alexjohnson/IDE Work/govspend-faulconer-market-intelligence/data/strategic_alignment.db"
```

### Option 3: Manual Migration

If you prefer to do it manually:

```bash
# 1. Export SQLite to SQL
sqlite3 "/Users/alexjohnson/IDE Work/govspend-faulconer-market-intelligence/data/strategic_alignment.db" .dump > strategic_alignment.sql

# 2. Convert SQLite syntax to PostgreSQL (basic conversion)
sed -i.bak \
  -e 's/INTEGER PRIMARY KEY AUTOINCREMENT/SERIAL PRIMARY KEY/g' \
  -e 's/DATETIME/TIMESTAMP/g' \
  -e '/^PRAGMA/d' \
  -e '/^BEGIN TRANSACTION/d' \
  -e '/^COMMIT/d' \
  strategic_alignment.sql

# 3. Import to Neon (you'll be prompted for password)
psql "postgresql://neondb_owner:YOUR_PASSWORD@ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech/neondb?sslmode=require" < strategic_alignment.sql
```

## Step 1B: Verify Migration

After migration, verify your tables exist:

```bash
psql "postgresql://neondb_owner:YOUR_PASSWORD@ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech/neondb?sslmode=require" -c "\dt"
```

You should see tables like:
- `opportunities_enriched`
- `smart_summaries`
- `faulconer_objectives`
- `agency_strategic_priorities`
- `relationship_graph`
- `compliance_readiness`

## Step 1C: Configure Retool Resource

1. **In Retool:**
   - Open Retool → Resources → Add Resource
   - Select **"PostgreSQL"** (NOT SQLite - that option doesn't exist)

2. **Enter your Neon connection details:**
   - **Name:** `strategic_db`
   - **Host:** `ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech`
   - **Port:** `5432`
   - **Database name:** `neondb`
   - **Database username:** `neondb_owner`
   - **Database password:** `[your Neon password]`
   - **Use SSL:** ✓ **CHECK THIS BOX** (Neon requires SSL)

3. **Test Connection:**
   - Click "Test Connection"
   - You should see: "Connection successful" ✅

4. **Save the resource**

## Step 1D: Test Query in Retool

Create a test query to verify everything works:

1. In Retool, go to the Query editor
2. Create a new query named `test_tables`
3. Use this SQL:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public'
   ORDER BY table_name;
   ```
4. Run it - you should see all your migrated tables

## Troubleshooting

### "Connection failed" error
- ✅ Verify SSL checkbox is checked in Retool
- ✅ Double-check your password
- ✅ Ensure your Neon database is active (not paused) in Neon dashboard
- ✅ Check that the host address is correct

### "Table does not exist" error
- ✅ Run the migration script again
- ✅ Check Neon dashboard to verify tables were created
- ✅ Verify you're connected to the correct database (`neondb`)

### "SSL required" error
- ✅ Enable "Use SSL" checkbox in Retool resource settings
- ✅ Neon requires SSL for all connections

---

**Once Step 1 is complete, proceed to Step 2: Create Application in the original guide.**
