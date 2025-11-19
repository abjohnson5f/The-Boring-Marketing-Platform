#!/bin/bash
# Migrate SQLite database to Neon PostgreSQL
# Usage: ./migrate-to-neon.sh <sqlite_db_path>

set -e

SQLITE_DB="$1"
NEON_CONNECTION="postgresql://neondb_owner:${NEON_PASSWORD}@ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech/neondb?sslmode=require"

if [ -z "$SQLITE_DB" ]; then
    echo "Usage: $0 <sqlite_db_path>"
    echo "Example: $0 /path/to/strategic_alignment.db"
    echo ""
    echo "Note: Set NEON_PASSWORD environment variable if password is needed"
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
echo "⚠️  You may be prompted for the database password"

# Import to Neon
if [ -n "$NEON_PASSWORD" ]; then
    export PGPASSWORD="$NEON_PASSWORD"
fi

psql "$NEON_CONNECTION" < "$TEMP_SQL" || {
    echo ""
    echo "❌ Import failed. Common issues:"
    echo "   1. Password incorrect - set NEON_PASSWORD environment variable"
    echo "   2. Tables already exist - drop them first or use --clean option"
    echo "   3. SSL connection issue - check your network"
    rm -f "$TEMP_SQL"
    exit 1
}

# Cleanup
rm -f "$TEMP_SQL"

echo ""
echo "✅ Migration complete!"
echo ""
echo "📊 Verifying tables..."
psql "$NEON_CONNECTION" -c "\dt" || true

echo ""
echo "🎉 Your database is now in Neon!"
echo "Next: Configure Retool with these settings:"
echo "  Host: ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech"
echo "  Port: 5432"
echo "  Database: neondb"
echo "  Username: neondb_owner"
echo "  Password: [your password]"
echo "  SSL: ✓ Enabled"
