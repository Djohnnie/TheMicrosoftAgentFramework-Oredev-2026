# Example 06 - Structured Output

> **TL;DR:** Define a C# response type, request JSON-schema output, and consume a typed result.

## What this example demonstrates

The application generates a fictional adult employee rather than receiving an unrestricted prose answer.

1. **Response type:** [`Employee.cs`](Employee.cs) defines `Name`, `FirstName`, `BirthDate`, `Salary`, and `FunctionTitle`.
2. **Structured request:** `GetResponseAsync<Employee>(..., useJsonSchemaResponseFormat: true)` requests the shape described by that type.
3. **Typed consumption:** `response.Result` supplies an `Employee`, which the application serializes as indented JSON.

The prompt defines `Name` as the family name and `Salary` as annual gross salary in EUR. Each request is independent; there is no conversation history. A valid schema does not prove that values satisfy business rules, so applications should still validate generated data.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting JSON-schema structured output through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and deployment name. The endpoint path becomes `/openai/v1`.

Keep credentials outside source control. Configuration, schema, and service errors propagate as exceptions.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-06\StructuredOutput.csproj
```

Request a fictional senior C# developer or a junior designer and inspect the same fields in each result. Consider checks for adulthood, nonnegative salary, and nonempty names. Blank input is skipped; `quit` or end-of-input exits.
