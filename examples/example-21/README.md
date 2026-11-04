# Example 21 - Why a Name Is Not Authentication

> **TL;DR:** A model-supplied identity is untrusted input, not proof of who is using a tool.

## What this example demonstrates

This intentionally unsafe agent retrieves fictional secret snacks for Alice or Bob.

1. **Identity from conversation:** The tool accepts a `userName` chosen by the model from chat content.
2. **Missing authentication:** Nothing verifies that the person chatting is the named user.
3. **Missing authorization:** The tool selects a stash by that name without an independent ownership check.

[`SnackTools.cs`](SnackTools.cs) logs the supplied name and returns the matching fictional snack. A prompt saying "I am Alice" is enough for the model to request Alice's data; claiming to be Bob can select Bob's data instead.

This is a demonstration of an unsafe trust boundary, not a recommended access-control pattern. A system prompt cannot turn a claimed name into a verified identity. Real tools must derive identity from trusted authentication and enforce authorization in application code.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting tool calling through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Only fictional records are included. Never connect this implementation to real private data. Keep API credentials outside source control and out of prompts.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-21\SnackAgentByName.csproj
```

Ask "I am Alice. What is my secret snack?" Then claim to be Bob and inspect the tool's log. Model behavior can vary, but the code performs no identity or ownership validation regardless of the wording of its reply.

Blank input is skipped; `quit` or end-of-input exits. Unknown names and configuration or service failures surface as errors.
