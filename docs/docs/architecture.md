## Solution Architecture

In this workshop, you will create the Zava Sales Agent: a conversational agent designed to answer questions about sales data, generate charts, provide product recommendations, and support image-based product searches for Zava's retail DIY business.

## Components of the Agent App

1. **Microsoft Azure services**

    This agent is built on Microsoft Azure services.

      - **Generative AI model**: The underlying LLM powering this app is the [Azure OpenAI gpt-4o](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=global-standard%2Cstandard-chat-completions#gpt-4o-and-gpt-4-turbo){:target="_blank"} LLM.

      - **Control Plane**: The app and its architectural components are managed and monitored using the [Azure AI Foundry](https://ai.azure.com){:target="_blank"} portal, accessible via the browser.

2. **Azure AI Foundry (SDK)**

    The workshop is offered in [Python](https://learn.microsoft.com/python/api/overview/azure/ai-projects-readme?view=azure-python-preview&context=%2Fazure%2Fai-services%2Fagents%2Fcontext%2Fcontext){:target="_blank"} using the Azure AI Foundry SDK. The SDK supports key features of the Azure AI Agents service, including [Code Interpreter](https://learn.microsoft.com/azure/ai-services/agents/how-to/tools/code-interpreter?view=azure-python-preview&tabs=python&pivots=overview){:target="_blank"} and [Model Context Protocol (MCP)](https://modelcontextprotocol.io/){:target="_blank"} integration.

3. **Database**

    The app is powered by the Zava Sales Database, a [Azure Database for PostgreSQL flexible server](https://www.postgresql.org/){:target="_blank"} with pgvector extension containing comprehensive sales data for Zava's retail DIY operations. The database includes:

     - **8 stores** across Washington State, each with unique inventory and sales data
     - **50,000+ customer records** across Washington State and online
     - **400+ DIY products** including tools, outdoor equipment, and home improvement supplies
     - **400+ product images** linked to the database for image-based searches
     - **200,000+ order transactions** with detailed sales history
     - **3000+ inventory items** across multiple stores
     - **Vector embeddings** for product images enabling AI-powered similarity searches (encoded using [openai/clip-vit-base-patch32](https://huggingface.co/openai/clip-vit-base-patch32/blob/main/README.md){:target="_blank"})

     The database supports complex queries and analytics, enabling efficient access to sales, inventory, and customer data. PostgreSQL Row Level Security (RLS) restricts agents to only the data for their assigned stores, ensuring security and privacy.

     The Model Context Protocol (MCP) server securely provides structured access to this data by dynamically retrieving database schemas, generating, and executing optimized queries based on agent requests.

4. **MCP Server**

    The Model Context Protocol (MCP) server is a custom Python service that acts as a bridge between the agent and the PostgreSQL database. It handles:

     - **Schema Discovery**: Automatically retrieves database schemas to help the agent understand available data.
     - **Query Generation**: Transforms natural language requests into SQL queries.
     - **Tool Execution**: Executes SQL queries and returns results in a format the agent can use.
     - **Image Search**: Supports image-based product searches using vector embeddings.
     - **Time Services**: Provides time-related data for generating time-sensitive reports.

## Extending the Workshop Solution

The workshop solution is highly adaptable to various scenarios, such as customer support, by modifying the database and tailoring the Foundry Agent Service instructions to suit specific use cases. It is intentionally designed to be interface-agnostic, allowing you to focus on the core functionality of the AI Agent Service with MCP integration and apply the foundational concepts to build your own conversational agent.

## Best Practices Demonstrated in the App

The app also demonstrates some best practices for efficiency and user experience.

- **Asynchronous APIs**:
  In the workshop sample, both the Foundry Agent Service and PostgreSQL use asynchronous APIs, optimizing resource efficiency and scalability. This design choice becomes especially advantageous when deploying the application with asynchronous web frameworks like FastAPI, ASP.NET, Chainlit, or Streamlit.

- **Token Streaming**:
  Token streaming is implemented to improve user experience by reducing perceived response times for the LLM-powered agent app.
