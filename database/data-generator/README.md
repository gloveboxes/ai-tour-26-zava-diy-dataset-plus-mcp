# Zava DIY PostgreSQL Database Generator

This directory contains the PostgreSQL database generator for **Zava DIY**, a fictional home improvement retail company. The generator creates a comprehensive sales database with realistic retail data patterns, seasonal variations, and advanced features for data analysis and agentic applications.

## Overview

The database generator creates a complete retail ecosystem for Zava DIY, simulating a multi-store home improvement retailer with 8 locations across Washington State, including physical stores and online sales. The generated data supports advanced analytics, seasonal pattern analysis, and agentic applications.

## Generated Database Structure

### Core Tables

#### **Customers** (`retail.customers`)

- **50,000+ customer records** with realistic demographic data
- Customer information: names, emails, phone numbers, addresses
- Primary store assignments based on geographic distribution
- Supports customer segmentation and loyalty analysis

#### **Stores** (`retail.stores`)

- **8 retail locations** across Washington State:
  - Physical stores: Seattle, Bellevue, Tacoma, Spokane, Everett, Redmond, Kirkland
  - Online store: Zava Retail Online
- Each store has unique characteristics:
  - Customer distribution weights (traffic patterns)
  - Order frequency multipliers
  - Order value multipliers
- Row-Level Security (RLS) support for store manager access control

#### **Product Catalog** (`retail.categories`, `retail.product_types`, `retail.products`)

- **9 main product categories** with realistic home improvement inventory:
  - Hand Tools, Power Tools, Paint & Finishes, Hardware
  - Lumber & Building Materials, Electrical, Plumbing
  - Garden & Outdoor, Storage & Organization
- **Product hierarchy**: Categories → Product Types → Individual Products
- **Cost and pricing structure** with consistent 33% gross margin
- **Complete product specifications**: SKUs, descriptions, pricing

#### **Orders & Sales** (`retail.orders`, `retail.order_items`)

- **Historical transaction data** spanning 2020-2026
- **Order header** information: customer, store, date
- **Detailed line items**: products, quantities, prices, discounts
- **Variable order patterns** based on store characteristics and seasonality

#### **Inventory** (`retail.inventory`)

- **Store-specific stock levels** for all products
- **Seasonal inventory adjustments** based on demand patterns
- **Geographic distribution** reflecting local market preferences

#### **Product Embeddings** (`retail.product_embeddings`)

- **AI ready vector embeddings** for product images
- **512-dimensional vectors** using pgvector extension
- **Vector similarity search** capabilities for recommendation systems
- **Image metadata** and embedding relationships

## Key Data Features

### 📊 Seasonal Variations

The generator implements **Washington State seasonal multipliers** for realistic business patterns:

#### **Hand Tools**

- **Peak season**: May-August (1.4-1.6x normal volume)
- **Low season**: December (0.9x normal volume)
- **Pattern**: Spring/summer home improvement surge

#### **Power Tools**

- **Peak season**: June-July (2.0-2.1x normal volume)
- **Low season**: December-February (0.8-0.9x normal volume)
- **Pattern**: Strong summer construction activity

#### **Paint & Finishes**

- **Peak season**: April (2.2x normal volume)
- **Strong season**: March-August (1.6-2.0x normal volume)
- **Pattern**: Spring painting season with sustained summer activity

#### **Lumber & Building Materials**

- **Peak season**: June-July (2.1-2.2x normal volume)
- **Low season**: November-February (0.7-0.8x normal volume)
- **Pattern**: Construction/renovation season alignment

#### **Garden & Outdoor**

- **Extreme seasonality**: 50% of normal volume in winter
- **Peak season**: Spring through early fall
- **Pattern**: Weather-dependent outdoor activity

### 💰 Financial Structure

#### **Margin Analysis**

- **Consistent 33% gross margin** across all products
- **Cost basis**: JSON price data represents wholesale cost
- **Selling price calculation**: Cost ÷ 0.67 = Retail Price
- **Margin verification**: Built-in reporting and validation

#### **Revenue Patterns**

