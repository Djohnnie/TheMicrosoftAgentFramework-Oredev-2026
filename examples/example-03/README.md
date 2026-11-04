# Example 03 - Chatbot with History

> **TL;DR:** Store ordered chat messages, send the full history, and append the assistant's replies.

## What this example demonstrates

The chatbot maintains a conversation in a `List<ChatMessage>` so later questions can refer to earlier turns.

1. **Message roles:** Each user turn is a `ChatMessage` with `ChatRole.User`. Assistant replies retain the roles returned by the client.
2. **Full-context requests:** `GetResponseAsync(history)` receives the ordered conversation, not just the latest question.
3. **Complete history:** `history.AddRange(response.Messages)` adds the reply before the next request.

Conversation context belongs to the application. It is not model training or permanent memory. The list grows without trimming and disappears when the process exits.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Request and configuration failures propagate as exceptions.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-03\ChatbotWithHistory.csproj
```

Share a fictional fact, then ask a question that depends on it. Restart the application and ask again: the earlier conversation is no longer available. Blank input is skipped; `quit` or end-of-input exits.
