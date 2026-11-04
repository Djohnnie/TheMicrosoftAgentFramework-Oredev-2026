# Example 13 - Dependency Injection in Tools

> **TL;DR:** Resolve tool dependencies from application services rather than model-generated arguments.

## What this example demonstrates

The date and time tools obtain their clock through .NET dependency injection.

1. **Service registration:** The application registers `TimeProvider.System` in a service collection.
2. **Dependency resolution:** The tool methods receive `IServiceProvider` and resolve `TimeProvider` with `GetRequiredService`.
3. **Agent integration:** The service provider is supplied when constructing the agent so tool invocation can use registered application services.

The clock is a trusted application dependency, not a value the model chooses. This separates infrastructure from tool logic and allows a different clock implementation to be registered without changing the model-facing task.

The session retains local history and prints tool interactions after replies. The service still receives prompts and selected results for cloud inference; local history does not mean local model execution.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting tool calling through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Missing configuration, missing service registrations, and API errors propagate as exceptions.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-13\ChatbotAgentWithDependencyInjection.csproj
```

Ask for the current local date or time and inspect the tool history. Trace the value from service registration to the C# tool result. Blank input is skipped; `quit` or end-of-input exits.
