#!/usr/bin/env python3
"""
Migrate SQLite database to Neon PostgreSQL
"""
import sqlite3
import sys
import os
import subprocess

# Neon connection string (full)
NEON_CONNECTION = "postgresql://neondb_owner:npg_LyPc2gdrEt9m@ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"

def export_sqlite_to_postgres_sql(sqlite_path, output_file):
    """Export SQLite database to PostgreSQL-compatible SQL"""
    print(f"📊 Reading SQLite database: {sqlite_path}")
    
    conn = sqlite3.connect(sqlite_path)
    cursor = conn.cursor()
    
    # Get all table names
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
    tables = [row[0] for row in cursor.fetchall()]
    
    print(f"📋 Found {len(tables)} tables: {', '.join(tables)}")
    
    sql_lines = []
    sql_lines.append("-- Migration from SQLite to PostgreSQL")
    sql_lines.append("-- Generated automatically\n")
    
    for table in tables:
        print(f"  Processing table: {table}")
        
        # Get table schema
        cursor.execute(f"PRAGMA table_info({table})")
        columns = cursor.fetchall()
        
        # Create table statement
        sql_lines.append(f"\n-- Table: {table}")
        sql_lines.append(f"DROP TABLE IF EXISTS {table} CASCADE;")
        sql_lines.append(f"CREATE TABLE {table} (")
        
        col_defs = []
        primary_keys = []
        
        for col in columns:
            col_id, col_name, col_type, not_null, default_val, is_pk = col
            
            # Convert SQLite types to PostgreSQL
            pg_type = col_type.upper()
            if pg_type in ["INTEGER"]:
                if is_pk:
                    pg_type = "SERIAL"
                    primary_keys.append(col_name)
                else:
                    pg_type = "INTEGER"
            elif pg_type == "TEXT":
                pg_type = "TEXT"
            elif pg_type == "REAL":
                pg_type = "DOUBLE PRECISION"
            elif pg_type == "BLOB":
                pg_type = "BYTEA"
            elif "INT" in pg_type:
                pg_type = "INTEGER"
            elif "CHAR" in pg_type or "VARCHAR" in pg_type:
                pg_type = "TEXT"
            else:
                pg_type = col_type  # Keep as-is
            
            col_def = f"  {col_name} {pg_type}"
            
            if not_null and not is_pk:  # SERIAL is already NOT NULL
                col_def += " NOT NULL"
            
            if default_val and not is_pk:  # Don't add default for SERIAL
                col_def += f" DEFAULT {default_val}"
            
            col_defs.append(col_def)
        
        sql_lines.append(",\n".join(col_defs))
        
        # Add primary key constraint if not using SERIAL
        if primary_keys and "SERIAL" not in "\n".join(col_defs):
            sql_lines.append(f",\n  PRIMARY KEY ({', '.join(primary_keys)})")
        
        sql_lines.append(");\n")
        
        # Get and insert data
        cursor.execute(f"SELECT * FROM {table}")
        rows = cursor.fetchall()
        
        if rows:
            print(f"    Inserting {len(rows)} rows...")
            sql_lines.append(f"-- Data for {table} ({len(rows)} rows)")
            
            # Get column names
            cursor.execute(f"PRAGMA table_info({table})")
            col_info = cursor.fetchall()
            col_names = [col[1] for col in col_info]
            
            for row in rows:
                values = []
                for i, val in enumerate(row):
                    if val is None:
                        values.append("NULL")
                    elif isinstance(val, (int, float)):
                        values.append(str(val))
                    elif isinstance(val, bytes):
                        values.append(f"E'\\\\x{val.hex()}'")
                    else:
                        # Escape single quotes and backslashes
                        val_str = str(val).replace("\\", "\\\\").replace("'", "''")
                        values.append(f"'{val_str}'")
                
                sql_lines.append(f"INSERT INTO {table} ({', '.join(col_names)}) VALUES ({', '.join(values)});")
            sql_lines.append("")
    
    conn.close()
    
    # Write to file
    sql_content = "\n".join(sql_lines)
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print(f"✅ SQL export written to: {output_file}")
    return output_file

def import_to_neon(sql_file):
    """Import SQL file to Neon PostgreSQL"""
    print(f"\n📥 Importing to Neon PostgreSQL...")
    print(f"   Host: ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech")
    print(f"   Database: neondb")
    
    # Use psql to import
    try:
        result = subprocess.run(
            ['psql', NEON_CONNECTION, '-f', sql_file],
            capture_output=True,
            text=True,
            check=False
        )
        
        if result.returncode == 0:
            print("✅ Import successful!")
            if result.stdout:
                print(result.stdout)
            return True
        else:
            print("❌ Import failed:")
            if result.stderr:
                print(result.stderr)
            if result.stdout:
                print(result.stdout)
            return False
    except FileNotFoundError:
        print("❌ psql not found. Please install PostgreSQL client:")
        print("   macOS: brew install postgresql")
        print("   Linux: apt-get install postgresql-client or yum install postgresql")
        print("\n   Or manually import the SQL file:")
        print(f"   psql '{NEON_CONNECTION}' < {sql_file}")
        return False

def verify_tables():
    """Verify tables were created in Neon"""
    print("\n📊 Verifying tables in Neon...")
    try:
        result = subprocess.run(
            ['psql', NEON_CONNECTION, '-c', "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"],
            capture_output=True,
            text=True,
            check=False
        )
        
        if result.returncode == 0:
            print(result.stdout)
            return True
        else:
            print("⚠️  Could not verify tables (this is okay if psql is not installed)")
            return False
    except FileNotFoundError:
        print("⚠️  psql not available for verification")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 migrate-sqlite-to-neon.py <sqlite_db_path>")
        print("\nExample:")
        print("  python3 migrate-sqlite-to-neon.py /path/to/strategic_alignment.db")
        sys.exit(1)
    
    sqlite_path = sys.argv[1]
    
    if not os.path.exists(sqlite_path):
        print(f"❌ Error: SQLite database not found: {sqlite_path}")
        sys.exit(1)
    
    # Export SQLite to SQL
    output_sql = "strategic_alignment_neon_import.sql"
    print("="*60)
    export_sqlite_to_postgres_sql(sqlite_path, output_sql)
    
    # Import to Neon
    print("\n" + "="*60)
    success = import_to_neon(output_sql)
    
    if success:
        verify_tables()
    
    print("\n" + "="*60)
    if success:
        print("🎉 Migration complete!")
    else:
        print("⚠️  Migration had issues. Check output above.")
    
    print("\n📋 Retool Configuration:")
    print("   Resource Type: PostgreSQL")
    print("   Host: ep-solitary-waterfall-ahcfss5g.c-3.us-east-1.aws.neon.tech")
    print("   Port: 5432")
    print("   Database: neondb")
    print("   Username: neondb_owner")
    print("   Password: npg_LyPc2gdrEt9m")
    print("   SSL: ✓ Enabled (REQUIRED)")

if __name__ == "__main__":
    main()
