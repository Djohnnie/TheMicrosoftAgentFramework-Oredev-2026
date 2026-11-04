# Example 20 - Concurrent Agent Workflow

> **TL;DR:** Fan out one pitch to multiple reviewers, execute concurrently, and collect every result at a barrier.

## What this example demonstrates

One Founder creates a startup pitch for three Investor personas: Hype, Bootstrap, and Doomsday.

1. **Fan-out:** `AddFanOutEdge` sends the same Founder output to all three reviewers.
2. **Concurrent execution:** `InProcessExecution.Concurrent.RunStreamingAsync` runs independent branches. Factory-bound executors create the instances required by the concurrent environment.
3. **Fan-in:** `AddFanInBarrierEdge` routes the reviews to `CollectReviewsExecutor`, which emits an array only after all three distinct reviewers have contributed.

Each agent invocation creates a fresh session. The collector rejects duplicate reviewer results and sorts the final array by investor name. Completion events can arrive in a different order; the final output still includes all three reviews.

This combines parallel work, not shared agent memory or automatic consensus. The program does not ask a fourth agent to synthesize a decision.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. A theme requires one Founder request and three review requests; concurrency does not reduce their combined token usage and can encounter service rate limits.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-20\StartupPitchConcurrent.csproj
```

Enter a theme, watch reviewer completion messages, and compare their perspectives in the final output. Blank input is skipped; `quit` or end-of-input exits. Workflow errors and incomplete final output are surfaced explicitly.
