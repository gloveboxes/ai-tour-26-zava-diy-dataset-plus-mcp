# Customer Sales MCP Server

A specialized Model Context Protocol (MCP) server that provides customer-focused product search capabilities for Zava Retail DIY Business. This server enables AI assistants to search and retrieve product information with Row Level Security (RLS) support for store-specific access.

## Features

- **Product Search by Name**: Search products by name
- **Store-Specific Access**: Row Level Security ensures users only see products available in their store
- **Real-time Inventory**: Access current stock levels and product availability
- **Product Details**: Retrieve comprehensive product information including pricing, categories, and images
- **Flexible Deployment**: Supports both stdio and HTTP server modes
- **Optimized Performance**: Connection pooling and query optimization for fast responses

## Core Functionality

### Product Search

The server provides intelligent product search capabilities that include:

- **Name-based Search**: Search products by exact or partial name matches
- **Description Search**: Also searches within product descriptions for better coverage
- **Aggregated Results**: Combines inventory data across locations for total stock levels
- **Rich Product Data**: Returns product names, types, categories, pricing, and image URLs

### Data Returned

For each product found, the server returns:

- **Product Name**: Full product name
- **Product Type**: Classification of the product type
- **Category**: Product category for organization
- **Price**: Current base price
- **Image URL**: Product image for visual identification
- **Total Stock**: Aggregated stock levels across locations

## Tools Available

### `get_products_by_name`

Search for products by name with comprehensive product details and inventory information.

**Parameters:**

- `product_name` (str): Name of the product to search for (supports partial matching)
- `max_rows` (int, optional): Maximum number of rows to return (default: 20). Limited to 100 for performance.

**Returns:** JSON-formatted query results containing:

- Product details (name, type, category, price)
- Product image URLs
- Aggregated stock levels
- Query metadata (row count, columns)

**Example Usage:**

```python
# Search for paint products
results = await get_products_by_name(
    product_name="paint",
    max_rows=10
)
```

### `get_current_utc_date`

Get the current UTC date and time in ISO format.

**Returns:** Current UTC date/time in ISO format (YYYY-MM-DDTHH:MM:SS.fffffZ)

**Use Cases:**

- Date-based inventory analysis
- Time-sensitive product searches
- Temporal context for customer interactions

## Security Features

### Row Level Security (RLS)

The server implements Row Level Security to ensure customers and staff only access products available in their specific store location:

- **HTTP Mode**: Uses `x-rls-user-id` header to identify the requesting user/store
- **Stdio Mode**: Uses `--RLS_USER_ID` command line argument
- **Default Fallback**: Uses placeholder UUID when no user ID is provided

#### Store-Specific RLS User IDs

Each Zava Retail store location has a unique RLS user ID that determines which products are visible:

| Store Location | RLS User ID | Access Level |
|---------------|-------------|--------------|
| **Global Access** | `00000000-0000-0000-0000-000000000000` | Limited product visibility |
| **Seattle** | `f47ac10b-58cc-4372-a567-0e02b2c3d479` | Seattle store product catalog |
| **Bellevue** | `6ba7b810-9dad-11d1-80b4-00c04fd430c8` | Bellevue store product catalog |
| **Tacoma** | `a1b2c3d4-e5f6-7890-abcd-ef1234567890` | Tacoma store product catalog |
| **Spokane** | `d8e9f0a1-b2c3-4567-8901-234567890abc` | Spokane store product catalog |
| **Everett** | `3b9ac9fa-cd5e-4b92-a7f2-b8c1d0e9f2a3` | Everett store product catalog |
| **Redmond** | `e7f8a9b0-c1d2-3e4f-5678-90abcdef1234` | Redmond store product catalog |
| **Kirkland** | `9c8b7a65-4321-fed0-9876-543210fedcba` | Kirkland store product catalog |
| **Online** | `2f4e6d8c-1a3b-5c7e-9f0a-b2d4f6e8c0a2` | Online store product catalog |

#### RLS Implementation

When a user connects with a specific store's RLS User ID, they will see:

- Products available in that store's inventory
- Store-specific pricing and stock levels
- Products relevant to that store's customer base
- Localized product recommendations

