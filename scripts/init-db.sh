#!/bin/bash
set -e

echo "🚀 Initializing Zava PostgreSQL Database..."

# Create the zava database
echo "📦 Creating 'zava' database..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE zava;
    GRANT ALL PRIVILEGES ON DATABASE zava TO $POSTGRES_USER;
EOSQL

# Install pgvector extension in the zava database
echo "🔧 Installing pgvector extension in 'zava' database..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "zava" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS vector;
EOSQL

# Create store_manager user for RLS testing (defer retail schema permissions until after restoration)
echo "👤 Creating 'store_manager' user for Row Level Security testing..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "zava" <<-EOSQL
    -- Create store_manager user if it doesn't exist
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'store_manager') THEN
            CREATE USER store_manager WITH PASSWORD 'StoreManager123!';
            
            -- Grant necessary privileges to connect and use the database
            GRANT CONNECT ON DATABASE zava TO store_manager;
            
            RAISE NOTICE 'Created store_manager user successfully (retail schema permissions will be granted after restoration)';
        ELSE
            RAISE NOTICE 'store_manager user already exists, skipping creation';
        END IF;
    END
    \$\$;
EOSQL

# Check if backup file exists and restore it
BACKUP_FILE_NEW="/docker-entrypoint-initdb.d/backups/zava_retail_2025_07_14_postgres_rls.backup"

echo "🔍 Checking for backup files..."
echo "📁 Contents of backup directory:"
ls -la /docker-entrypoint-initdb.d/backups/ || echo "Backup directory not found"

# Check file permissions and existence
if [ -d "/docker-entrypoint-initdb.d/backups" ]; then
    echo "📋 Backup directory exists"
    echo "🔍 Looking for backup files..."
    find /docker-entrypoint-initdb.d/backups -name "*.backup" -ls || echo "No .backup files found"
else
    echo "❌ Backup directory does not exist"
fi

# Try the newer backup file first, then fall back to the older one
if [ -f "$BACKUP_FILE_NEW" ]; then
    BACKUP_FILE="$BACKUP_FILE_NEW"
    echo "📂 Found newer backup file with RLS: $BACKUP_FILE"
else
    BACKUP_FILE=""
    echo "❌ No backup files found"
fi

if [ -n "$BACKUP_FILE" ]; then
    echo "🚀 Restoring data from: $BACKUP_FILE"
    echo "📊 Backup file size: $(stat -c%s "$BACKUP_FILE" 2>/dev/null || stat -f%z "$BACKUP_FILE" 2>/dev/null || echo "unknown") bytes"
    
    # Test if pg_restore can read the file
    echo "🔍 Testing backup file integrity..."
    if pg_restore -l "$BACKUP_FILE" >/dev/null 2>&1; then
        echo "✅ Backup file is valid"
    else
        echo "❌ Backup file appears to be corrupted or invalid"
        BACKUP_FILE=""
    fi
fi

if [ -n "$BACKUP_FILE" ]; then
    echo "🚀 Starting restoration process..."
    
    # Create the retail schema first if it doesn't exist
    echo "🔧 Ensuring retail schema exists..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "zava" <<-EOSQL
        CREATE SCHEMA IF NOT EXISTS retail;
EOSQL
    
    # CRITICAL: Disable RLS temporarily for restoration
    echo "🔓 Temporarily disabling Row Level Security for restoration..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "zava" <<-EOSQL
        -- Disable RLS on all tables that might have it
        DO \$\$
        DECLARE
            r RECORD;
        BEGIN
            -- Find all tables with RLS enabled and disable it temporarily
            FOR r IN SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'retail'
            LOOP
                BEGIN
                    EXECUTE format('ALTER TABLE %I.%I DISABLE ROW LEVEL SECURITY', r.schemaname, r.tablename);
                    RAISE NOTICE 'Disabled RLS on table %.%', r.schemaname, r.tablename;
                EXCEPTION
                    WHEN undefined_table THEN
                        -- Table doesn't exist yet, ignore
                        NULL;
                    WHEN OTHERS THEN
                        -- Log error but continue
                        RAISE WARNING 'Could not disable RLS on table %.%: %', r.schemaname, r.tablename, SQLERRM;
                END;
            END LOOP;
        END
        \$\$;
