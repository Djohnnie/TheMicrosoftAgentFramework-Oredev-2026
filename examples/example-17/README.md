# Example 17 - Manual Multi-Agent Orchestration

> **TL;DR:** Give agents separate roles, pass one agent's output to another, and keep their sessions isolated.

## What this example demonstrates

A Founder proposes a deliberately terrible startup idea, and an Investor reviews it.

1. **Specialized agents:** Separate instructions define the pitch-writing and reviewing roles while using the same chat client.
2. **Explicit handoff:** Application code awaits the Founder and passes `pitch.Text` as the Investor's input.
3. **Isolated state:** Each agent receives its own fresh session for every theme. Earlier pitches and the other agent's private session history are not automatically shared.

The control flow is ordinary sequential C#, not an autonomous conversation or a workflow graph. The Investor sees the generated pitch because the application explicitly forwards it.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Each theme makes separate model requests for the Founder and Investor; both consume tokens.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-17\StartupPitchManual.csproj
```

Enter a theme such as "a subscription service for developers who forget to take breaks." The console prints the pitch and review. Repeat with another theme to see the isolated rounds. Blank input is skipped; `quit` or end-of-input exits. Model failures and empty agent outputs surface as errors.
