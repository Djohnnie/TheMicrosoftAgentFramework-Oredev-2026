# Example 27 - Automatic History Compaction

> **TL;DR:** Trigger summarization of older history, preserve recent groups, and inspect the reduced session.

## What this example demonstrates

The agent replaces older conversation content with a model-generated summary to limit the context retained in its local session.

1. **Compaction trigger:** `CompactionTriggers.TurnsExceed(3)` evaluates whether more than three user turns are retained.
2. **Summarization policy:** `SummarizationCompactionStrategy` preserves at least the two newest groups and targets no more than two included non-system groups.
3. **History integration:** The strategy is installed as the in-memory history provider's `ChatReducer`, triggered `AfterMessageAdded`.

The strategy uses the same configured chat client for its summarization request. This is automatic history management, not just asking the assistant to summarize as a normal reply. The console prints stored messages and their text-character count after each answer; `/history` inspects them without making another chat request.

The trigger is evaluated as history changes, so do not equate every displayed message with a user turn or group. System instructions and summary content also affect the resulting context.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Both regular replies and summaries use cloud inference, with server-side Responses storage disabled. History stays in memory and is not saved across process runs.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-27\HistoryCompaction.csproj
```

Share several fictional facts across more than three turns. Inspect when older detail becomes a summary and recent exchanges remain available. Ask follow-up questions about both older and newer facts to assess what the summary preserved.

Type `/history` to inspect stored state or `quit` to exit. Blank input is skipped; end-of-input exits.

## Tradeoffs and limits

Compaction is experimental. Summarization makes an additional model request, so it consumes tokens and adds latency before any savings on later input. Character counts are not token-usage or cost measurements.

Summaries may omit or distort details. The instructions treat summary content as conversation data, not permission to override agent policy. The client rejects empty model text instead of treating it as a valid replacement; API errors are logged and surfaced. This example does not provide durable session storage or guaranteed lossless recall.
