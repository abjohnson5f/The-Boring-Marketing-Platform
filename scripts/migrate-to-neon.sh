#!/bin/bash
# Migrate SQLite database to Neon PostgreSQL
# Usage: ./migrate-to-neon.sh <sqlite_db_path>

set -e

SQLITE_DB="$1"
NEON_CONNECTION="postgresql://neondb_owner:npg_LyPc2gdrEt9m@ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"

if [ -z "$SQLITE_DB" ]; then
    echo "Usage: $0 <sqlite_db_path>"
    echo "Example: $0 /path/to/strategic_alignment.db"
    exit 1
fi

if [ ! -f "$SQLITE_DB" ]; then
    echo "Error: SQLite database file not found: $SQLITE_DB"
    exit 1
fi

echo "🔄 Migrating SQLite database to Neon PostgreSQL..."
echo "SQLite DB: $SQLITE_DB"
echo "Neon Host: ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech"
echo ""

# Check for required tools
if ! command -v sqlite3 &> /dev/null; then
    echo "Error: sqlite3 not found. Please install it first."
    exit 1
fi

if ! command -v psql &> /dev/null; then
    echo "Error: psql not found. Please install PostgreSQL client first."
    echo "macOS: brew install postgresql"
    echo "Linux: apt-get install postgresql-client"
    exit 1
fi

# Export SQLite schema and data
TEMP_SQL="/tmp/strategic_alignment_export_$$.sql"
echo "📤 Exporting SQLite data..."
sqlite3 "$SQLITE_DB" .dump > "$TEMP_SQL"

# Convert SQLite syntax to PostgreSQL
echo "🔧 Converting SQL syntax for PostgreSQL..."
sed -i.bak \
    -e 's/INTEGER PRIMARY KEY AUTOINCREMENT/SERIAL PRIMARY KEY/g' \
    -e 's/INTEGER PRIMARY KEY/SERIAL PRIMARY KEY/g' \
    -e 's/AUTOINCREMENT/SERIAL/g' \
    -e 's/DATETIME/TIMESTAMP/g' \
    -e 's/BLOB/BYTEA/g' \
    -e '/^PRAGMA/d' \
    -e '/^BEGIN TRANSACTION/d' \
    -e '/^COMMIT/d' \
    -e 's/INTEGER/SMALLINT/g' \
    "$TEMP_SQL"

# Remove the backup file
rm -f "${TEMP_SQL}.bak"

echo "📥 Importing to Neon PostgreSQL..."

# Import to Neon
if psql "$NEON_CONNECTION" < "$TEMP_SQL"; then
    echo ""
    echo "✅ Migration complete!"
    echo ""
    echo "📊 Verifying tables..."
    psql "$NEON_CONNECTION" -c "\dt" || true
    
    echo ""
    echo "🎉 Your database is now in Neon!"
else
    echo ""
    echo "❌ Import failed. Common issues:"
    echo "   1. Tables already exist - drop them first or use DROP TABLE IF EXISTS"
    echo "   2. SSL connection issue - check your network"
    echo "   3. Syntax errors - check the SQL file: $TEMP_SQL"
    rm -f "$TEMP_SQL"
    exit 1
fi

# Cleanup
rm -f "$TEMP_SQL"

echo ""
echo "📋 Retool Configuration:"
echo "   Resource Type: PostgreSQL"
echo "   Host: ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech"
echo "   Port: 5432"
echo "   Database: neondb"
echo "   Username: neondb_owner"
echo "   Password: npg_LyPc2gdrEt9m"
echo "   SSL: ✓ Enabled (REQUIRED)"
