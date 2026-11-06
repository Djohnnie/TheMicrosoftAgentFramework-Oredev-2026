using System.Collections.Concurrent;
using System.Diagnostics;
using System.Net.NetworkInformation;
using System.Text.Json;

namespace DemoLauncher;

internal static class DemoRunner
{
    public static async Task<int> BuildAsync(string root, IReadOnlyList<Example> examples, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        Console.WriteLine("Building all examples once. Subsequent launches will skip build and restore checks...");
        var projects = examples
            .SelectMany(example => example.ServerProject is { } server
                ? new[] { example.ClientProject, server }
                : new[] { example.ClientProject })
            .Select(project => Path.GetRelativePath(root, project))
            .Distinct()
            .ToArray();
        var filterPath = Path.Combine(Path.GetTempPath(), $"DemoLauncher-{Guid.NewGuid():N}.slnf");
        try
        {
            // Exclude the running launcher rather than trying to overwrite its executable.
            var filter = new { solution = new { path = Path.Combine(root, "exercises.slnx"), projects } };
            await File.WriteAllTextAsync(filterPath, JsonSerializer.Serialize(filter), cancellationToken);
            var info = new ProcessStartInfo("dotnet")
            {
                WorkingDirectory = root,
                UseShellExecute = false
            };
            info.ArgumentList.Add("build");
            info.ArgumentList.Add(filterPath);
            info.ArgumentList.Add("--nologo");
            info.ArgumentList.Add("--verbosity");
            info.ArgumentList.Add("minimal");
            using var build = Process.Start(info)
                ?? throw new InvalidOperationException("Could not start the example build.");
            try
            {
                await build.WaitForExitAsync(cancellationToken);
                return build.ExitCode;
            }
            finally
            {
                await StopAsync(build);
            }
        }
        finally
        {
            File.Delete(filterPath);
        }
    }

    public static async Task RunAsync(Example example, CancellationToken cancellationToken)
    {
        Process? server = null;
        var serverOutput = new ConcurrentQueue<string>();
        try
        {
            if (example.ServerProject is not null && example.ServerUrl is { } url)
            {
                if (IPGlobalProperties.GetIPGlobalProperties().GetActiveTcpListeners().Any(endpoint => endpoint.Port == url.Port))
                    throw new InvalidOperationException($"Port {url.Port} is already in use. Stop the existing server first; the launcher will not reuse or terminate it.");

                Console.WriteLine($"Starting MCP server at {url} ...");
                var serverInfo = CreateStartInfo(example.ServerProject);
                serverInfo.ArgumentList.Add("--no-launch-profile");
                serverInfo.ArgumentList.Add("--");
                serverInfo.ArgumentList.Add("--urls");
                serverInfo.ArgumentList.Add(url.AbsoluteUri);
                serverInfo.RedirectStandardInput = true;
                serverInfo.RedirectStandardOutput = true;
                serverInfo.RedirectStandardError = true;
                server = Process.Start(serverInfo)
                    ?? throw new InvalidOperationException("Could not start the MCP server.");
                server.OutputDataReceived += CaptureOutput;
                server.ErrorDataReceived += CaptureOutput;
                server.StandardInput.Close();
                server.BeginOutputReadLine();
                server.BeginErrorReadLine();
                await WaitForServerAsync(server, url, cancellationToken);
                Console.WriteLine("MCP server ready.\n");
            }

            cancellationToken.ThrowIfCancellationRequested();
            var clientInfo = CreateStartInfo(example.ClientProject);
            if (example.Number == 24)
            {
                // Override even a local launch profile so the client uses the server we own.
                clientInfo.ArgumentList.Add("--environment");
                clientInfo.ArgumentList.Add($"SNACK_SERVER_URL={example.ServerUrl!.AbsoluteUri}");
            }

            using var client = Process.Start(clientInfo)
                ?? throw new InvalidOperationException("Could not start the example.");
            try
            {
                var clientExit = client.WaitForExitAsync(cancellationToken);
                if (server is not null)
                {
                    var firstExit = await Task.WhenAny(clientExit, server.WaitForExitAsync(cancellationToken));
                    cancellationToken.ThrowIfCancellationRequested();
                    if (firstExit != clientExit)
                        throw new InvalidOperationException($"MCP server exited unexpectedly with code {server.ExitCode}.");
                }

                await clientExit;
                Console.WriteLine($"\nExample {example.Number:00} exited with code {client.ExitCode}.");
            }
            finally
            {
                await StopAsync(client);
            }
        }
        catch (Exception exception) when (exception is not OperationCanceledException)
        {
            if (server is not null)
            {
                if (server.HasExited)
                    await server.WaitForExitAsync();
                Console.Error.WriteLine("\nMCP server output (last 40 lines):");
                foreach (var line in serverOutput)
                    Console.Error.WriteLine(line);
            }
            throw;
        }
        finally
        {
            if (server is not null)
            {
                try
                {
                    await StopAsync(server);
                    Console.WriteLine("MCP server stopped.");
                }
                finally
                {
                    server.Dispose();
                }
            }
        }

        void CaptureOutput(object sender, DataReceivedEventArgs eventArgs)
        {
            if (eventArgs.Data is not { } line)
                return;
            serverOutput.Enqueue(line);
            while (serverOutput.Count > 40)
                serverOutput.TryDequeue(out _);
        }
    }

    private static ProcessStartInfo CreateStartInfo(string project)
    {
        var info = new ProcessStartInfo("dotnet")
        {
            WorkingDirectory = Path.GetDirectoryName(project)!,
            UseShellExecute = false
        };
        info.ArgumentList.Add("run");
        info.ArgumentList.Add("--project");
        info.ArgumentList.Add(project);
        info.ArgumentList.Add("--no-build");
        return info;
    }

    private static async Task WaitForServerAsync(Process server, Uri url, CancellationToken cancellationToken)
    {
        using var handler = new HttpClientHandler { UseProxy = false };
        using var http = new HttpClient(handler) { Timeout = TimeSpan.FromSeconds(2) };
        var elapsed = Stopwatch.StartNew();
        while (elapsed.Elapsed < TimeSpan.FromMinutes(2))
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (server.HasExited)
                throw new InvalidOperationException($"MCP server exited during startup with code {server.ExitCode}.");
            try
            {
                // A 404 at the root is sufficient: the HTTP host is accepting requests.
                using var response = await http.GetAsync(url, cancellationToken);
                if (!server.HasExited)
                    return;
            }
            catch (HttpRequestException)
            {
                // Connection refused is expected while dotnet starts the server.
            }
            catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
            {
                // Retry a timed-out readiness probe until the overall startup deadline.
            }
            await Task.Delay(200, cancellationToken);
        }
        throw new TimeoutException($"MCP server at {url} did not become ready within two minutes.");
    }

    private static async Task StopAsync(Process process)
    {
        if (!process.HasExited)
        {
            try
            {
                process.Kill(entireProcessTree: true);
            }
            catch (InvalidOperationException) when (process.HasExited)
            {
                // The process exited between the check and Kill.
            }
        }
        await process.WaitForExitAsync();
    }
}
