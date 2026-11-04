# Example 18 - Sequential Agent Workflow

> **TL;DR:** Wrap agents in typed executors, connect them with an edge, and observe workflow events.

## What this example demonstrates

The Founder-to-Investor startup pitch is represented as an Agent Framework workflow instead of a manually coded handoff.

1. **Typed executors:** `PitchAgentExecutor : Executor<string, string>` runs an agent and returns its text. Each invocation creates a fresh session.
2. **Graph routing:** `WorkflowBuilder.AddEdge` connects Founder output to Investor input. The Investor is the workflow's output executor.
3. **Event stream:** `InProcessExecution.RunStreamingAsync` starts the graph. The application reads completion, output, and error events from `WatchStreamAsync`.

The graph determines execution order. The returned string is the explicit handoff between agents; their session histories remain separate. The event stream reports workflow progress, not token-by-token model output.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Every theme requires both a pitch-generation request and a review request.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-18\StartupPitchWorkflow.csproj
```

Enter a startup theme and follow the Founder completion and final Investor output. Each round creates a new workflow. Blank input is skipped; `quit` or end-of-input exits. Workflow errors and missing final output are surfaced explicitly.