EOSQL
    
    # Method 1: Try standard restoration with better error handling
    echo "🔧 Method 1: Standard restore with --clean --if-exists"
    RESTORE_OUTPUT=$(mktemp)
    if pg_restore -v --username "$POSTGRES_USER" --dbname "zava" --clean --if-exists --no-owner --no-privileges "$BACKUP_FILE" 2>"$RESTORE_OUTPUT"; then
        echo "✅ Standard restoration successful"
        RESTORE_SUCCESS=true
    else
        RESTORE_EXIT_CODE=$?
        echo "❌ Standard pg_restore failed with exit code $RESTORE_EXIT_CODE"
        echo "� Error details:"
        cat "$RESTORE_OUTPUT" | tail -20
        
        # Method 2: Try without --clean --if-exists
        echo "🔧 Method 2: Restore without --clean --if-exists"
        if pg_restore -v --username "$POSTGRES_USER" --dbname "zava" --no-owner --no-privileges "$BACKUP_FILE" 2>"$RESTORE_OUTPUT"; then
            echo "✅ Alternative restoration successful"
            RESTORE_SUCCESS=true
        else
            RESTORE_EXIT_CODE=$?
            echo "❌ Alternative restore method also failed with exit code $RESTORE_EXIT_CODE"
            echo "� Error details:"
            cat "$RESTORE_OUTPUT" | tail -20
            
            # Method 3: Try schema-only first, then data-only
            echo "🔧 Method 3: Schema-only followed by data-only restoration"
            
            # First restore schema
            if pg_restore -v --username "$POSTGRES_USER" --dbname "zava" --schema-only --no-owner --no-privileges "$BACKUP_FILE" 2>"$RESTORE_OUTPUT"; then
                echo "✅ Schema restoration successful"
                
                # Then restore data
                if pg_restore -v --username "$POSTGRES_USER" --dbname "zava" --data-only --no-owner --no-privileges "$BACKUP_FILE" 2>"$RESTORE_OUTPUT"; then
                    echo "✅ Data restoration successful"
                    RESTORE_SUCCESS=true
                else
                    echo "❌ Data restoration failed"
                    echo "📋 Error details:"
                    cat "$RESTORE_OUTPUT" | tail -20
                    RESTORE_SUCCESS=false
                fi
            else
                echo "❌ Schema restoration failed"
                echo "📋 Error details:"
                cat "$RESTORE_OUTPUT" | tail -20
                RESTORE_SUCCESS=false
            fi
        fi
    fi
    
    # Clean up temp file
    rm -f "$RESTORE_OUTPUT"
    
    # Set BACKUP_FILE to empty if restoration failed
    if [ "$RESTORE_SUCCESS" != true ]; then
        echo "❌ All restoration methods failed"
        echo "📋 Continuing without backup restoration..."
        BACKUP_FILE=""
    fi
    
    if [ -n "$BACKUP_FILE" ] && [ "$RESTORE_SUCCESS" = true ]; then
        echo "✅ Database restoration completed!"
        
        # Verify that data was actually restored
        echo "🔍 Verifying restoration..."
        
        # Check if retail schema exists
        SCHEMA_EXISTS=$(psql -t --username "$POSTGRES_USER" --dbname "zava" -c "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = 'retail';" 2>/dev/null | tr -d ' \n' || echo "0")
        
        if [ "$SCHEMA_EXISTS" -gt 0 ]; then
            echo "✅ Retail schema exists"
            
            # Check table count
            TABLE_COUNT=$(psql -t --username "$POSTGRES_USER" --dbname "zava" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'retail';" 2>/dev/null | tr -d ' \n' || echo "0")
            
            if [ "$TABLE_COUNT" -gt 0 ]; then
                echo "✅ Found $TABLE_COUNT tables in retail schema"
                
                # List all tables
                echo "📋 Tables found:"
                psql --username "$POSTGRES_USER" --dbname "zava" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'retail' ORDER BY table_name;" 2>/dev/null | grep -v "^$" | grep -v "table_name" | grep -v "^-" | grep -v "rows)" | sed 's/^/   - /'
                
                # Check for some expected tables and their data
                STORES_COUNT=$(psql -t --username "$POSTGRES_USER" --dbname "zava" -c "SELECT COUNT(*) FROM retail.stores;" 2>/dev/null | tr -d ' \n' || echo "0")
                CUSTOMERS_COUNT=$(psql -t --username "$POSTGRES_USER" --dbname "zava" -c "SELECT COUNT(*) FROM retail.customers;" 2>/dev/null | tr -d ' \n' || echo "0")
                PRODUCTS_COUNT=$(psql -t --username "$POSTGRES_USER" --dbname "zava" -c "SELECT COUNT(*) FROM retail.products;" 2>/dev/null | tr -d ' \n' || echo "0")
                ORDERS_COUNT=$(psql -t --username "$POSTGRES_USER" --dbname "zava" -c "SELECT COUNT(*) FROM retail.orders;" 2>/dev/null | tr -d ' \n' || echo "0")
                
                echo "📊 Data verification:"
                echo "   - Stores: $STORES_COUNT"
                echo "   - Customers: $CUSTOMERS_COUNT"
                echo "   - Products: $PRODUCTS_COUNT"
                echo "   - Orders: $ORDERS_COUNT"
                
                if [ "$STORES_COUNT" -gt 0 ] && [ "$CUSTOMERS_COUNT" -gt 0 ] && [ "$PRODUCTS_COUNT" -gt 0 ]; then
                    echo "✅ Data restoration verified successfully"
                    echo "🎯 Database is ready for use!"
                else
                    echo "⚠️  Some tables appear to be empty"
                    echo "🔍 This might be normal if using a minimal backup"
                fi
            else
                echo "❌ No tables found in retail schema after restoration"
                echo "⚠️  Backup restoration may have failed"
                BACKUP_FILE=""  # Mark as failed
            fi
        else
            echo "❌ Retail schema not found after restoration"
            echo "⚠️  Backup restoration failed"
            BACKUP_FILE=""  # Mark as failed
        fi
        
        # CRITICAL: Re-enable RLS and recreate policies after successful restoration
        echo "🔒 Re-enabling Row Level Security and recreating policies..."
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "zava" <<-EOSQL
            -- Re-enable RLS on all tables and recreate policies
            DO \$\$
            BEGIN
                -- Enable RLS on customers table and recreate policy
                ALTER TABLE retail.customers ENABLE ROW LEVEL SECURITY;
                DROP POLICY IF EXISTS customers_manager_policy ON retail.customers;
                CREATE POLICY customers_manager_policy ON retail.customers
                    FOR ALL TO store_manager
                    USING (rls_user_id = current_setting('app.current_rls_user_id')::integer);
                RAISE NOTICE 'Enabled RLS and recreated policy on customers table';
                
                -- Enable RLS on orders table and recreate policy
                ALTER TABLE retail.orders ENABLE ROW LEVEL SECURITY;
                DROP POLICY IF EXISTS orders_manager_policy ON retail.orders;
                CREATE POLICY orders_manager_policy ON retail.orders
                    FOR ALL TO store_manager
                    USING (rls_user_id = current_setting('app.current_rls_user_id')::integer);
                RAISE NOTICE 'Enabled RLS and recreated policy on orders table';
                
                -- Enable RLS on order_items table and recreate policy
                ALTER TABLE retail.order_items ENABLE ROW LEVEL SECURITY;
                DROP POLICY IF EXISTS order_items_manager_policy ON retail.order_items;
                CREATE POLICY order_items_manager_policy ON retail.order_items
                    FOR ALL TO store_manager
                    USING (EXISTS (
                        SELECT 1 FROM retail.orders o 
                        WHERE o.order_id = order_items.order_id 
                        AND o.rls_user_id = current_setting('app.current_rls_user_id')::integer
                    ));
                RAISE NOTICE 'Enabled RLS and recreated policy on order_items table';
                
                -- Enable RLS on inventory table and recreate policy
                ALTER TABLE retail.inventory ENABLE ROW LEVEL SECURITY;
                DROP POLICY IF EXISTS inventory_manager_policy ON retail.inventory;
                CREATE POLICY inventory_manager_policy ON retail.inventory
                    FOR ALL TO store_manager
                    USING (rls_user_id = current_setting('app.current_rls_user_id')::integer);
                RAISE NOTICE 'Enabled RLS and recreated policy on inventory table';
                
                RAISE NOTICE 'Successfully re-enabled RLS and recreated all policies';
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE WARNING 'Error during RLS re-enablement: %', SQLERRM;
            END
            \$\$;
