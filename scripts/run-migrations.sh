#!/usr/bin/env bash
# run-migrations.sh
# Purpose: Execute Day 1 database migrations in correct order with validation
# Usage: ./scripts/run-migrations.sh [--validate-only] [--rollback]

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SQL_DIR="$PROJECT_ROOT/sql"
TEST_DIR="$SQL_DIR/tests"

# Migration files in execution order
MIGRATIONS=(
    "001_create_orchestrator_log.sql"
    "002_opportunity_tables.sql"
    "003_threshold_seed.sql"
    "004_runtime_logging.sql"
)

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if psql is installed
    if ! command -v psql &> /dev/null; then
        log_error "psql command not found. Please install PostgreSQL client."
        exit 1
    fi

    log_info "PostgreSQL client version: $(psql --version)"

    # Check if NEON_CONNECTION_STRING is set
    if [ -z "${NEON_CONNECTION_STRING:-}" ] && [ -z "${DATABASE_URL:-}" ]; then
        log_error "Database connection string not found."
        log_error "Set NEON_CONNECTION_STRING or DATABASE_URL environment variable."
        log_error "Example: export NEON_CONNECTION_STRING='postgresql://user:pass@host.neon.tech/db?sslmode=require'"
        exit 1
    fi

    # Use DATABASE_URL if NEON_CONNECTION_STRING not set
    DB_URL="${NEON_CONNECTION_STRING:-${DATABASE_URL}}"

    # Test database connection
    log_info "Testing database connection..."
    if ! psql "$DB_URL" -c "SELECT 1;" > /dev/null 2>&1; then
        log_error "Failed to connect to database. Check your connection string."
        exit 1
    fi

    log_info "✓ Database connection successful"

    # Check if migration files exist
    log_info "Verifying migration files..."
    for migration in "${MIGRATIONS[@]}"; do
        if [ ! -f "$SQL_DIR/$migration" ]; then
            log_error "Migration file not found: $SQL_DIR/$migration"
            exit 1
        fi
        log_info "  ✓ $migration"
    done

    log_info "✓ All prerequisites met"
    echo ""
}

run_migrations() {
    log_info "Starting Day 1 database migrations..."
    echo ""

    local success_count=0
    local total_count=${#MIGRATIONS[@]}

    for migration in "${MIGRATIONS[@]}"; do
        local migration_path="$SQL_DIR/$migration"
        log_info "Executing: $migration"

        if psql "$DB_URL" -f "$migration_path" > /tmp/migration_output.log 2>&1; then
            log_info "✓ $migration completed successfully"
            ((success_count++))
        else
            log_error "✗ $migration failed"
            log_error "Error details:"
            cat /tmp/migration_output.log
            exit 1
        fi
        echo ""
    done

    log_info "Migration Summary: $success_count/$total_count completed successfully"
    echo ""
}

validate_migrations() {
    log_info "Running validation tests..."
    echo ""

    local validation_file="$TEST_DIR/001_constraint_validation.sql"

    if [ ! -f "$validation_file" ]; then
        log_warning "Validation file not found: $validation_file"
        log_warning "Skipping validation tests."
        return 0
    fi

    if psql "$DB_URL" -f "$validation_file" > /tmp/validation_output.log 2>&1; then
        log_info "✓ Validation tests completed"
        echo ""
        log_info "Validation Results:"
        cat /tmp/validation_output.log | grep -E "(PASS|FAIL|TEST)" || true
    else
        log_error "✗ Validation tests failed"
        cat /tmp/validation_output.log
        exit 1
    fi
    echo ""
}

rollback_migrations() {
    log_warning "!!! ROLLBACK MODE !!!"
    log_warning "This will DROP ALL tables created by Day 1 migrations."
    echo ""
    read -p "Are you sure you want to continue? Type 'YES' to confirm: " confirmation

    if [ "$confirmation" != "YES" ]; then
        log_info "Rollback cancelled."
        exit 0
    fi

    log_info "Executing rollback..."

    psql "$DB_URL" <<EOF
BEGIN;

DROP TABLE IF EXISTS etl_logs CASCADE;
DROP TABLE IF EXISTS lead_transactions CASCADE;
DROP TABLE IF EXISTS lead_tasks CASCADE;
DROP TABLE IF EXISTS newsletter_issues CASCADE;
DROP TABLE IF EXISTS opportunity_metrics CASCADE;
DROP TABLE IF EXISTS opportunities CASCADE;
DROP TABLE IF EXISTS opportunity_runs CASCADE;
DROP TABLE IF EXISTS opportunity_thresholds CASCADE;
DROP TABLE IF EXISTS opportunity_hypotheses CASCADE;
DROP TABLE IF EXISTS orchestrator_run_log CASCADE;

COMMIT;
EOF

    if [ $? -eq 0 ]; then
        log_info "✓ Rollback completed successfully"
    else
        log_error "✗ Rollback failed"
        exit 1
    fi
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Execute Day 1 database migrations for Boring Businesses Platform.

OPTIONS:
    --validate-only     Run validation tests only (skip migrations)
    --rollback          Rollback all Day 1 migrations (DESTRUCTIVE)
    --help              Show this help message

EXAMPLES:
    # Run migrations with validation
    $0

    # Validate existing schema without running migrations
    $0 --validate-only

    # Rollback all Day 1 migrations
    $0 --rollback

PREREQUISITES:
    - PostgreSQL client (psql) installed
    - NEON_CONNECTION_STRING or DATABASE_URL environment variable set
    - Network access to Neon database

For more information, see: docs/runbooks/database-setup.md
EOF
}

# Main execution
main() {
    local mode="migrate"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --validate-only)
                mode="validate"
                shift
                ;;
            --rollback)
                mode="rollback"
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Execute based on mode
    case $mode in
        migrate)
            check_prerequisites
            run_migrations
            validate_migrations
            log_info "🎉 Day 1 migrations completed successfully!"
            log_info "Next: Review docs/runbooks/database-setup.md for post-migration steps"
            ;;
        validate)
            check_prerequisites
            validate_migrations
            log_info "✓ Validation complete"
            ;;
        rollback)
            check_prerequisites
            rollback_migrations
            ;;
    esac
}

# Run main function
main "$@"
