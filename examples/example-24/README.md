# Example 24 - Authenticate Across an MCP Boundary

> **TL;DR:** Authenticate MCP requests, validate tokens on the server, and derive tool identity from trusted claims.

## What this example demonstrates

A console agent calls an ASP.NET Core MCP server that owns the fictional snack records and access checks.

1. **Token issuance:** The client's `/auth` command posts demo credentials to the server's `/auth` endpoint. ASP.NET Core `AddBearerToken` and `Results.SignIn` issue a protected, opaque bearer token with a five-minute lifetime.
2. **Authenticated MCP:** The client adds the token to its MCP transport's HTTP authorization header. `MapMcp("/mcp").RequireAuthorization()` rejects missing, invalid, or expired tokens.
3. **Server-owned identity:** A request-scoped `UserContext` reads the validated principal's `NameIdentifier` claim. The tool has no model-controlled identity argument.

The server uses stateless Streamable HTTP so each request resolves its own authenticated context. Tokens stay outside prompts and tool arguments. The client prints the discovered tool schema, not its access token.

## Requirements and configuration

Use the **.NET 10 SDK**. The server requires no Foundry settings. The client requires a tool-calling Responses API deployment configured through `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT`. The endpoint may be a Foundry resource or project URL; the client uses `/openai/v1`.

The server defaults to `http://localhost:5404`. The client's optional `SNACK_SERVER_URL` overrides that same default.

Only use the public demo accounts: `Alice` / `alice-snacks` and `Bob` / `bob-snacks`. Password input is visible. These are fictional fixtures, not a production credential store.

## Run and explore

Open two terminals at the repository root. Start the server:

```powershell
dotnet run --project examples\example-24\server\SnackMcpServer.csproj
```

In the terminal containing the Foundry environment variables, start the client:

```powershell
dotnet run --project examples\example-24\client\SnackAgentWithAuthenticatedMcp.csproj
```

Use `/auth`, sign in as Alice, and ask for your snack. Ask for Bob's record and inspect the server's identity-based lookup. Sign in as Bob to change identity and start a fresh conversation.

`/auth` discards the previous connection and conversation before attempting login; failure leaves you signed out. `/logout` discards them locally but does not revoke an already-issued token. `quit` or end-of-input exits; blank input is skipped. Stop the server with Ctrl+C.

If port 5404 is busy, start the server with `-- --urls http://localhost:5405` and set `$env:SNACK_SERVER_URL = "http://localhost:5405"` in the client terminal.

## Boundaries and limitations

An unauthenticated POST to `/mcp` should return HTTP 401:

```powershell
curl.exe -i -X POST http://localhost:5404/mcp -H "Content-Type: application/json" -d '{}'
```

Stateless MCP uses POST; an unauthenticated GET returns 405 rather than testing the same boundary. After token expiry, use `/auth` again: this client does not refresh tokens automatically.

The token protection is real ASP.NET Core authentication backed by Data Protection, not a source-embedded JWT signing secret. This example is not an OAuth/OIDC authorization server and does not implement MCP OAuth discovery, browser sign-in, consent, refresh, or revocation.

Loopback HTTP and public demo passwords are for local experimentation only. Do not expose this service publicly. A deployed system needs HTTPS, a suitable identity provider, scoped/audience-bound tokens, and resource authorization policies. Treat bearer tokens as secrets.

Foundry credentials stay in the client, while MCP tokens go to the server. Selected snack results and conversation messages still go to Foundry. Connection and service errors are reported explicitly.
