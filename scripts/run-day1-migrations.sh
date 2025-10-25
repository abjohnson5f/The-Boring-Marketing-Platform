#!/bin/bash
set -e

echo "====================================="
echo "Day 1: Database Migration Execution"
echo "====================================="
echo ""

# Check for connection string
if [ -z "$NEON_CONNECTION_STRING" ]; then
    echo "ERROR: NEON_CONNECTION_STRING environment variable is not set"
    exit 1
fi

echo "✓ NEON_CONNECTION_STRING is set"
echo ""

# Test connection
echo "Testing database connection..."
psql "$NEON_CONNECTION_STRING" -c "SELECT version();" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Database connection successful"
else
    echo "✗ Database connection failed"
    exit 1
fi
echo ""

# Run migrations
MIGRATIONS=(
    "001_create_orchestrator_log.sql"
    "002_opportunity_tables.sql"
    "003_threshold_seed.sql"
    "004_runtime_logging.sql"
)

echo "Executing migrations..."
echo ""

for migration in "${MIGRATIONS[@]}"; do
    echo "Running $migration..."
    psql "$NEON_CONNECTION_STRING" -f "sql/$migration"
    if [ $? -eq 0 ]; then
        echo "✓ $migration completed successfully"
    else
        echo "✗ $migration failed"
        exit 1
    fi
    echo ""
done

echo "====================================="
echo "All migrations completed successfully"
echo "====================================="
echo ""

# Run validation
if [ -f "sql/tests/001_constraint_validation.sql" ]; then
    echo "Running validation tests..."
    psql "$NEON_CONNECTION_STRING" -f "sql/tests/001_constraint_validation.sql"
    echo ""
    echo "✓ Validation completed"
fi

# Show table count
echo "Checking created tables..."
psql "$NEON_CONNECTION_STRING" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"