EOSQL
        
        # Re-grant permissions to store_manager after restoration
        echo "🔑 Re-granting permissions to store_manager after restoration..."
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "zava" <<-EOSQL
            -- Re-grant permissions on all tables and sequences in retail schema
            GRANT USAGE ON SCHEMA retail TO store_manager;
            GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA retail TO store_manager;
            GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA retail TO store_manager;
            RAISE NOTICE 'Re-granted permissions to store_manager after restoration';
EOSQL
    else
        echo "⚠️  Database restoration failed or no backup found"
        echo "📋 Database 'zava' created but no data restored."
        echo ""
        echo "� Attempting to generate fresh data automatically..."
        
        # Try to generate data using the Python script
        if [ -f "/workspace/src/shared/database/data-generator/generate_zava_postgres.py" ]; then
            echo "📊 Found data generator script, attempting to create fresh data..."
            cd /workspace/src/shared/database/data-generator
            
            # Check if required Python packages are available
            if python3 -c "import asyncpg, asyncio" 2>/dev/null; then
                echo "✅ Required Python packages found"
                echo "🚀 Generating fresh data (this may take a few minutes)..."
                
                if python3 generate_zava_postgres.py --num-customers 10000 2>&1; then
                    echo "✅ Fresh data generation completed successfully!"
                    echo "🎯 Database is now ready for use!"
                    
                    # Re-grant permissions after data generation
                    echo "🔑 Granting permissions to store_manager for generated data..."
                    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "zava" <<-EOSQL
                        GRANT USAGE ON SCHEMA retail TO store_manager;
                        GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA retail TO store_manager;
                        GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA retail TO store_manager;
                        RAISE NOTICE 'Granted permissions to store_manager for generated data';
