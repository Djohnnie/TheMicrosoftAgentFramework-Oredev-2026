# Example 01 - Token Visualizer

> **TL;DR:** Inspect request and response tokens, see history increase input size, and compare tokenization across languages.

## What this example demonstrates

The console application sends messages to Microsoft Foundry through the Responses API and displays the input and reply as colored token streams. It keeps the conversation in memory and compares local token estimates with usage reported by the service.

1. **Request and response:** Input and generated output contribute separately to token usage. The comparison table shows input, output, and total counts.
2. **Conversation history:** Each request includes the system instruction and previous user and assistant messages. A short follow-up can therefore carry substantially more input than its own text.
3. **Languages and code:** Natural languages, identifiers, punctuation, and programming languages split into different token sequences. A token is not necessarily a word or character.

## How it works

[`Program.cs`](Program.cs) owns the conversation and calls `CreateResponseAsync`. The local tokenizer uses the GPT-4.1 `o200k_base` encoding regardless of the configured deployment. Its history estimate adds three tokens per message and three reply-primer tokens; this is an approximation, not the Responses API's exact framing.

[`FoundryEndpoint.cs`](FoundryEndpoint.cs) accepts an HTTPS resource URL, an `/openai/v1` URL, or a supported Foundry `/api/projects/<project-name>` URL and resolves it to OpenAI v1. [`TokenVisualizerUi.cs`](TokenVisualizerUi.cs) renders the token streams and comparison table.

**API-reported usage is authoritative.** Different model tokenizers and request framing can make local counts differ from the service. This program displays token counts, not monetary charges.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set these environment variables in the terminal used to start the application:

| Variable | Value |
| --- | --- |
| `FOUNDRY_ENDPOINT` | Foundry resource URL, OpenAI v1 URL, or supported project URL |
| `FOUNDRY_API_KEY` | Resource API key |
| `FOUNDRY_MODEL_DEPLOYMENT` | Your deployment name, not necessarily the model catalog name |

Keep credentials in environment variables or an uncommitted local launch profile. Never include API keys in prompts or source control.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-01\TokenVisualizer.csproj
```

Send a question and a follow-up, then compare the message-only input with the full-history estimate and API usage. Try equivalent questions in different human languages or paste short C# and Python snippets.

Type `clear` to remove prior user and assistant turns while preserving the system instruction. Type `quit` to exit. History is not saved to a local file.

Missing or invalid configuration is reported before chatting. A failed API request is reported and its user turn is removed from history so you can try again.
