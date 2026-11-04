# Example 09 - Multimodal Images

> **TL;DR:** Combine text and image input, using a remote URL or inline image bytes.

## What this example demonstrates

An image-capable agent translates text in an image into English using two independently constructed requests.

1. **Multimodal message:** A `ChatMessage` combines `TextContent` with actual image content. A file path or URL written inside ordinary prompt text is not an image attachment.
2. **Remote image:** `UriContent` attaches a public JPEG URL with the `image/jpeg` media type.
3. **Inline image:** `DataContent` attaches bytes read from the bundled [`quote.jpg`](quote.jpg).

Each request gets a fresh session so the second translation cannot rely on the first image or answer. The instructions tell the agent to treat image text as data and acknowledge unreadable content rather than invent it.

This is image understanding, not image generation. Local bytes are uploaded to Foundry; do not attach private images without permission. The public URL must remain reachable by the model provider.

## Requirements and configuration

Use the **.NET 10 SDK** and a Foundry deployment supporting image input through the Responses API. Set `FOUNDRY_ENDPOINT`, `FOUNDRY_API_KEY`, and `FOUNDRY_MODEL_DEPLOYMENT` to the resource or project URL, resource key, and image-capable deployment name. The client uses `/openai/v1`.

Keep credentials outside source control. The project copies the JPEG to the output directory and resolves it through `AppContext.BaseDirectory`. If changing the file format, update the file name, project copy entry, and media type together.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-09\MultimodalImages.csproj
```

The program prints the URL-based and inline translations, then exits; there is no interactive input loop. Compare both outputs with the original image. Configuration, file, and API errors propagate as exceptions.
