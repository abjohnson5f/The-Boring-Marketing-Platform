# Updated SQLite Connection Instructions for Retool

## The Problem
Retool doesn't have a direct "SQLite" resource option in their interface.

## Solution: Updated Step 1 Instructions

Replace the "Step 1: Create Database Resource" section with these updated options:

### Step 1: Create Database Resource

**Option A: PostgreSQL (RECOMMENDED - Most Reliable)**

Retool has excellent PostgreSQL support. Convert your SQLite database to PostgreSQL:

1. **Set up PostgreSQL database:**
   - Use a free cloud provider:
     - **Neon** (neon.tech) - Free tier available
     - **Supabase** (supabase.com) - Free tier available  
     - **Railway** (railway.app) - Free tier available
   - Or use local PostgreSQL if you have it installed

2. **Export SQLite to PostgreSQL:**
   ```bash
   # Install pgloader (if not installed)
   # macOS: brew install pgloader
   # Linux: apt-get install pgloader or yum install pgloader
   
   # Convert SQLite to PostgreSQL
   pgloader sqlite:///Users/alexjohnson/IDE\ Work/govspend-faulconer-market-intelligence/data/strategic_alignment.db postgresql://user:password@host:5432/dbname
   ```

   **Alternative method (manual export/import):**
   ```bash
   # 1. Export SQLite schema and data
   sqlite3 /Users/alexjohnson/IDE\ Work/govspend-faulconer-market-intelligence/data/strategic_alignment.db .dump > strategic_alignment.sql
   
   # 2. Convert SQLite syntax to PostgreSQL (may need manual adjustments)
   # 3. Import to PostgreSQL
   psql "postgresql://user:password@host:5432/dbname" < strategic_alignment.sql
   ```

3. **In Retool:**
   - Open Retool → Resources → Add Resource
   - Select **"PostgreSQL"**
   - Configure:
     - **Name:** `strategic_db`
     - **Host:** (your PostgreSQL host)
     - **Port:** `5432` (default)
     - **Database name:** (your database name)
     - **Database username:** (your username)
     - **Database password:** (your password)
     - **Use SSL:** ✓ (for cloud providers)
   - Click "Test Connection"
   - Save

**Option B: REST API Wrapper (For SQLite)**

If you want to keep using SQLite, create a REST API wrapper:

1. **Create a simple Node.js/Express API server:**
   ```javascript
   // sqlite-api-server.js
   const express = require('express');
   const sqlite3 = require('sqlite3').verbose();
   const app = express();
   
   const db = new sqlite3.Database('/Users/alexjohnson/IDE Work/govspend-faulconer-market-intelligence/data/strategic_alignment.db');
   
   app.use(express.json());
   
   app.post('/query', (req, res) => {
     const { sql } = req.body;
     db.all(sql, (err, rows) => {
       if (err) return res.status(500).json({ error: err.message });
       res.json({ data: rows });
     });
   });
   
   app.listen(3000, () => console.log('SQLite API running on port 3000'));
   ```

2. **Run the server:**
   ```bash
   npm install express sqlite3
   node sqlite-api-server.js
   ```

3. **In Retool:**
   - Resources → Add Resource → **"REST API"**
   - **Base URL:** `http://localhost:3000` (or your server URL)
   - **Name:** `strategic_db`
   - For queries, use "POST" method to `/query` with body: `{"sql": "YOUR SQL QUERY"}`

**Option C: File Resource (If Available)**

Some Retool plans support file-based resources:

1. **In Retool:**
   - Resources → Add Resource
   - Look for **"File"** or **"Local File"** option
   - If available, select it and point to your SQLite file path
   - Note: This may only work for Retool self-hosted instances

## Recommendation

**Use Option A (PostgreSQL)** because:
- ✅ Most reliable and well-supported in Retool
- ✅ Better performance for dashboards
- ✅ Easy to share and collaborate
- ✅ Free cloud options available (Neon, Supabase)
- ✅ All SQL queries will work the same way

The conversion from SQLite to PostgreSQL is usually straightforward, and all your existing SQL queries in the guide will work without modification.
