# Retool Setup Guide - Neon PostgreSQL Edition

## Updated Step 1: Connect to Neon PostgreSQL

Since Retool doesn't support SQLite directly, we'll use Neon PostgreSQL (which you already have set up).

### Step 1A: Locate Your SQLite Database

Your SQLite database should be at:
```
/Users/alexjohnson/IDE Work/govspend-faulconer-market-intelligence/data/strategic_alignment.db
```

### Step 1B: Convert SQLite to Neon PostgreSQL

**Option 1: Using the Migration Script (Recommended)**

1. **Get your Neon connection string:**
   - Log into Neon dashboard (neon.tech)
   - Go to your project → Connection Details
   - Copy the connection string (format: `postgresql://user:password@host/dbname`)

2. **Run the conversion script:**
   ```bash
   # Navigate to your project directory
   cd "/Users/alexjohnson/IDE Work/govspend-faulconer-market-intelligence"
   
   # Use the conversion script
   /workspace/scripts/convert-sqlite-to-neon.sh \
     "./data/strategic_alignment.db" \
     "postgresql://your-neon-connection-string"
   ```

**Option 2: Using Python Helper Script**

```bash
# Generate PostgreSQL SQL file
python3 /workspace/scripts/neon-migration-helper.py \
  "/Users/alexjohnson/IDE Work/govspend-faulconer-market-intelligence/data/strategic_alignment.db" \
  strategic_alignment_export.sql

# Import to Neon (replace with your connection string)
psql "postgresql://user:password@host/dbname" < strategic_alignment_export.sql
```

**Option 3: Using Neon MCP (If Available)**

If your Neon MCP is configured, you can use it directly:
- The MCP can help with database operations
- Check available Neon MCP resources for database import tools

### Step 1C: Configure Retool Resource

1. **In Retool:**
   - Open Retool → Resources → Add Resource
   - Select **"PostgreSQL"** (not SQLite - that option doesn't exist)

2. **Enter your Neon connection details:**
   - **Name:** `strategic_db`
   - **Host:** (from your Neon connection string, e.g., `ep-xxx.us-east-2.aws.neon.tech`)
   - **Port:** `5432` (default PostgreSQL port)
   - **Database name:** (your Neon database name)
   - **Database username:** (your Neon username)
   - **Database password:** (your Neon password)
   - **Use SSL:** ✓ **CHECK THIS** (Neon requires SSL)

3. **Test Connection:**
   - Click "Test Connection"
   - You should see: "Connection successful"

4. **Save the resource**

### Step 1D: Verify Tables Exist

Test that your tables are accessible:

1. In Retool, go to the Query editor
2. Create a test query:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public'
   ORDER BY table_name;
   ```
3. Run it - you should see tables like:
   - `opportunities_enriched`
   - `smart_summaries`
   - `faulconer_objectives`
   - `agency_strategic_priorities`
   - `relationship_graph`
   - `compliance_readiness`

## Troubleshooting

### "Connection failed" error
- ✅ Verify SSL is enabled
- ✅ Check your connection string format
- ✅ Ensure your Neon database is active (not paused)
- ✅ Verify firewall/IP allowlist settings in Neon

### "Table does not exist" error
- ✅ Run the migration script again
- ✅ Check that all tables were created: `\dt` in psql
- ✅ Verify you're connected to the correct database

### "SSL required" error
- ✅ Enable "Use SSL" checkbox in Retool resource settings
- ✅ Neon requires SSL for all connections

## Next Steps

Once your Neon database is connected in Retool:
1. ✅ Proceed to **Step 2: Create Application** in the original guide
2. ✅ All SQL queries will work the same (PostgreSQL is compatible)
3. ✅ Your dashboard will be accessible from anywhere (Neon is cloud-hosted)

## Benefits of Using Neon

- ✅ **Cloud-hosted** - Access from anywhere
- ✅ **Free tier** - Generous free plan
- ✅ **Automatic backups** - Your data is safe
- ✅ **Scalable** - Easy to upgrade as needed
- ✅ **PostgreSQL** - Full SQL compatibility
- ✅ **Fast** - Optimized for performance

---

**Ready to continue?** Once Step 1 is complete, proceed with the rest of the RETOOL_SETUP_GUIDE.md starting from Step 2.
