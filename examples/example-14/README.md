# Example 14 - Microsoft Learn MCP Tools

> **TL;DR:** Connect to an MCP server, discover its tools, and make them available to an agent.

## What this example demonstrates

The application connects to the Microsoft Learn MCP endpoint at `https://learn.microsoft.com/api/mcp`.

1. **Remote connection:** `HttpClientTransport` uses Streamable HTTP, and `McpClient.CreateAsync` establishes the MCP client.
2. **Tool discovery:** `ListToolsAsync` retrieves tool names, descriptions, and schemas at runtime. The console lists the available tools.
3. **Agent integration:** Discovered `McpClientTool` instances are supplied as agent tools. Requested calls execute against the remote server.

The agent can use current documentation rather than relying only on model knowledge. Its local debug history includes tool interactions. The remote server controls the advertised tool set, which may change independently of this application.

Tool results are external data, not an authority to change application policy. Prompts go to Foundry, and tool queries go to Microsoft Learn; do not include sensitive data.

## Requirements and configuration

Use the **.NET 10 SDK**, network access to Microsoft Learn, and a Foundry deployment supporting tool calling through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

No separate MCP credential is configured for this endpoint. Keep Foundry credentials outside source control.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-14\ChatbotAgentWithLearnMcp.csproj
```

Ask a question about a Microsoft API or Azure service and inspect the discovered tools and debug history to see whether documentation was retrieved. Blank input is skipped; `quit` or end-of-input exits. MCP connection, discovery, and model errors propagate as exceptions.
