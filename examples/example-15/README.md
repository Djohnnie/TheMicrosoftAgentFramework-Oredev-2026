# Example 15 - Build and Consume an MCP Server

> **TL;DR:** Publish C# tools over MCP, inject server-side dependencies, and discover them from an agent client.

## What this example demonstrates

This example has two projects: an ASP.NET Core date/time MCP server and a console agent client.

1. **Publish tools:** The server registers MCP with HTTP transport, discovers its `DateTimeTools`, and maps `/mcp`.
2. **Inject dependencies:** Server-side tools use an injected `TimeProvider`. The date and time belong to the server's clock and timezone, not necessarily the client's.
3. **Consume remotely:** The client connects with Streamable HTTP, calls `ListToolsAsync`, and exposes the discovered tools to the agent.

The client does not invoke a shared C# method directly. MCP carries the function description, arguments, and result across the process boundary. The client prints discovered tools and local session history.

## Requirements and configuration

Use the **.NET 10 SDK**. The server requires no Foundry credentials. For the client, configure a Foundry deployment supporting tool calling through the Responses API:

| Variable | Value |
| --- | --- |
| `FOUNDRY_ENDPOINT` | Foundry resource or project URL; the client uses `/openai/v1` |
| `FOUNDRY_API_KEY` | Resource API key |
| `FOUNDRY_MODEL_DEPLOYMENT` | Deployment name |

Keep credentials outside source control. The client connects to `http://localhost:5285/mcp`, set directly in its `Program.cs`.

## Run and explore

Open two terminals at the repository root. Start the server with an explicit URL matching the client:

```powershell
dotnet run --project examples\example-15\server\DateTimeMcpServer.csproj -- --urls http://localhost:5285
```

In the terminal containing the Foundry environment variables:

```powershell
dotnet run --project examples\example-15\client\ChatbotAgentWithMcpServer.csproj
```

Ask for the current date or time and trace the result from server tool to agent answer. Blank input is skipped; `quit` or end-of-input exits the client. Stop the server with Ctrl+C.

The server has no authentication and uses loopback HTTP for local experimentation. Do not expose it publicly. Client requests and tool results are sent to Foundry, and connection or API failures propagate as exceptions.
