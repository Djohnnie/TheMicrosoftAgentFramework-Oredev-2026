# Example 23 - Trusted User Context for Tools

> **TL;DR:** Keep authenticated identity in application state and resolve it inside the tool, not from model-generated arguments.

## What this example demonstrates

The snack tool derives its owner from a scoped dependency-injected `UserContext`.

1. **Trusted context:** `/auth` verifies demo credentials and sets `UserContext.User` in application code.
2. **Injected identity:** `GetSecretSnack(IServiceProvider services)` resolves the context. The model-facing tool has no user-name or user-ID argument.
3. **Ownership enforcement:** The tool selects the record using the authenticated user's ID and rejects missing or unsupported identities.

A name claimed in conversation cannot replace the context used by the tool. Session history is also reset on authentication and logout so replies from one account do not remain in another account's conversation.

The context is scoped, not a mutable singleton shared across users. This demonstrates the trust boundary; it is not a production identity system.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting tool calling through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Use only the public demo accounts: `Alice` / `alice-snacks` or `Bob` / `bob-snacks`. Password input is visible. Never enter real credentials, deploy the hard-coded account store, or commit API keys.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-23\SnackAgentWithUserContext.csproj
```

Sign in with `/auth`, ask for your snack, then ask for the other user's snack. Inspect the tool log: lookup still uses the authenticated owner. Sign in as the other account and observe the new context and empty conversation.

`/auth` clears the old identity and session before checking credentials. `/logout` clears identity and starts a fresh session. Chatting requires sign-in; blank input is skipped and `quit` or end-of-input exits.

Selected results and messages still go to Foundry for inference. Configuration, service, and unauthorized tool-access failures surface as errors.
