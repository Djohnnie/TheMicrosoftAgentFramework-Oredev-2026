# Enable GenAI in Your Applications

**Johnny Hooyberghs · Øredev 2026 · Malmö, Sweden**

This repository accompanies the talk **“Enable GenAI in your applications using .NET, Azure and the Microsoft Agent Framework.”** It introduces a practical path from familiar .NET applications to generative AI, cloud services, and agentic workflows.

Open the [offline slide preview](slides/index.html) to navigate all forty-eight slides with the arrow keys, or browse the individual slides below. Each slide includes a short takeaway and an explanation of its place in the presentation.

The 27 examples live in `examples\example-01` through `examples\example-27`. Open [`exercises.slnx`](exercises.slnx) for their individually named solution folders; each example's README describes its requirements and usage.

## Demo launcher

Run the interactive console menu from the repository root with the .NET 10 SDK:

```powershell
dotnet run --project examples\DemoLauncher\DemoLauncher.csproj
```

The Spectre.Console menu uses the presentation's lime accent, with arrow-key navigation, type-to-search, and an **Exit launcher** option. Press Enter to launch the highlighted example; MCP examples are labeled. Redirected or non-interactive terminals retain the numbered menu (`0` or `quit` exits).

Before showing the menu, the launcher builds all example projects and MCP servers once. It excludes its own running project from that build. Every subsequent selection uses `dotnet run --no-build`, so switching examples does not trigger build or restore checks. A failed or cancelled startup build exits without showing the menu.

Each example runs as a separate process in the same terminal, with its own project directory as its working directory. Exit the example normally to return to the menu, or press Ctrl+C to stop it. Ctrl+C at the menu exits the launcher.

The launcher reads example names and project paths from `exercises.slnx`; it does not duplicate or change the examples. Environment variables and each example's local launch profile continue to supply configuration. Foundry credentials, Ollama, model deployments, and other prerequisites described in the example READMEs are still required.

For examples 15 and 24, the launcher starts the matching MCP server on loopback ports 5285 and 5404, waits for HTTP readiness, then starts the client. It stops its server when the client exits, fails, or is cancelled. Server output is captured separately and shown if server startup or execution fails. An occupied port is reported rather than reusing or stopping someone else's server. Example 24's client is explicitly pointed at the managed local server, overriding `SNACK_SERVER_URL` for that child process only. Server launch profiles are skipped so their URLs cannot override the managed endpoints.

If everything is already built, you can skip the initial build as well:

```powershell
dotnet build exercises.slnx
dotnet run --project examples\DemoLauncher\DemoLauncher.csproj --no-build -- --no-build
```

The first `--no-build` skips building the launcher; the second skips its one-time example build. Both builds use Debug by default. Keep the repository and SDK available: this is a source-based launcher, not a bundle of the example executables. `dotnet run --no-build` still has some project-evaluation overhead.

Run `pwsh -File _tools\validate-demo-launcher.ps1` for isolated launcher checks using temporary local fixtures. These require ports 5285 and 5404 to be unused and do not call Foundry or need credentials.

## Presentation slides

### Slide 1 / Enable GenAI in your applications

> **TL;DR:** Build GenAI into your applications with .NET, Azure, and the Microsoft Agent Framework.

![Enable GenAI in your applications](slides/slide-01.svg)

The opening slide introduces Johnny Hooyberghs's Øredev 2026 session and its focus: **Enable GenAI in your applications using .NET, Azure and the Microsoft Agent Framework**. A central AI mark is connected to the application, cloud, and agent-framework labels, framing the talk around the technologies working together.

The visual identity follows Øredev's near-black and electric-lime palette, with Geist Mono, Inter, and Outfit typefaces. The 16:9 SVG is designed to be readable on a presentation screen.

### Slide 2 / Johnny Hooyberghs

> **TL;DR:** Meet your guide to building with .NET, Azure, and generative AI.

![Johnny Hooyberghs](slides/slide-02.svg)

The speaker introduction positions Johnny Hooyberghs as a developer, speaker, and trainer focused on practical software development. The .NET, Azure, and generative AI labels preview the areas brought together in the session.

