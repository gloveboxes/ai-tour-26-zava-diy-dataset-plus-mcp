# Zava DIY Dataset Plus MCP

A comprehensive demonstration project featuring a realistic PostgreSQL dataset for **Zava DIY**, a fictional home improvement retail company, combined with two specialized Model Context Protocol (MCP) servers. This project showcases advanced retail analytics, AI-powered product search capabilities, and secure multi-store data access patterns.

## Example Workshop Documentation

Click the links below to view the example workshop documentation:

(https://gloveboxes.github.io/ai-tour-26-zava-diy-dataset-plus-mcp/)

## Project Overview

This project provides:

- **🏪 Realistic Retail Dataset**: A complete PostgreSQL database with 50,000+ customers, 400+ products, 200,000+ transactions, and AI-ready vector embeddings
- **🔍 Customer Sales MCP Server**: Intelligent product search with Row Level Security for store-specific access
- **📊 Sales Analysis MCP Server**: Comprehensive sales database access for AI-powered analytics and insights
- **🔒 Row Level Security**: Multi-tenant security ensuring store managers only access their store's data
- **🚀 AI/ML Ready**: Vector embeddings for product similarity search and recommendation systems

The dataset simulates **Zava DIY**, a Washington State-based home improvement retailer with 8 locations (7 physical stores + online), complete with seasonal variations, realistic customer behavior patterns, and comprehensive product catalog covering tools, lumber, electrical, plumbing, and garden supplies.

## Prerequisites

Before getting started, ensure you have:

- **Docker Desktop** installed and running
- **Visual Studio Code** with the Dev Containers extension
- **Git** for cloning the repository

## Getting Started

### Opening the Project in a Dev Container

1. **Clone the repository**:
   ```bash
   git clone https://github.com/gloveboxes/ai-tour-26-zava-diy-dataset-plus-mcp.git
   cd ai-tour-26-zava-diy-dataset-plus-mcp
   ```

2. **Open in VS Code**:
   ```bash
   code .
   ```

3. **Reopen in Container**:
   - When prompted by VS Code, click "Reopen in Container"
   - Or use the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and select "Dev Containers: Reopen in Container"
   - Or click the green button in the bottom-left corner and select "Reopen in Container"

4. **Wait for Setup**:
   - The dev container will build automatically with all dependencies pre-installed
   - This includes PostgreSQL with pgvector extension, Python environment, and all required packages

The dev container provides a complete development environment with:
- PostgreSQL database with pgvector extension
- Python 3.x with all required packages
- Azure CLI for cloud deployments
- Node.js and npm for web development
- .NET SDK for additional integrations

## MCP Servers

This project includes two specialized Model Context Protocol servers designed for different retail scenarios:

### 🔍 Customer Sales MCP Server

**Purpose**: Intelligent product search and customer assistance

**Key Features**:
- Product search by name with fuzzy matching
- Store-specific product availability through Row Level Security
- Real-time inventory levels and stock information
- AI-ready product image embeddings for visual search
- Optimized for customer service and sales assistance

**Use Cases**:
- Customer service applications helping customers find products
- Store associate tools for inventory lookup
- E-commerce product search and recommendations
- AI chatbots for customer product inquiries

📖 **[Read the Customer Sales MCP Server Documentation](src/python/mcp_server/customer_sales/README.md)**

### 📊 Sales Analysis MCP Server

**Purpose**: Comprehensive sales database access and analytics

**Key Features**:
- Multi-table schema access for complete database insights
- Secure PostgreSQL query execution with Row Level Security
- Access to customers, orders, inventory, and product data
- Time-series analysis with UTC date utilities
- Store manager access control and data isolation

**Use Cases**:
- Sales performance analysis and reporting
- Business intelligence and data analytics
- Store manager dashboards and insights
- AI-powered business decision support
- Customer behavior and trend analysis

📖 **[Read the Sales Analysis MCP Server Documentation](src/python/mcp_server/sales_analysis/README.md)**

### Security Model

Both servers implement **Row Level Security (RLS)** ensuring:
- **Store managers** only access their store's data
- **Customer service reps** see store-specific product availability
- **Data isolation** between different store locations
- **Global admin access** for corporate-level analysis

## Dataset Overview

The Zava DIY PostgreSQL database provides a comprehensive retail ecosystem with realistic data patterns:

### 📊 Dataset Scale

| Component | Count | Description |
|-----------|-------|-------------|
| **Customers** | 50,000+ | Realistic demographic profiles across Washington State |
| **Products** | 400+ | Complete DIY home improvement catalog |
| **Stores** | 8 | Physical + online locations across Washington State |
| **Orders** | 200,000+ | Multi-year transaction history (2020-2026) |
| **Order Items** | 500,000+ | Detailed line items with pricing and quantities |
| **Inventory Records** | 3,000+ | Store-specific stock levels |
| **Vector Embeddings** | 400+ | AI-powered product similarity search |

### 🏪 Store Locations

- **High-Traffic Stores**: Seattle, Bellevue, Online
- **Regional Stores**: Tacoma, Spokane
- **Specialty Markets**: Everett, Redmond, Kirkland
- **Geographic Distribution**: Realistic Washington State market penetration

### 📦 Product Categories

- **Hand Tools**: Hammers, screwdrivers, wrenches, measuring tools
- **Power Tools**: Drills, saws, sanders, grinders
- **Paint & Finishes**: Interior/exterior paints, primers, stains
- **Hardware**: Fasteners, hinges, locks, cabinet hardware
- **Lumber & Building Materials**: Dimensional lumber, plywood, drywall
- **Electrical**: Wiring, outlets, switches, circuit breakers
- **Plumbing**: Pipes, fittings, fixtures, water heaters
- **Garden & Outdoor**: Tools, fertilizers, irrigation, outdoor power equipment
- **Storage & Organization**: Shelving, bins, garage organization

### 🌡️ Seasonal Patterns

The dataset includes realistic seasonal variations:
- **Spring Surge**: Paint and garden products peak in March-May
- **Summer Construction**: Power tools and lumber peak in June-August
- **Fall Preparation**: Hardware and storage products increase
- **Winter Maintenance**: Hand tools and indoor projects

### 💰 Financial Modeling

- **Consistent 33% gross margin** across all products
- **Year-over-year growth patterns** (2020-2026)
- **Store performance variations** based on market size
- **Seasonal revenue fluctuations** aligned with product demand

📖 **[Read the Complete Dataset Documentation](database/data-generator/README.md)**

## Project Structure

```
ai-tour-26-zava-diy-dataset-plus-mcp/
├── .devcontainer/              # Dev container configuration
├── .vscode/                    # VS Code settings and MCP configuration
├── database/                   # PostgreSQL database and data generation
│   ├── data-generator/         # Database generator scripts
│   └── zava_retail_*.backup    # Database backup files
├── src/
│   ├── python/
│   │   ├── mcp_server/         # Model Context Protocol servers
│   │   │   ├── customer_sales/ # Customer product search MCP server
│   │   │   └── sales_analysis/ # Sales analytics MCP server
│   │   ├── web_app/           # Web application demos
│   │   └── workshop/          # Workshop and demo materials
│   └── shared/                # Shared utilities and resources
├── docs/                      # Documentation and guides
├── images/                    # Product images for the dataset
├── infra/                     # Infrastructure as Code
├── scripts/                   # Utility scripts
├── docker-compose.yml         # Multi-service development environment
├── pyproject.toml            # Python project configuration
└── README.md                 # This file
```

### Key Components

- **🐳 Dev Container**: Complete development environment with PostgreSQL, Python, and all dependencies
- **🔧 MCP Servers**: Two specialized servers for product search and sales analysis
- **🗄️ Database Generator**: Creates realistic retail data with seasonal patterns
- **📱 Web Applications**: Demo applications showcasing the dataset and MCP servers
- **🏗️ Infrastructure**: Azure deployment templates and configurations
- **📚 Documentation**: Comprehensive guides and API documentation

## Getting Started with the Project

1. **Set up the dev container** (see instructions above)
2. **Generate the database** using the data generator
3. **Start the MCP servers** using VS Code tasks or directly
4. **Explore the dataset** using the provided sample queries
5. **Build applications** using the MCP servers for AI-powered retail experiences

This project serves as both a learning resource and a foundation for building sophisticated retail AI applications with realistic data patterns and secure multi-tenant access controls.