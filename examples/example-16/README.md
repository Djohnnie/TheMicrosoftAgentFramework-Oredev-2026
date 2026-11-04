# Example 16 - Human Approval for Tools

> **TL;DR:** Intercept tool calls, approve the exact request, and resume the same agent session with a correlated decision.

## What this example demonstrates

The agent can request date and time functions, but the application asks for permission before executing them.

1. **Approval boundary:** `ApprovalRequiredAIFunction` wraps each C# tool. A requested call produces `ToolApprovalRequestContent`.
2. **Informed decision:** The console shows the function name, call ID, and JSON arguments before collecting approval.
3. **Correlated continuation:** `request.CreateResponse(approved)` creates a decision for that specific call. `RunAsync` resumes the same session with those decisions.

A plain-text "yes" sent as a new prompt is not equivalent to approving the pending call. The continuation loop handles further approval requests until the agent produces its final reply.

The agent is instructed not to invent denied tool results or retry a denied call unless asked. Application-level approval, not that instruction alone, gates execution.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting tool calling through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Inference still goes to Foundry; approval controls the C# tool execution, not the preceding model request.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-16\ChatbotAgentWithApproval.csproj
```

Ask for the current time. Enter `yes` to allow a call, `no` or an empty line to deny it, and compare the resulting replies. Invalid decisions prompt again without submitting a choice.

At an approval prompt, `quit` or end-of-input exits without executing the pending batch. In the main input loop, blank input is skipped and `quit` or end-of-input exits. Configuration, service, and unexpected-response errors propagate explicitly.