EOSQL
                else
                    echo "❌ Fresh data generation failed"
                    echo "💡 You can manually generate data later using:"
                    echo "   cd /workspace/src/shared/database/data-generator"
                    echo "   python3 generate_zava_postgres.py --num-customers 10000"
                fi
            else
                echo "❌ Required Python packages not available"
                echo "💡 You can manually generate data later using: /workspace/scripts/generate_fresh_data.sh"
            fi
        else
            echo "❌ Data generator script not found"
            echo "💡 You can manually generate data using: /workspace/scripts/generate_fresh_data.sh"
        fi
    fi
else
    echo "⚠️  No backup files found"
    echo "📋 Database 'zava' created but no data restored."
    echo "💡 You can generate data using: /workspace/scripts/generate_fresh_data.sh"
fi

echo "🎉 Zava PostgreSQL Database initialization completed!"
echo "📊 Database: zava"
echo "👤 Users: postgres (superuser), store_manager (RLS testing)"
echo "🔌 Extensions: pgvector"
echo ""
echo "🔧 Troubleshooting scripts available:"
echo "   📋 Test backup files: /workspace/scripts/test_backup_files.sh"
echo "   🔄 Manual restore: /workspace/scripts/manual_restore_backup.sh"
echo "   🆕 Generate data: /workspace/scripts/generate_fresh_data.sh"
echo "   👤 Test store_manager: /workspace/scripts/test_store_manager.sh"