- **Year-over-year growth**: Configurable growth patterns (2020-2026) with consistent business expansion
- **Growth trajectory**: Steady increases year-over-year, except for 2023 which shows a slight decline reflecting market conditions
- **Store performance variation**: Based on location and market size
- **Seasonal revenue fluctuations**: Aligned with product demand cycles

### 🏪 Store Performance Characteristics

#### **High-Performance Stores**

- **Seattle**: 30% customer distribution, 3.0x order frequency, 1.3x order value
- **Bellevue**: 25% customer distribution, 2.6x order frequency, 1.2x order value
- **Online**: 30% customer distribution, 3.0x order frequency, 1.5x order value

#### **Regional Stores**

- **Tacoma**: 20% customer distribution, 2.4x order frequency, 1.1x order value
- **Spokane**: 8% customer distribution, 2.0x order frequency, 1.0x order value

#### **Specialty/Smaller Markets**

- **Everett, Redmond, Kirkland**: Lower distribution weights with adjusted multipliers
- **Geographic clustering**: Realistic market penetration patterns

### 🔒 Security & Access Control

#### **Row-Level Security (RLS)**

- **Store manager isolation**: Each manager sees only their store's data
- **Super manager access**: UUID `00000000-0000-0000-0000-000000000000` bypasses all restrictions
- **Secure multi-tenancy**: Perfect for workshop and demo scenarios
- **Policy coverage**: Orders, order items, inventory, customers

#### **Manager Access Patterns**

- **Unique UUIDs** for each store manager
- **Complete data isolation** between stores
- **Controlled access** to reference data (products, categories)

### 🚀 Advanced Features

#### **Vector Search Capabilities**

- **pgvector integration** for similarity search
- **Product image embeddings** for recommendation engines
- **Optimized vector indexes** for performance
- **512-dimensional embeddings** ready for ML applications

#### **Performance Optimization**

- **Comprehensive indexing strategy**: 20+ optimized indexes
- **Covering indexes** for common query patterns
- **Batch insert operations** for large data volumes
- **Query performance monitoring** and optimization

#### **Data Quality & Validation**

- **Built-in verification** routines for data consistency
- **Seasonal pattern validation** and reporting
- **Margin analysis** and financial reconciliation
- **Statistical summaries** and health checks

## Usage Examples

### Generate Complete Database

```bash
python generate_zava_postgres.py
```

### Show Database Statistics

```bash
python generate_zava_postgres.py --show-stats
```

### Populate Embeddings Only

```bash
python generate_zava_postgres.py --embeddings-only
```

### Verify Data Integrity

```bash
python generate_zava_postgres.py --verify-embeddings
```

## Technical Requirements

- **PostgreSQL 12+** with pgvector extension
- **Python 3.8+** with asyncpg, faker, python-dotenv
- **Database**: `zava` with `retail` schema
- **Memory**: Recommended 4GB+ for large datasets
- **Storage**: ~2GB for complete database with embeddings

## Configuration Files

### `product_data.json`

- Complete product catalog with categories and types
- Seasonal multiplier coefficients for each category
- Product specifications, pricing, and descriptions
- Image embedding data for AI/ML applications

### `reference_data.json`

- Store configurations and performance characteristics
- Customer distribution weights by store
- Year-over-year growth patterns and multipliers
- Store manager RLS UUID mappings

## Data Volume Summary

| Component | Count | Description |
|-----------|-------|-------------|
| **Customers** | 50,000+ | Realistic demographic profiles across Washington State and online |
| **Products** | 400+ | Complete DIY home improvement catalog (tools, outdoor equipment, supplies) |
| **Product Images** | 400+ | Product images linked to database for image-based searches |
| **Stores** | 8 | Physical + online locations across Washington State |
| **Orders** | 200,000+ | Multi-year transaction history with detailed sales data |
| **Inventory Items** | 3,000+ | Store-specific inventory across multiple locations |
| **Vector Embeddings** | 400+ | AI-powered similarity searches using OpenAI CLIP-ViT-Base-Patch32 |

This database provides a realistic foundation for retail analytics, machine learning experimentation, seasonal trend analysis, and multi-tenant application development in the home improvement industry. The database is powered by Azure Database for PostgreSQL flexible server with pgvector extension, enabling advanced AI-powered product similarity searches and comprehensive sales analytics.