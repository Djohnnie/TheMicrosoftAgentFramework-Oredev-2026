# Example 02 - Simple Chatbot

> **TL;DR:** Connect to Azure OpenAI, use `IChatClient`, and call `GetResponseAsync`.

## What this example demonstrates

This console chatbot sends independent text requests to a Foundry-hosted Azure OpenAI deployment.

1. **Cloud connection:** A `ResponsesClient` uses an API-key credential and the resource's `/openai/v1` endpoint.
2. **Chat abstraction:** `AsIChatClient(model)` adapts that client to `IChatClient`, keeping provider-specific construction outside the input loop.
3. **Request and reply:** `GetResponseAsync(input)` sends the current text, and `response.Text` supplies the answer.

The application does not send previous messages. Saying "remember this" cannot create conversation context for the next independent request.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT` to the resource or project URL, `FOUNDRY_API_KEY` to its API key, and `FOUNDRY_MODEL_DEPLOYMENT` to the deployment name. The program replaces the endpoint path with `/openai/v1`.

Keep credentials outside source control. Configuration and request errors surface as exceptions.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-02\SimpleChatbot.csproj
```

Ask a question, then ask a follow-up referring to the first answer. The second call receives only the follow-up text, illustrating the stateless baseline. Blank input is skipped; `quit` or end-of-input exits.
