# Example 05 - Chatbot Personas

> **TL;DR:** Change the system instruction to guide a persona while preserving the conversation.

## What this example demonstrates

The chatbot role-plays a child whose age changes after each response.

1. **System instruction:** A `ChatRole.System` message describes the character's age, vocabulary, and behavior.
2. **Changing persona:** The first reply uses age 10, followed by 8, 6, 4, 2, and 0. Age stays at 0, where the instructions request short babbling sounds.
3. **Retained context:** The application replaces `history[0]` before each request while retaining earlier user and assistant messages.

The instructions guide the next response but do not modify model weights or guarantee compliance. Earlier replies remain in context even when the new persona calls for a different style.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Configuration and API failures propagate as exceptions.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-05\ChatbotPersonas.csproj
```

Ask the same explanatory question across several turns and compare vocabulary and response length as the displayed age changes. Restarting resets both history and age. Blank input is skipped; `quit` or end-of-input exits.
