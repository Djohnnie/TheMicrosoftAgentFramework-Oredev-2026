# Example 11 - Agent with C# Tools

> **TL;DR:** Expose C# functions as tools, let the model request them, and return their results to the agent.

## What this example demonstrates

The agent answers questions about the current local date and time using application code rather than guessing from model knowledge.

1. **Tool definition:** [`DateTimeTools.cs`](DateTimeTools.cs) supplies methods with function names and descriptions. `AIFunctionFactory.Create` turns them into tool definitions.
2. **Tool execution:** `UseFunctionInvocation()` adds execution middleware to the `IChatClient` pipeline. The model requests a function; the application runs the C# method.
3. **Results in context:** The agent uses the tool result to compose a reply, and the debug view exposes function-call and function-result content in session history.

The functions read the machine's local clock and timezone. They are not a live web service, and registering a tool does not mean every prompt will call it. Tool descriptions guide selection; inspect the recorded calls to see what happened.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting tool calling through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Credentials must stay outside source control. History is local and in memory; inference and selected tool results still go to Foundry.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-11\ChatbotAgentWithTools.csproj
```

Ask "What time is it?" and "What is today's date?" Compare the replies with the tool history and local clock. Blank input is skipped; `quit` or end-of-input exits. Configuration and request errors propagate as exceptions.
