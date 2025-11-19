#!/usr/bin/env python3
"""
Helper script to migrate SQLite database to Neon PostgreSQL
Can be used with or without MCP resources
"""
import sqlite3
import sys
import os
from pathlib import Path

def get_sqlite_schema_and_data(db_path):
    """Extract schema and data from SQLite database"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get all table names
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in cursor.fetchall()]
    
    schema = {}
    data = {}
    
    for table in tables:
        # Get schema
        cursor.execute(f"PRAGMA table_info({table})")
        columns = cursor.fetchall()
        schema[table] = columns
        
        # Get data
        cursor.execute(f"SELECT * FROM {table}")
        data[table] = cursor.fetchall()
    
    conn.close()
    return schema, data, tables

def convert_sqlite_to_postgres_sql(db_path, output_file=None):
    """Convert SQLite database to PostgreSQL-compatible SQL"""
    schema, data, tables = get_sqlite_schema_and_data(db_path)
    
    sql_lines = []
    
    for table in tables:
        # Create table statement
        sql_lines.append(f"\n-- Table: {table}")
        sql_lines.append(f"DROP TABLE IF EXISTS {table} CASCADE;")
        sql_lines.append(f"CREATE TABLE {table} (")
        
        columns = schema[table]
        col_defs = []
        for col in columns:
            col_name = col[1]
            col_type = col[2]
            not_null = "NOT NULL" if col[3] else ""
            default = f"DEFAULT {col[4]}" if col[4] else ""
            
            # Convert SQLite types to PostgreSQL
            if col_type.upper() == "INTEGER":
                pg_type = "INTEGER"
            elif col_type.upper() == "TEXT":
                pg_type = "TEXT"
            elif col_type.upper() == "REAL":
                pg_type = "DOUBLE PRECISION"
            elif col_type.upper() == "BLOB":
                pg_type = "BYTEA"
            elif "INT" in col_type.upper():
                pg_type = "INTEGER"
            else:
                pg_type = col_type
            
            col_defs.append(f"  {col_name} {pg_type} {not_null} {default}".strip())
        
        sql_lines.append(",\n".join(col_defs))
        sql_lines.append(");\n")
        
        # Insert data
        if data[table]:
            sql_lines.append(f"-- Data for {table}")
            for row in data[table]:
                values = []
                for val in row:
                    if val is None:
                        values.append("NULL")
                    elif isinstance(val, str):
                        # Escape single quotes
                        val_escaped = val.replace("'", "''")
                        values.append(f"'{val_escaped}'")
                    elif isinstance(val, (int, float)):
                        values.append(str(val))
                    else:
                        values.append(f"'{str(val)}'")
                
                sql_lines.append(f"INSERT INTO {table} VALUES ({', '.join(values)});")
            sql_lines.append("")
    
    sql_content = "\n".join(sql_lines)
    
    if output_file:
        with open(output_file, 'w') as f:
            f.write(sql_content)
        print(f"✅ SQL export written to: {output_file}")
    else:
        print(sql_content)
    
    return sql_content

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python neon-migration-helper.py <sqlite_db_path> [output.sql]")
        sys.exit(1)
    
    db_path = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    if not os.path.exists(db_path):
        print(f"Error: Database file not found: {db_path}")
        sys.exit(1)
    
    print(f"📊 Analyzing SQLite database: {db_path}")
    convert_sqlite_to_postgres_sql(db_path, output_file)
    print("\n✅ Conversion complete!")
    print("\nNext steps:")
    print("1. Review the generated SQL file")
    print("2. Import to Neon using: psql <connection_string> < output.sql")
    print("   Or use Neon MCP resources if available")
