# Example 19 - Human Input in a Workflow

> **TL;DR:** Pause a workflow at a request port, collect human input, and resume the same run.

## What this example demonstrates

The Founder creates a startup pitch, but the Investor cannot review it until a person accepts or replaces it.

1. **Request port:** `RequestPort.Create<string, string>("HumanInput")` sits between the Founder and Investor in the graph.
2. **External input:** A `RequestInfoEvent` exposes the pending pitch. The console lets a person keep or rewrite it.
3. **Resume in place:** `request.Request.CreateResponse(reviewedPitch)` correlates the answer, and `run.SendResponseAsync` continues the existing workflow.

Human input is a real graph boundary, not an instruction asking the model to pretend it obtained approval. The Investor receives the accepted or replacement text, and each agent invocation creates a fresh session.

The pause is in-process; this example does not persist a suspended workflow for recovery after application shutdown.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. The Founder request happens before the human pause; the Investor request happens only after a response is submitted.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-19\StartupPitchHumanInput.csproj
```

Enter a theme. At the pause, press Enter to keep the pitch or type replacement text. Type `quit` or end the input to stop without an Investor review.

In the main loop, blank input is skipped and `quit` or end-of-input exits. Workflow errors and missing final output surface explicitly.
