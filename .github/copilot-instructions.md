# Copilot instructions

## Build and validation

Run commands from the repository root:

```powershell
dotnet build exercises.slnx
dotnet run --project examples\example-01\TokenVisualizer.csproj
pwsh -File _tools\validate-slides.ps1
```

The .NET example requires the .NET 10 SDK and the `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` environment variables to make API requests. There is no automated test project or configured lint command; the PowerShell script validates the slide SVGs and shared presentation assets.

## Architecture

- The presentation is the repository's main deliverable. `README.md` is its written companion, `slides\index.html` is the offline browser navigator, `_resources\oredev-theme.css` styles that navigator, and each `slides\slide-NN.svg` is a standalone slide. `_resources\` contains shared artwork; `slides\slide-template.svg` is the source template for the shared slide frame.
- Slides 4–8, 9–14, and 16–21 are successive static reveal states, not one animated slide: each SVG contains the cumulative content for its position in the sequence. The browser navigator selects among the SVG files.
- `exercises.slnx` at the repository root organizes examples 01–27 into separate, descriptive solution folders. Example 01 appears on slide 15; the Agent Framework reveal sequence occupies slides 16–21; examples 02–27 appear on slides 22–47.
- `examples\example-01` is a separate .NET 10 console application. `Program.cs` owns chat history, requests, and local token counts; `FoundryEndpoint.cs` normalizes supported Foundry URLs to the OpenAI v1 endpoint; `TokenVisualizerUi.cs` renders the terminal interaction. Local history token counts are estimates; Responses API usage is authoritative.
- `_tools\validate-slides.ps1` checks both broad SVG requirements and presentation-specific structure and reveal states. Treat its assertions as part of the slide format.
- `.mcp.json` configures the Microsoft Learn MCP server for current Microsoft documentation lookup.

## Repository-specific conventions

- Keep slides at a `1920 1080` SVG `viewBox`, with accessible `<title>` and `<desc>`, the full-canvas dot pattern, and the shared header, logo, footer, and slide number. Slide 1 intentionally has exceptions to the standard footer and header; preserve its event branding and application-stack layout.
- For a slide sequence, keep each step as a separate SVG and use the existing labeled groups and `display:none` reveal states. Update `slides\index.html` slide metadata and navigation, the slide references in `README.md`, and `_tools\validate-slides.ps1` when changing the deck or its invariants.
- Each example slide presents three concrete teaching points in its three cards, not setup or execution instructions. Keep example numbers consistent across slides, `example-NN` directories, README references, and solution folders.
- Keep Foundry credentials in environment variables or an uncommitted local launch profile. The example uses the `FOUNDRY_MODEL_DEPLOYMENT` deployment name; its local `o200k_base` tokenizer is for comparison, not a substitute for API-reported usage.
