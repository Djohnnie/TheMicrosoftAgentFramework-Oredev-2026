# Example 10 - Multimodal Audio

> **TL;DR:** Transcribe audio in its original language and translate spoken audio into English.

## What this example demonstrates

The application sends the bundled French recording, [`welcome-fr.wav`](welcome-fr.wav), to an Azure OpenAI Whisper deployment twice.

1. **Audio client:** `AzureOpenAIClient.GetAudioClient("whisper")` selects the audio deployment.
2. **Transcription:** `TranscribeAudioAsync` returns text in the language spoken in the recording.
3. **Translation:** `TranslateAudioAsync` processes the audio independently and produces English text.

Each operation opens a fresh file stream so it reads from the beginning. The recording is copied to the build output and found through `AppContext.BaseDirectory`. Its spoken greeting is simply sample input; the program does not capture microphone audio or synthesize speech.

These are direct audio SDK requests, not `AIAgent` calls or a conversation. Both return text. The local recording is uploaded to the service, so only use audio you have permission to send.

## Requirements and configuration

Use the **.NET 10 SDK** and an Azure OpenAI resource with a Whisper deployment supporting both operations.

| Variable | Value |
| --- | --- |
| `FOUNDRY_ENDPOINT` | Azure OpenAI resource endpoint, such as `https://<resource>.openai.azure.com/` |
| `FOUNDRY_API_KEY` | Resource API key |
| `FOUNDRY_MODEL_DEPLOYMENT` | Required by the current startup configuration check; see the deployment note below |

**Deployment selection:** The current code reads `FOUNDRY_MODEL_DEPLOYMENT` but calls `GetAudioClient("whisper")` with a fixed name. The deployed resource must therefore contain a deployment named `whisper`, or that call in `Program.cs` must be changed to your deployment name. Changing the environment variable alone does not select another deployment.

Unlike the text examples, this program passes the resource endpoint directly to `AzureOpenAIClient`; it does not normalize a Foundry project URL to `/openai/v1`. Keep credentials outside source control.

## Run and explore

From the repository root:

```powershell
dotnet run --project examples\example-10\MultimodalAudio.csproj
```

The program prints the French transcription and English translation, then waits for any key before exiting so the results stay visible when launched from the demo menu. The pause is skipped when standard input is redirected. Compare the meaning, names, and punctuation rather than assuming a fluent result is correct.

Changing the recording's file name or format also requires updating `Program.cs` and the project's copy entry. Configuration, file, unsupported-deployment, and API errors propagate as exceptions.
