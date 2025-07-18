MCP (Model Context Protocol) is an emerging open standard that allows large-language models (LLMs) to call external tools, APIs, and data sources through a consistent, well-defined interface — similar to how USB-C standardizes device connections, or [ODBC](https://en.wikipedia.org/wiki/Open_Database_Connectivity){:target "_blank"} standardizes interfaces for databases.

## Benefits of MCP

- **Interoperability** – Connect an LLM to tools from any vendor that exposes an MCP interface, with little or no bespoke code.
- **Security hooks** – MCP includes hooks so you can plug in your own sign-in, permissions, and activity-logging systems.
- **Reusability** – Implement a tool once and reuse it across projects, clouds, and runtimes.
- **Operational simplicity** – When all parties adopt MCP, a single contract reduces boilerplate and lowers maintenance overhead.

## How MCP Works

MCP uses a client-server model to organize interactions between AI models and external resources:

- **MCP Host:** The runtime or platform where the LLM executes (e.g., Azure AI Foundry Agent Service).
- **MCP Client:** A library or SDK that converts the model’s tool calls or data queries into MCP‑formatted requests and forwards them to the server.
- **MCP Server:** A service that registers tools, executes them on request, and returns results in a standard JSON format; implementations can plug in authentication, authorization, and logging as needed.

### Real‑World Analogy: Restaurant Service

MCP works like a restaurant:

- **MCP Host:** The dining area where customers (AI models) order.
- **MCP Client:** The waiter who takes orders and delivers them in a standard format.
- **MCP Server:** The kitchen that prepares dishes (tools), checks for restrictions (auth/logging), and returns the meal.
- **MCP Tools/Data:** The dishes served to the customer.

Because orders are standardized, any chef (server) can fulfill them, and any customer (model) can order without custom instructions.

### Key Components on an MCP Server

- **Resources** – Data sources (databases, APIs, file stores) the server can query and return in a canonical format.
- **Tools** – Named functions or APIs registered with the server that it can execute on demand.
- **Prompts (optional)** – Versioned prompt templates the server can store for reuse across models or projects.
- **Policies (optional)** – Limits and safety checks (rate, depth, authentication) the server enforces around each tool call.

### Server Workflow

1. **Client sends a request to the model (host):** The end user or application submits a natural-language query or task to the AI model running in the MCP Host environment.
2. **Model requests tools/data from the MCP server:** The model analyzes the request and determines if it needs external data or tool execution. It formulates a tool call or data query, which the MCP Client forwards to the MCP Server.
3. **Server executes the tool, returns results in a standard format:** The MCP Server authenticates the request, runs the appropriate tool or data operation (e.g., database query, API call), and formats the output in a way the model can easily consume.
4. **Model incorporates results and responds to the client:** The model integrates the tool output or data into its response, generating a final answer or action that is sent back to the original client or user.

## Real-World Applications

- **Enterprise Data Integration:** Connect LLMs to databases, CRMs, internal tools
- **Agentic AI:** Enable autonomous agents with tool access
- **Multi-modal Apps:** Combine text, image, and audio tools
- **Live Data:** Bring real-time data into AI interactions

## MCP in the Zava Sales Agent

In this workshop, the MCP server connects the Azure AI Agent with Zava's sales data. When you ask about products, sales, or inventory:

1. The LLM generates MCP Server requests based on your query
1. The MCP Server:
      1. Provides schema info to help the LLM generate accurate queries
      2. Runs SQL queries and returns structured data for natural-language responses
      3. Provides time services for time-sensitive reports

<!-- 4. It enables image search via [pgvector](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-use-pgvector){:target="_blank"} -->

This lets the agent deliver real-time insights into Zava's sales operations efficiently.

## Architecture

```text
┌─────────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Azure AI Agent    │    │   MCP Client    │    │   MCP Server    │
│   (main.py)         │◄──►│ (mcp_client.py) │◄──►│ (mcp_server_sales_analysis.py) │
│                     │    └─────────────────┘    └─────────────────┘
│ ┌─────────────────┐ │                                   │
│ │ Azure AI        │ │                                   ▼
│ │ Agents Service  │ │                           ┌─────────────────┐
│ │ + Streaming     │ │                           │ Azure Database  │
│ │                 │ │                           │ for PostgreSQL  │
│ └─────────────────┘ │                           │       +         │
└─────────────────────┘                           │    pgvector     │
         │                                        └─────────────────┘
         ▼                                                │
┌─────────────────────┐                           ┌─────────────────┐
│ Azure OpenAI        │                           │ 8 Normalized    │
│ Model Deployment    │                           │ Tables with     │
│ (GPT-4, etc.)       │                           │ Performance     │
└─────────────────────┘                           │ Indexes         │
                                                  └─────────────────┘
```

This architecture shows how the Azure AI Agent interacts with the MCP Client and Server to access external data and tools, enabling powerful AI capabilities.