Microsoft MVP recognition in Developer Technologies and Microsoft Azure, held since 2020, adds context to the speaker's community and technology background. A subtle silhouette of Belgium appears behind the text, recolored in Øredev's electric lime to complement the portrait and the slide's dark theme.

### Slide 3 / Scan to visit the repository

> **TL;DR:** Scan the QR code to open this repository and follow along.

![Scan to visit the repository](slides/slide-03.svg)

A large QR code links directly to the [presentation repository](https://github.com/Djohnnie/TheMicrosoftAgentFramework-Oredev-2026), where attendees can revisit the slides, resources, and updates. The code is embedded as a local SVG asset and is also clickable in the slide.

The charcoal layout pairs the call to action with the repository address for people viewing the deck on screen.

### Slides 4–8 / The evolution of AI

> **TL;DR:** Compare AI systems built from explicit rules, learned patterns, deep networks, and generative models.

![The evolution of AI](slides/slide-04.svg)
![Rules-based AI revealed](slides/slide-05.svg)
![Machine learning revealed](slides/slide-06.svg)
![Deep learning revealed](slides/slide-07.svg)
![Generative AI revealed](slides/slide-08.svg)

Five slides reveal the four cards one at a time, comparing explicit if-then rules, machine learning, deep neural networks, and generative models. The sequence describes a shift in approach without implying that newer methods replace every earlier one.

### Slides 9–14 / How large language models generate text

> **TL;DR:** An LLM tokenizes its input, predicts a distribution for the next token, and appends one token at a time.

![LLM generation: prompt and context](slides/slide-09.svg)
![LLM generation: tokenization](slides/slide-10.svg)
![LLM generation: embeddings](slides/slide-11.svg)
![LLM generation: next-token prediction](slides/slide-12.svg)
![LLM generation: selection and append](slides/slide-13.svg)
![LLM generation: context window and streaming](slides/slide-14.svg)

Six reveal states build the generation pipeline one box at a time, then add the context-window and streaming takeaways. The model considers the full context as it generates each token, and streaming lets applications display each token without waiting for the entire response.

### Slide 15: Example 01 Tokenization demo

![Example 01: Tokenization demo](slides/slide-15.svg)

> **TL;DR:** Request and response tokens, growing history, and language choices all affect usage.

The three blocks compare input and output token counts, show how conversation history increases context, and demonstrate that human and programming languages tokenize differently. Local tokenizer counts are estimates; API-reported usage is authoritative. See [Example 01](examples/example-01/README.md).

### Slides 16–21 / The Agent Framework

> **TL;DR:** Reveal the framework's agents, harness agents, workflows, integrations, and language support before building the next examples.

The six-slide sequence keeps the title, footer, and linked source in place as it reveals the overview, agents, harness agents, workflows, integrations, and .NET, Python, and Go (preview) support. It sits between Examples 01 and 02.

![Framework introduction](slides/slide-16.svg)
![Agents revealed](slides/slide-17.svg)
![Harness agents revealed](slides/slide-18.svg)
![Workflows revealed](slides/slide-19.svg)
![Integrations revealed](slides/slide-20.svg)
![Language support revealed](slides/slide-21.svg)

### Slide 22 / Example 02: Simple Chatbot

![Example 02: Simple Chatbot](slides/slide-22.svg)

> **TL;DR:** Connect to Azure OpenAI, use `IChatClient`, and call `GetResponseAsync`.

[Example 02](examples/example-02/README.md) connects a Foundry-hosted Azure OpenAI deployment through `ResponsesClient`, adapts it to `IChatClient`, and awaits a response with `GetResponseAsync`. The interface keeps provider-specific setup outside the chat loop. Each request is independent because no conversation history is supplied.

### Slide 23 / Example 03: Chatbot with History

![Example 03: Chatbot with History](slides/slide-23.svg)

> **TL;DR:** Store chat messages, send the full history, and append the assistant's replies.

[Example 03](examples/example-03/README.md) represents user and assistant turns as ordered `ChatMessage` objects. Each request includes earlier turns, and `response.Messages` is appended afterward so follow-up questions have context. This is application-managed history, not permanent model memory; restarting clears the conversation.

### Slide 24 / Example 04: Chatbot with Token Usage

![Example 04: Chatbot with Token Usage](slides/slide-24.svg)

> **TL;DR:** Measure input tokens, output tokens, and actual API-reported usage.

[Example 04](examples/example-04/README.md) reads `InputTokenCount` and `OutputTokenCount` from `response.Usage` after each reply. Input includes the conversation supplied to the model, while output covers generated tokens. These service-reported counts are distinct from local tokenizer estimates; missing usage is not reported as zero.

### Slide 25 / Example 05: Chatbot Personas

![Example 05: Chatbot Personas](slides/slide-25.svg)

> **TL;DR:** Use a system message to change the persona while retaining the conversation.

[Example 05](examples/example-05/README.md) places behavior instructions in a `ChatRole.System` message and changes the character's age after each reply. Replacing that message guides the next response without removing earlier user and assistant turns. The example separates persona instructions from conversation context.

### Slide 26 / Example 06: Structured Output

![Example 06: Structured Output](slides/slide-26.svg)

> **TL;DR:** Define a C# type, request JSON-schema output, and consume a typed result.

[Example 06](examples/example-06/README.md) defines an `Employee` and calls `GetResponseAsync<Employee>` with `useJsonSchemaResponseFormat` enabled. The response exposes a typed `Result` instead of prose that application code must parse. A predictable schema makes integration easier, but does not replace business validation of the generated values.

### Slide 27 / Example 07: Local Ollama Chatbot

![Example 07: Local Ollama Chatbot](slides/slide-27.svg)

> **TL;DR:** Replace the cloud provider with Ollama while keeping `IChatClient` and chat history.

[Example 07](examples/example-07/README.md) uses `OllamaApiClient` with the local `qwen2.5:7b` model. The same `IChatClient` abstraction, `GetResponseAsync` call, and message-history loop remain in place. Changing where inference happens does not remove the need to supply conversation context.

### Slide 28 / Example 08: Chatbot Agent

![Example 08: Chatbot Agent](slides/slide-28.svg)

> **TL;DR:** Create an `AIAgent`, reuse an `AgentSession`, and call `RunAsync`.

[Example 08](examples/example-08/README.md) wraps the chat client with `AsAIAgent` and adds a name and instructions. A reusable `AgentSession` holds local conversation history, and `RunAsync` lets the agent manage message updates instead of application code maintaining a list. The agent abstraction does not train or replace the underlying model.

### Slide 29 / Example 09: Multimodal Images

![Example 09: Multimodal Images](slides/slide-29.svg)

> **TL;DR:** Combine text and image content, using either an image URL or inline bytes.

[Example 09](examples/example-09/README.md) puts `TextContent` and an image attachment in the same `ChatMessage`. `UriContent` references a provider-reachable image, while `DataContent` supplies local bytes with their media type. Separate sessions keep the comparisons independent; attaching local bytes still sends the image to the model provider.

### Slide 30 / Example 10: Multimodal Audio

![Example 10: Multimodal Audio](slides/slide-30.svg)

> **TL;DR:** Use an audio client to transcribe speech and translate spoken audio into English.

[Example 10](examples/example-10/README.md) uses a Whisper audio client for two independent operations on a French recording. `TranscribeAudioAsync` preserves the spoken language, while `TranslateAudioAsync` produces English text directly from the audio. Each request gets a fresh stream; these are audio SDK calls rather than agent conversations.

### Slide 31 / Example 11: Chatbot Agent with Tools

![Example 11: Chatbot Agent with Tools](slides/slide-31.svg)

> **TL;DR:** Describe C# functions, register them as tools, and complete the function-call loop.

[Example 11](examples/example-11/README.md) exposes date and time methods through `AIFunctionFactory`, with names and descriptions that help the model select a tool. The invocation layer executes the selected C# function and returns its real result to the conversation. The model then uses that result to compose the answer.

### Slide 32 / Example 12: Local Chatbot with Tools

![Example 12: Local Chatbot with Tools](slides/slide-32.svg)

> **TL;DR:** Use a local model with the same tool contract and session-managed conversation.

[Example 12](examples/example-12/README.md) combines Ollama's local `IChatClient` implementation with the date and time functions. The agent still selects functions, receives their results, and retains chat and tool turns in its session. Tool use is an application integration pattern, not a feature restricted to cloud inference.

### Slide 33 / Example 13: Dependency Injection for Agent Tools

![Example 13: Dependency Injection for Agent Tools](slides/slide-33.svg)

> **TL;DR:** Register services, resolve them inside tools, and keep dependencies out of model arguments.

[Example 13](examples/example-13/README.md) registers `TimeProvider` with the service container and gives that provider to the agent. Tools receive `IServiceProvider` and resolve the clock when invoked, rather than reading the system clock directly. The application controls the dependency, enabling a test clock without making it a model-selected argument.

### Slide 34 / Example 14: Microsoft Learn MCP Agent

![Example 14: Microsoft Learn MCP Agent](slides/slide-34.svg)

> **TL;DR:** Connect to Microsoft Learn MCP, discover remote tools, and use their results in answers.

[Example 14](examples/example-14/README.md) connects an `McpClient` to Microsoft Learn over HTTP and discovers available functions with `ListToolsAsync`. Each `McpClientTool` can be supplied as an agent tool through the `AIFunction` abstraction. Selected calls travel through the live MCP connection, bringing documentation results into the conversation.

### Slide 35 / Example 15: Host Date and Time Tools with MCP

![Example 15: Host Date and Time Tools with MCP](slides/slide-35.svg)

> **TL;DR:** Host MCP tools in a server, discover them from a client, and call them across processes.

[Example 15](examples/example-15/README.md) separates date and time functions into an ASP.NET Core MCP server and a console agent client. The client discovers the server's tools instead of duplicating their implementation. Tool requests and results cross the MCP boundary while the server owns the code and its dependencies.

### Slide 36 / Example 16: Chatbot Agent with Tool Approval

![Example 16: Chatbot Agent with Tool Approval](slides/slide-36.svg)

> **TL;DR:** Gate functions with approval, review each proposed call, and resume with an explicit decision.

[Example 16](examples/example-16/README.md) wraps tools with `ApprovalRequiredAIFunction`, so a selected call returns `ToolApprovalRequestContent` before execution. The application presents the function name, call ID, and arguments for approval or denial. Returning the decision through the same session allows only approved calls to execute; a prompt alone cannot enforce that gate.

### Slide 37 / Example 17: Terrible Startup Pitch — Manual Orchestration

![Example 17: Manual Startup Pitch Orchestration](slides/slide-37.svg)

> **TL;DR:** Give two agents distinct roles, hand off results in C#, and isolate their sessions.

[Example 17](examples/example-17/README.md) gives a Founder agent the job of producing a fictional startup pitch and an Investor agent the job of reviewing it. Ordinary C# passes `pitch.Text` from one invocation to the next. Fresh, separate sessions keep each agent's instructions and each pitch round from leaking into the other.

### Slide 38 / Example 18: Terrible Startup Pitch — Agent Framework Workflow

![Example 18: Startup Pitch Workflow](slides/slide-38.svg)

> **TL;DR:** Wrap agents as executors, connect their steps with an edge, and observe workflow events.

[Example 18](examples/example-18/README.md) replaces the manual Founder-to-Investor handoff with a workflow graph. `PitchAgentExecutor` handles string input and output, while `WorkflowBuilder.AddEdge` routes the pitch to the review step. Execution events expose progress and outputs without changing the agents' responsibilities.

### Slide 39 / Example 19: Terrible Startup Pitch — Human Input Pauses

![Example 19: Human Input Pauses](slides/slide-39.svg)

> **TL;DR:** Insert a request port, pause for human input, and resume the same workflow run.

[Example 19](examples/example-19/README.md) places a `RequestPort<string, string>` between the Founder and Investor. A `RequestInfoEvent` lets the host present the pitch for human review or editing while the workflow waits. `SendResponseAsync` supplies the reviewed text and continues the existing run rather than starting the process again.

### Slide 40 / Example 20: Terrible Startup Pitch — Concurrent Investors

![Example 20: Concurrent Investors](slides/slide-40.svg)

> **TL;DR:** Fan out one pitch, review it concurrently, and collect every investor's response.

[Example 20](examples/example-20/README.md) sends the same Founder pitch to three investor personas with `AddFanOutEdge`. Independent sessions allow those branches to review it concurrently. A fan-in barrier and collector wait for all three reviews before yielding the combined result.

### Slide 41 / Example 21: A Name Is Not Authentication

![Example 21: A Name Is Not Authentication](slides/slide-41.svg)

> **TL;DR:** Chat claims are not identity, model-supplied names are untrusted, and tools need authorization.

[Example 21](examples/example-21/README.md) intentionally trusts a `userName` supplied by the model to retrieve a secret snack. Nothing verifies that the caller owns the name they typed, so another person's data can be exposed. The example demonstrates why identity and access checks cannot be delegated to conversational instructions.

### Slide 42 / Example 22: Authenticated, but Still Trusting a Tool Argument

![Example 22: Authenticated Caller and Tool Arguments](slides/slide-42.svg)

> **TL;DR:** Authenticate outside chat, distrust model-selected user IDs, and authorize tool actions in code.

[Example 22](examples/example-22/README.md) adds application sign-in but still asks the model to supply a `userId` argument to the tool. A prompt containing the authenticated ID does not prevent a different ID being selected. Authentication establishes who signed in; tool code must separately bind access to that verified identity.

### Slide 43 / Example 23: Trusted User Context Through Dependency Injection

![Example 23: Trusted User Context](slides/slide-43.svg)

> **TL;DR:** Scope trusted user context, inject it into tools, and enforce ownership at execution time.

[Example 23](examples/example-23/README.md) stores the authenticated caller in a scoped `UserContext` and resolves it inside the tool through dependency injection. No model-controlled identity parameter selects the owner. The tool rejects unauthenticated access, and changing identity resets the conversation to avoid carrying another user's context forward.

### Slide 44 / Example 24: Authenticate Across an MCP Boundary

![Example 24: Authenticate Across an MCP Boundary](slides/slide-44.svg)

> **TL;DR:** Authenticate the MCP client, validate tokens on the server, and derive server-owned identity.

[Example 24](examples/example-24/README.md) sends a bearer token in HTTP headers rather than model messages. Server authentication middleware validates it, and authorization protects the MCP endpoint. Tools derive their user context from validated claims, keeping ownership checks on the side of the boundary that holds the data.

### Slide 45 / Example 25: Chat with a Microsoft Foundry Prompt Agent

![Example 25: Microsoft Foundry Prompt Agent](slides/slide-45.svg)

> **TL;DR:** Authenticate with Entra, select a named agent version, and reuse a hosted conversation.

[Example 25](examples/example-25/README.md) authenticates an application with `ClientSecretCredential` and connects an `AIProjectClient` to an existing Foundry project. `AgentReference` selects a Prompt Agent by name and version; its instructions and tools remain hosted in Foundry. A conversation session is reused across `RunAsync` calls.

### Slide 46 / Example 26: Save and Restore a Local Agent Session

![Example 26: Save and Restore an Agent Session](slides/slide-46.svg)

> **TL;DR:** Serialize session state, restore it into a session, and manage the lifetime of persisted data.

[Example 26](examples/example-26/README.md) uses `SerializeSessionAsync` to capture a local session as JSON and `DeserializeSessionAsync` to restore it later. Explicitly saving allows conversation state to survive process exit, unlike an in-memory session alone. A new conversation and a saved snapshot have separate lifetimes, and stored chat data needs protection.

### Slide 47 / Example 27: Compact Local History with Summaries

![Example 27: Compact Local History](slides/slide-47.svg)

> **TL;DR:** Trigger compaction, summarize older turns, and balance context size against cost and lost detail.

[Example 27](examples/example-27/README.md) attaches `SummarizationCompactionStrategy` to the history provider and triggers reduction after more than three user turns. An additional model call summarizes older groups while preserving the newest two groups. Sending that summary with recent messages can reduce subsequent input, but summarization itself uses tokens and may discard details.

### Slide 48 / Thank you and questions

> **TL;DR:** Thank participants and invite questions.

![Thank you for joining](slides/slide-48.svg)

The closing slide thanks participants, opens the floor for questions, and keeps the repository QR code available for anyone who wants the slides and resources.
