# Example 22 - Sign-In Is Not Tool Authorization

> **TL;DR:** Authenticating a user does not secure a tool that still trusts a model-controlled user ID.

## What this example demonstrates

The application adds a demo login, but deliberately leaves the snack lookup vulnerable to selecting another owner.

1. **Application sign-in:** `/auth` checks public demo credentials and starts a fresh agent session for the selected user.
2. **Identity in the prompt:** Instructions tell the agent which user ID to supply to the tool.
3. **Untrusted tool argument:** `GetSecretSnack(string userId)` accepts that ID without checking it against authenticated application state.

The login is real application logic, but the lookup still uses a value the model can change. Instructions to supply the right ID are not an authorization check. The tool must enforce ownership independently of model behavior.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting tool calling through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

The public demo accounts are `Alice` / `alice-snacks` and `Bob` / `bob-snacks`. They map to `alice-001` and `bob-002`. Password input is visible; never enter real credentials or use this credential store in a deployed application.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-22\SnackAgentWithUserId.csproj
```

Use `/auth` and sign in as Alice, then ask for your snack. Inspect the logged `userId` and compare the code's behavior when the agent requests Bob's fictional record. A refusal by the model does not fix the missing ownership check.

`/auth` resets the previous conversation, and a failed sign-in leaves you signed out. `/logout` clears the agent and session. Chatting requires sign-in; blank input is skipped and `quit` or end-of-input exits.

Only fictional data should be used. Prompts and selected results go to Foundry; keep API keys outside source control. Unknown IDs and configuration or service failures surface as errors.
