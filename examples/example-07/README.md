# Example 07 - Local Ollama Chatbot

> **TL;DR:** Use a local model without changing the `IChatClient` conversation pattern.

## What this example demonstrates

The chatbot performs local inference through Ollama and retains its conversation in memory.

1. **Local provider:** `OllamaApiClient` connects to `http://localhost:11434` using `qwen2.5:7b`.
2. **Shared interface:** The client implements `IChatClient`, so the input loop still calls `GetResponseAsync`.
3. **Explicit history:** A `List<ChatMessage>` supplies earlier user and assistant turns on every call.

No Foundry endpoint, API key, or cloud model request is used. Local inference still requires sufficient memory and compute, and it still needs previous messages to answer contextual follow-ups.

## Requirements and configuration

Use the **.NET 10 SDK** and install Ollama. Download the model:

```powershell
ollama pull qwen2.5:7b
```

Ollama must be listening on port 11434. If its background service is not already running, start `ollama serve` in a separate terminal. The model name and URL are set directly in `Program.cs`.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-07\LocalChatbot.csproj
```

Share a fictional fact and ask a follow-up to observe retained context. Restarting clears the history. Blank input is skipped; `quit` or end-of-input exits. Connection and inference errors propagate as exceptions.
