# Example 12 - Local Agent with Tools

> **TL;DR:** Use Ollama for agent reasoning while executing date and time tools in C#.

## What this example demonstrates

A locally hosted model can use the same agent and function-calling abstractions as a cloud model.

1. **Local inference:** `OllamaApiClient` implements `IChatClient` for `qwen2.5:7b` at `http://localhost:11434`.
2. **C# functions:** `AIFunctionFactory.Create` exposes the date and time methods, and `UseFunctionInvocation()` executes requested functions.
3. **Session history:** A reused `AgentSession` retains the exchange. Debug output shows tool calls and results alongside conversation messages.

The tools read the application machine's local clock. Model support and reliability matter: a tool being registered does not guarantee that the model requests it correctly. This example makes no Foundry requests and needs no Foundry credentials.

## Requirements and configuration

Use the **.NET 10 SDK**, install Ollama, and download the configured model:

```powershell
ollama pull qwen2.5:7b
```

Ollama must be listening on port 11434. If its service is not already running, start `ollama serve` in a separate terminal. The model name and server address are set in `Program.cs`; local inference requires sufficient memory and compute.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-12\LocalChatbotAgentWithTools.csproj
```

Ask for the current time or date and inspect whether the debug history records the expected function. History disappears when the process exits. Blank input is skipped; `quit` or end-of-input exits. Connection and inference failures propagate as exceptions.
