# Example 04 - Chatbot with Token Usage

> **TL;DR:** Read input and output token counts from API-reported usage instead of estimating them locally.

## What this example demonstrates

This chatbot retains conversation history and prints usage after each assistant reply.

1. **Input tokens:** `response.Usage.InputTokenCount` measures the input reported by the API, including the conversation supplied with that request.
2. **Output tokens:** `response.Usage.OutputTokenCount` measures generated output reported by the API.
3. **Authoritative usage:** Counts come from the service, not a local tokenizer. Missing values are displayed as `not reported`, not zero.

User messages are appended before the call, and `response.Messages` is appended afterward. As history grows, even a short new question can require more input tokens. The program does not calculate monetary cost or trim history.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The endpoint path becomes `/openai/v1`.

Keep credentials outside source control. Configuration and API failures propagate as exceptions.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-04\ChatbotWithTokenUsage.csproj
```

Compare usage for a short request, a long request, and several short follow-ups. Ask for a longer answer to observe output usage. History exists only in memory. Blank input is skipped; `quit` or end-of-input exits.