## Installation & Setup

### Prerequisites

- Docker
- VS Code with DevContainer extension

### Opening the Project

1. Open the project in VS Code.
2. If prompted, reopen in a DevContainer to ensure all dependencies are available.

### Environment Configuration

The project uses the same `.env` file configuration as other MCP servers:

```properties
# Default Group Access ID
RLS_USER_ID="00000000-0000-0000-0000-000000000000" 

# Store-specific RLS User IDs
# Zava Retail Seattle
# RLS_USER_ID="f47ac10b-58cc-4372-a567-0e02b2c3d479"

# Zava Retail Bellevue  
# RLS_USER_ID="6ba7b810-9dad-11d1-80b4-00c04fd430c8"

# Zava Retail Online
# RLS_USER_ID="2f4e6d8c-1a3b-5c7e-9f0a-b2d4f6e8c0a2"
# ... (additional store configurations)
```

### Database Configuration

```properties
# PostgreSQL connection (provided via Docker environment variables)
POSTGRES_URL="postgresql://store_manager:StoreManager123!@db:5432/zava"
```

## Usage

The following assumes you'll be using the built-in VS Code MCP server support.

### Running in Stdio Mode

Start the **zava-customer-sales-stdio** server using the `.vscode/mcp.json` configuration:

```json
{
    "servers": {
        "zava-sales-analysis-stdio": {
            "type": "stdio",
            "command": "python",
            "args": [
                "${workspaceFolder}/src/python/mcp_server/sales_analysis/sales_analysis.py",
                "--stdio",
                "--RLS_USER_ID=00000000-0000-0000-0000-000000000000"
            ]
        },
        "zava-customer-sales-stdio": {
            "type": "stdio",
            "command": "python",
            "args": [
                "${workspaceFolder}/src/python/mcp_server/customer_sales/customer_sales.py",
                "--stdio",
                "--RLS_USER_ID=00000000-0000-0000-0000-000000000000"
            ]
        },
        "zava-diy-http": {
            "url": "http://127.0.0.1:8000/mcp",
            "type": "http"
        }
    },
    "inputs": []
}
```

### Start the Customer Sales MCP Server in Streamable HTTP Mode

1. Start the MCP server in stdio mode:

    From VS Code, open the customer_sales.py file and run it directly by clicking the "Run" button in VS Code.

    or from the command line, run:

    ```bash
    cd src/python/mcp_server/customer_sales/ 
    python customer_sales.py
    ```

2. Enable the MCP server from the mcp.json configuration

    Start the **zava-diy-http** server using the `.vscode/mcp.json` configuration:

    ```json
    {
        "servers": {
            "zava-sales-analysis-stdio": {
                "type": "stdio",
                "command": "python",
                "args": [
                    "${workspaceFolder}/src/python/mcp_server/sales_analysis/sales_analysis.py",
                    "--stdio",
                    "--RLS_USER_ID=00000000-0000-0000-0000-000000000000"
                ]
            },
            "zava-customer-sales-stdio": {
                "type": "stdio",
                "command": "python",
                "args": [
                    "${workspaceFolder}/src/python/mcp_server/customer_sales/customer_sales.py",
                    "--stdio",
                    "--RLS_USER_ID=00000000-0000-0000-0000-000000000000"
                ]
            },
            "zava-diy-http": {
                "url": "http://127.0.0.1:8000/mcp",
                "type": "http"
            }
        },
        "inputs": []
    }
    ```

## Sample Queries

1. What paint products are available from Zava?
1. Is there paint in stock at the Seattle store?

## Architecture

### Application Context

The server uses a managed application context with:

- **Database Connection Pool**: Efficient connection management for concurrent requests
- **Lifecycle Management**: Proper resource cleanup on shutdown
- **Type Safety**: Strongly typed context with `AppContext` dataclass

### Database Integration

The server integrates with PostgreSQL through the `PostgreSQLCustomerSales` class:

- **Connection Pooling**: Configurable async connection pools (1-3 connections)
- **Query Optimization**: Optimized queries with joins for comprehensive product data
- **Resource Management**: Conservative memory usage and connection timeouts
- **RLS Integration**: Automatic Row Level Security configuration per request

