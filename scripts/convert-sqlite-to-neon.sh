#!/bin/bash
# Convert SQLite database to Neon PostgreSQL
# Usage: ./convert-sqlite-to-neon.sh <sqlite_db_path> <neon_connection_string>

set -e

SQLITE_DB="$1"
NEON_CONNECTION="$2"

if [ -z "$SQLITE_DB" ] || [ -z "$NEON_CONNECTION" ]; then
    echo "Usage: $0 <sqlite_db_path> <neon_connection_string>"
    echo "Example: $0 /path/to/strategic_alignment.db postgresql://user:pass@host/dbname"
    exit 1
fi

if [ ! -f "$SQLITE_DB" ]; then
    echo "Error: SQLite database file not found: $SQLITE_DB"
    exit 1
fi

echo "🔄 Converting SQLite to PostgreSQL..."
echo "SQLite DB: $SQLITE_DB"
echo "Neon Connection: ${NEON_CONNECTION%%@*}@***"

# Check if pgloader is available
if command -v pgloader &> /dev/null; then
    echo "✅ Using pgloader for conversion..."
    pgloader "sqlite://${SQLITE_DB}" "$NEON_CONNECTION"
    echo "✅ Conversion complete!"
else
    echo "⚠️  pgloader not found. Using manual export/import method..."
    
    # Export SQLite to SQL dump
    TEMP_SQL="/tmp/strategic_alignment_export.sql"
    echo "📤 Exporting SQLite data..."
    sqlite3 "$SQLITE_DB" .dump > "$TEMP_SQL"
    
    # Convert SQLite-specific syntax to PostgreSQL
    echo "🔧 Converting SQL syntax..."
    sed -i.bak \
        -e 's/INTEGER PRIMARY KEY AUTOINCREMENT/SERIAL PRIMARY KEY/g' \
        -e 's/INTEGER PRIMARY KEY/SERIAL PRIMARY KEY/g' \
        -e 's/AUTOINCREMENT/SERIAL/g' \
        -e 's/INTEGER/SMALLINT/g' \
        -e 's/BLOB/BYTEA/g' \
        -e 's/DATETIME/TIMESTAMP/g' \
        -e '/^PRAGMA/d' \
        -e '/^BEGIN TRANSACTION/d' \
        -e '/^COMMIT/d' \
        "$TEMP_SQL"
    
    # Import to PostgreSQL
    echo "📥 Importing to Neon PostgreSQL..."
    psql "$NEON_CONNECTION" < "$TEMP_SQL"
    
    # Cleanup
    rm -f "$TEMP_SQL" "${TEMP_SQL}.bak"
    
    echo "✅ Conversion complete!"
    echo "⚠️  Note: You may need to manually adjust some data types or constraints"
fi

echo ""
echo "🎉 Database migration complete!"
echo "You can now use this connection string in Retool:"
echo "$NEON_CONNECTION"
