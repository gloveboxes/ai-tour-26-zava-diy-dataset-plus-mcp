#!/usr/bin/env python3
"""
PostgreSQL Customer Sales Tool

This script provides the get_products_by_name function for querying product information
from the PostgreSQL database.

Usage:
    python postgres_customer_sales.py

Requirements:
    - asyncpg (async PostgreSQL adapter)
    - asyncio (for async operations)
    - python-dotenv (for environment variables)
"""

import asyncio
import json
import logging
import os
from typing import Optional

import asyncpg
from dotenv import load_dotenv

# Load environment variables (don't override existing ones)
load_dotenv(override=False)

# Configure logging
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(__name__)

# PostgreSQL connection configuration
POSTGRES_URL = os.getenv(
    "POSTGRES_URL", "postgresql://store_manager:StoreManager123!@db:5432/zava")

SCHEMA_NAME = "retail"
MANAGER_ID = ""


class PostgreSQLCustomerSales:
    """Provides PostgreSQL database connection and product search functionality."""

    def __init__(self, postgres_config: Optional[str] = None) -> None:
        self.postgres_config = postgres_config or POSTGRES_URL
        self.connection_pool: Optional[asyncpg.Pool] = None

    async def __aenter__(self) -> "PostgreSQLCustomerSales":
        """Async context manager entry - just return self, don't auto-create pool."""
        return self

    async def __aexit__(self, exc_type: Optional[type], exc_val: Optional[Exception], exc_tb: Optional[object]) -> None:
        """Async context manager exit - close connection pool if it was opened."""
        await self.close_pool()

    async def create_pool(self) -> None:
        """Create connection pool for better resource management."""
        if self.connection_pool is None:
            try:
                self.connection_pool = await asyncpg.create_pool(
                    self.postgres_config,
                    min_size=1,  # Minimum connections in pool
                    max_size=3,  # Very conservative pool size
                    command_timeout=30,  # 30 second query timeout
                    server_settings={
                        "jit": "off",  # Disable JIT to reduce memory usage
                        "work_mem": "4MB",  # Limit work memory per query
                        "statement_timeout": "30s",  # 30 second statement timeout
                    },
                )
                logger.info(
                    f"✅ PostgreSQL connection pool created: {self.postgres_config}"
                )
            except Exception as e:
                logger.error(f"❌ Failed to create PostgreSQL pool: {e}")
                raise

    async def close_pool(self) -> None:
        """Close connection pool and cleanup."""
        if self.connection_pool:
            await self.connection_pool.close()
            self.connection_pool = None
            logger.info("✅ PostgreSQL connection pool closed")

    async def get_connection(self) -> asyncpg.Connection:
        """Get a connection from pool."""
        if not self.connection_pool:
            raise RuntimeError(
                "No database connection pool available. Call create_pool() first.")

        try:
            return await self.connection_pool.acquire()
        except Exception as e:
            logger.error(f"Failed to acquire connection from pool: {e}")
            raise RuntimeError(
                f"Connection pool exhausted or unavailable: {e}") from e

    async def release_connection(self, conn: asyncpg.Connection) -> None:
        """Release connection back to pool."""
        if self.connection_pool:
            await self.connection_pool.release(conn)

    async def get_products_by_name(self, product_name: str, max_rows: int, rls_user_id: str) -> str:
        """Get products by name using a PostgreSQL query."""
        conn = None
        try:
            max_rows = min(max_rows, 100)  # Limit to 100 for performance
            
            conn = await self.get_connection()

            await conn.execute(
                "SELECT set_config('app.current_rls_user_id', $1, false)", rls_user_id)

            query = """
                SELECT p.product_name, pt.type_name, c.category_name, p.base_price as price, pe.image_url, SUM(i.stock_level) AS total_stock
                FROM retail.products p
                JOIN retail.product_types pt ON p.type_id = pt.type_id
                JOIN retail.categories c ON p.category_id = c.category_id
                JOIN retail.inventory i ON p.product_id = i.product_id
                JOIN retail.product_embeddings pe ON p.product_id = pe.product_id
                WHERE product_name ILIKE $1 OR product_description ILIKE $1
                GROUP BY p.product_name, pt.type_name, c.category_name, p.base_price, pe.image_url
                ORDER BY p.product_name
                LIMIT $2;
            """

            rows = await conn.fetch(
                query,
                f"%{product_name}%", max_rows
            )

            if not rows:
                return json.dumps(
                    {
                        "results": [],
                        "row_count": 0,
                        "columns": [],
                        "message": "The query returned no results. Try a different question.",
                    }
                )

            # Convert asyncpg Records to list of dictionaries
            results = [dict(row) for row in rows]
            columns = list(rows[0].keys()) if rows else []

            # Return LLM-friendly format
            return json.dumps(
                {"results": results, "row_count": len(results), "columns": columns}, indent=2, default=str
            )

        except Exception as e:
            return json.dumps(
                {
                    "error": f"PostgreSQL query failed: {e!s}",
                    "results": [],
                    "row_count": 0,
                    "columns": [],
                }
            )
        finally:
            if conn:
                await self.release_connection(conn)


async def test_connection() -> bool:
    """Test PostgreSQL connection and return success status."""
    try:
        # Create a temporary pool for testing
        pool = await asyncpg.create_pool(POSTGRES_URL, min_size=1, max_size=1)
        conn = await pool.acquire()
        await pool.release(conn)
        await pool.close()
        return True
    except Exception as e:
        logger.error(f"Connection test failed: {e}")
        return False


async def main() -> None:
    """Main function to test the get_products_by_name functionality."""
    logger.info("🤖 PostgreSQL Customer Sales Tool")
    logger.info("=" * 50)

    # Test connection first
    if not await test_connection():
        logger.error(
            f"❌ Error: Cannot connect to PostgreSQL using: {POSTGRES_URL}")
        logger.error("   Please verify:")
        logger.error("   1. PostgreSQL is running")
        logger.error("   2. Database 'zava' exists")
        logger.error("   3. POSTGRES_URL environment variable is correct")
        logger.error("   4. User has access to the retail schema")
        return

    try:
        async with PostgreSQLCustomerSales() as provider:
            # Create connection pool
            await provider.create_pool()

            logger.info("\n🧪 Testing get_products_by_name:")
            logger.info("=" * 50)

            logger.info("\n📊 Test: Search for 'paint' products")
            result = await provider.get_products_by_name("paint", 20, rls_user_id=MANAGER_ID)
            logger.info(f"Result: {result}")

            logger.info("\n✅ Product search test completed!")

    except Exception as e:
        logger.error(f"❌ Error during analysis: {e}")
        raise


if __name__ == "__main__":
    asyncio.run(main())
