## Lab 1: Getting Started with the Workshop

This is an example lab showing how content writers can create multi-language workshop content using MkDocs sticky tabs.

## What You'll Learn

In this lab, you will:

- Set up your development environment for the workshop
- Connect to the sample database and verify data access
- Create your first AI-powered application
- Understand the basic architecture of Model Context Protocol (MCP)
- Test your setup with simple queries and responses

## Introduction

The Model Context Protocol (MCP) is a standardized interface that connects Large Language Models (LLMs) to external tools and data sources—such as databases and APIs—enabling smarter, more extensible AI applications.

In this introductory lab, you will:

- Configure your development environment for either Python or C# development
- Connect to the Zava DIY retail database using MCP
- Create a basic agent that can query sales data
- Verify your setup is working correctly before moving to advanced topics

## Lab Exercise

In this lab, you'll set up your first MCP-enabled application and connect it to the sample database.

=== "Python"

    ### Step 1: Configure Your Python Environment

    1. Open the `src/python/workshop` folder in your workspace.

    2. Create a new file called `my_first_agent.py`:

        ```python
        import asyncio
        from mcp_client import MCPClient
        
        async def main():
            """Create your first MCP-enabled agent."""
            client = MCPClient()
            
            # Connect to the MCP server
            await client.connect("localhost:8000")
            
            # Test basic connectivity
            response = await client.query("SELECT COUNT(*) FROM products")
            print(f"Total products in database: {response}")
            
        if __name__ == "__main__":
            asyncio.run(main())
        ```

    ### Step 2: Test Your Connection

    1. Run your agent to test the connection:

        ```bash
        python my_first_agent.py
        ```

    2. You should see output showing the number of products in the database.

    ### Step 3: Add Basic Query Functionality

    1. Extend your agent with more sophisticated queries:

        ```python
        async def query_top_products():
            """Query the top-selling products."""
            query = """
            SELECT product_name, SUM(quantity) as total_sold 
            FROM sales_data 
            GROUP BY product_name 
            ORDER BY total_sold DESC 
            LIMIT 5
            """
            
            result = await client.query(query)
            print("Top 5 Products:")
            for row in result:
                print(f"- {row['product_name']}: {row['total_sold']} units")
        ```

=== "C#"

    ### Step 1: Configure Your C# Environment

    1. Open the `src/csharp/workshop` folder in your workspace.

    2. Create a new file called `MyFirstAgent.cs`:

        ```csharp
        using System;
        using System.Threading.Tasks;
        using McpClient;
        
        namespace Workshop
        {
            public class MyFirstAgent
            {
                private readonly MCPClient _client;
                
                public MyFirstAgent()
                {
                    _client = new MCPClient();
                }
                
                public async Task ConnectAsync()
                {
                    // Connect to the MCP server
                    await _client.ConnectAsync("localhost:8000");
                    
                    // Test basic connectivity
                    var response = await _client.QueryAsync("SELECT COUNT(*) FROM products");
                    Console.WriteLine($"Total products in database: {response}");
                }
                
                public static async Task Main(string[] args)
                {
                    var agent = new MyFirstAgent();
                    await agent.ConnectAsync();
                }
            }
        }
        ```

    ### Step 2: Test Your Connection

    1. Build and run your agent:

        ```bash
        dotnet run
        ```

    2. You should see output showing the number of products in the database.

    ### Step 3: Add Basic Query Functionality

    1. Extend your agent with more sophisticated queries:

        ```csharp
        public async Task QueryTopProductsAsync()
        {
            var query = @"
                SELECT product_name, SUM(quantity) as total_sold 
                FROM sales_data 
                GROUP BY product_name 
                ORDER BY total_sold DESC 
                LIMIT 5";
                
            var result = await _client.QueryAsync(query);
            Console.WriteLine("Top 5 Products:");
            foreach (var row in result)
            {
                Console.WriteLine($"- {row["product_name"]}: {row["total_sold"]} units");
            }
        }
        ```

## Run and Test Your Application

### For Python Users
1. Start the MCP server (if not already running):
   ```bash
   python mcp_server.py
   ```

2. In a new terminal, run your agent:
   ```bash
   python my_first_agent.py
   ```

### For C# Users
1. Start the MCP server (if not already running):
   ```bash
   dotnet run --project McpServer
   ```

2. In a new terminal, run your agent:
   ```bash
   dotnet run --project MyFirstAgent
   ```

## Verify Your Setup

You should see output similar to:
```
Total products in database: 150
Top 5 Products:
- Electrical Wire 12 AWG: 1,245 units
- Circuit Breaker 15A: 987 units
- PVC Conduit 1/2 inch: 856 units
- Electrical Tape: 743 units
- Wire Nuts (Assorted): 692 units
```

!!! success "Congratulations!"
    You've successfully set up your first MCP-enabled agent and connected to the workshop database. You're now ready to move on to more advanced topics in the next lab.

## Next Steps

In the next lab, you'll learn how to:
- Add AI capabilities to your agent
- Process natural language queries
- Generate dynamic responses based on data analysis
- Implement error handling and logging

## Troubleshooting

!!! warning "Common Issues"
    - **Connection refused**: Make sure the MCP server is running
    - **Database not found**: Verify your database connection string
    - **Permission denied**: Check your database credentials
    
    If you encounter issues, refer to the troubleshooting section or ask for help from the workshop facilitators.