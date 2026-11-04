# Example 26 - Local Session Persistence

> **TL;DR:** Serialize an agent session, save it locally, and restore conversation context in a later run.

## What this example demonstrates

The agent keeps local chat history and exposes explicit commands for snapshotting and restoring it.

1. **Serialize state:** `SerializeSessionAsync(session)` produces a JSON snapshot of the session.
2. **Persist locally:** `/save` writes a temporary file and moves it over `session.json`, keeping the completed snapshot at a stable path.
3. **Restore context:** `/load` calls `DeserializeSessionAsync` and replaces the current session, rather than appending the saved messages to it.

The path is `session.json` under `AppContext.BaseDirectory`, typically the project's build-output directory. The console prints the exact path at startup; it is not a file in the terminal's current directory.

Persisting state does not persist the model or enable offline inference. New chat turns still go to Foundry. `StoredOutputEnabled = false` disables server-side Responses storage, not the transmission of history for inference.

## Requirements and configuration

Use the **.NET 10 SDK**, write access to the build-output directory, and a Foundry deployment supporting the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. Snapshots contain plaintext conversation data and should be treated as sensitive: do not commit them, share them casually, or load untrusted snapshots.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-26\SessionPersistence.csproj
```

Share a fictional fact, use `/save`, then restart the application and use `/load`. Ask a follow-up that depends on the saved fact.

| Command | Behavior |
| --- | --- |
| `/save` | Overwrite the saved snapshot with the current session |
| `/load` | Replace the current session with the saved snapshot and print its history |
| `/new` | Start an empty session without changing the saved file |
| `/history` | Print locally stored messages |
| `quit` | Exit without automatically saving |

A missing snapshot is reported without replacing the session. Blank input is skipped; end-of-input exits. File, deserialization, and service errors propagate explicitly. Session snapshots may depend on the SDK version; this example does not implement schema migration or encrypted storage.
