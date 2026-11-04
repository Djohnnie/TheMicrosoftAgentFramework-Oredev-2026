# Example 08 - Chatbot Agent

> **TL;DR:** Create an `AIAgent`, reuse an `AgentSession`, and invoke it with `RunAsync`.

## What this example demonstrates

The application creates an instructed agent with a cheerful ten-year-old persona and local conversation state.

1. **Agent definition:** `AsAIAgent` wraps an `IChatClient` with a name, instructions, and an `InMemoryChatHistoryProvider`.
2. **Session state:** `CreateSessionAsync` creates an `AgentSession` that is reused across questions.
3. **Agent invocation:** `RunAsync(input, session)` lets the agent manage message history instead of manually appending each turn.

After each reply, `TryGetInMemoryChatHistory` prints the stored messages and their roles. History stays in the process, and `StoredOutputEnabled = false` disables server-side Responses storage. This does not make inference local: requests still go to Foundry.

The agent does not train a new model or create a hosted Foundry agent. Its persona stays at age 10, and it has no tools or workflow.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Configuration and service errors propagate as exceptions.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-08\ChatbotAgent.csproj
```

Ask a question and a contextual follow-up, then inspect the debug history. Restarting creates a new, empty session. Blank input is skipped; `quit` or end-of-input exits.
