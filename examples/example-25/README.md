# Example 25 - Chat with a Foundry Prompt Agent

> **TL;DR:** Authenticate an application, select a named agent version, and reuse a server-side conversation.

## What this example demonstrates

This console application calls an existing Microsoft Foundry Prompt Agent instead of defining its instructions and tools locally.

1. **Application identity:** `ClientSecretCredential` authenticates a Microsoft Entra application using tenant ID, client ID, and client secret.
2. **Versioned agent:** `AIProjectClient.AsAIAgent(new AgentReference(agentName, agentVersion))` selects an existing agent definition and pins its version.
3. **Hosted conversation:** `CreateConversationSessionAsync` creates a server-side conversation. Every subsequent `RunAsync` call reuses it.

The application prints the conversation ID and then waits for user input. It does not send an initial capabilities question. Nonempty response messages are printed as assistant output.

The model, instructions, and hosted tools are configured in Foundry. This program neither creates nor modifies the agent, and it uses the named/versioned Prompt Agent API rather than a classic `asst_...` agent ID.

## Requirements and configuration

Use the **.NET 10 SDK**, a Foundry project, an existing Prompt Agent version, and a Microsoft Entra application permitted to access that project.

| Variable | Value |
| --- | --- |
| `TENANT_ID` | App registration's directory/tenant ID |
| `CLIENT_ID` | App registration's application/client ID, not its object ID |
| `CLIENT_SECRET` | Client secret **value**, not the secret's ID |
| `FOUNDRY_ENDPOINT` | Full project endpoint, including `/api/projects/<project-name>` |
| `FOUNDRY_AGENT_NAME` | Existing Prompt Agent's name |
| `FOUNDRY_AGENT_VERSION` | Existing version in that project |

`FOUNDRY_API_KEY` and `FOUNDRY_MODEL_DEPLOYMENT` are not used. Do not use the resource root, `/openai/v1`, or a named agent's Responses URL as the project endpoint.

To obtain application credentials, create a single-tenant registration under **Microsoft Entra ID > App registrations** in the Azure portal. Copy its tenant and client IDs, then create a client secret under **Certificates & secrets** and securely retain the secret's value.

Registration alone does not grant Foundry access. At the project's **Access control (IAM)**, grant the application's service principal an appropriate role, such as **Foundry User** (formerly **Azure AI User**), at project scope. Assigning a role only to your personal account does not authorize the application; allow time for role assignments to propagate.

Directory and role-assignment operations require suitable permissions. Prefer least privilege and managed identity for deployed applications; the current code explicitly uses a client secret, not managed identity or `az login`.

## Run and explore

From the repository root in PowerShell:

```powershell
$env:TENANT_ID = "<directory-tenant-id>"
$env:CLIENT_ID = "<application-client-id>"
$env:FOUNDRY_ENDPOINT = "https://<resource>.services.ai.azure.com/api/projects/<project>"
$env:FOUNDRY_AGENT_NAME = "<agent-name>"
$env:FOUNDRY_AGENT_VERSION = "<existing-version>"
$env:CLIENT_SECRET = Read-Host "Client secret value" -MaskInput
try {
    dotnet run --no-launch-profile --project examples\example-25\FoundryAgent.csproj
}
finally {
    Remove-Item Env:\CLIENT_SECRET
}
```

`--no-launch-profile` keeps local profiles from overriding these values. The SDK obtains and refreshes access tokens; the program does not print them.

Ask a question and a contextual follow-up. Restart and compare the new conversation ID. Blank input is skipped; `quit` or end-of-input exits.

## State and credential handling

Each process run creates a new conversation, but exiting does not delete the stored server-side conversation. Use non-sensitive prompts and manage retained conversations according to project policies.

Never commit client secrets or include credentials in agent messages. Rotate or remove temporary secrets when finished. Authentication, missing-agent/version, and service errors propagate as exceptions rather than fabricated replies. The Foundry integration uses preview packages; retain compatible dependency versions.