### Query Performance

The database layer includes several optimizations:

- **Connection Pooling**: Min 1, Max 3 connections to balance performance and resource usage
- **Query Timeouts**: 30-second timeouts to prevent hanging requests
- **Memory Limits**: 4MB work memory per query to control resource usage
- **JIT Disabled**: Reduces memory overhead for better performance

## Database Schema Integration

### Tables Accessed

The server queries the following retail database tables:

- `retail.products` - Main product information
- `retail.product_types` - Product type classifications
- `retail.categories` - Product categories
- `retail.inventory` - Stock levels and availability
- `retail.product_embeddings` - Product images and metadata

### Query Structure

The main product search query performs:

1. **Multi-table Joins**: Combines product, type, category, inventory, and embedding data
2. **Fuzzy Matching**: Uses ILIKE for partial name and description matching
3. **Aggregation**: Sums stock levels across multiple inventory records
4. **Ordering**: Results ordered by product name for consistency
5. **Limiting**: Configurable result limits for performance

## Error Handling

The server implements comprehensive error handling:

- **Connection Management**: Graceful handling of database connection issues
- **Query Validation**: Safe parameter binding to prevent SQL injection
- **Resource Cleanup**: Proper connection release even during errors
- **User-Friendly Responses**: Clear error messages in JSON format
- **Fallback Handling**: Graceful degradation when no results found

## Example Usage Scenarios

### Customer Product Search

```python
# Customer looking for paint products
results = await get_products_by_name(
    product_name="paint",
    max_rows=20
)
# Returns: paint types, prices, stock levels, images
```

### Store Associate Assistance

```python
# Store associate helping customer find specific item
results = await get_products_by_name(
    product_name="electrical outlet",
    max_rows=15
)
# Returns: outlet types, categories, availability, pricing
```

### Inventory Check

```python
# Quick inventory check for specific product
results = await get_products_by_name(
    product_name="drill bit set",
    max_rows=5
)
# Returns: available drill bit sets with stock levels
```

## Security Considerations

1. **Row Level Security**: All queries respect RLS policies based on store identity
2. **Store Data Isolation**: Each store sees only relevant product inventory
3. **Input Sanitization**: All user inputs are safely parameterized in queries
4. **Resource Limits**: Query timeouts and connection limits prevent abuse
5. **Connection Security**: Secure database connection practices
6. **User Identity Verification**: Always verify correct RLS User ID for intended store

### Important Security Notes

- **Store-Specific Access**: Each RLS User ID provides access only to that store's products
- **Customer Privacy**: Product searches are isolated by store location
- **Inventory Security**: Stock levels shown only for authorized store locations
- **Production Safety**: Never use production RLS User IDs in development environments

## Development

### Project Structure

```text
customer_sales/
├── customer_sales.py          # Main MCP server implementation
├── customer_sales_postgres.py # PostgreSQL integration layer
└── README.md                  # This documentation
```

### Key Components

- **FastMCP Server**: Modern MCP server with async support and lifecycle management
- **PostgreSQL Provider**: Specialized database layer for product search operations
- **Context Management**: Type-safe application and request context handling
- **Tool Registration**: Declarative tool registration with Pydantic validation

### Testing

The PostgreSQL layer includes built-in testing capabilities:

```bash
# Test the database connection and search functionality
python customer_sales_postgres.py
```

## Contributing

When contributing to this server:

1. Ensure all database queries respect Row Level Security policies
2. Add proper error handling and input validation for new features
3. Update this README with any new functionality or changes
4. Test both stdio and HTTP server modes thoroughly
5. Validate product search results across different store locations
6. Maintain query performance and resource usage limits

## Use Cases

This MCP server is ideal for:

- **Customer Service Applications**: Help customers find products quickly
- **Store Associate Tools**: Assist staff in locating inventory and product details
- **E-commerce Integration**: Power product search in online stores
- **Inventory Management**: Quick product lookup and availability checking
- **Customer Chat Bots**: Enable AI assistants to help with product inquiries

## License

[Include appropriate license information]

---

*This MCP server enables efficient, secure product search capabilities for Zava Retail customers and staff across all store locations.*
