$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$launcherProject = Join-Path $root 'examples\DemoLauncher\DemoLauncher.csproj'
$launcherDll = Join-Path $root 'examples\DemoLauncher\bin\Debug\net10.0\DemoLauncher.dll'
$fixture = Join-Path ([System.IO.Path]::GetTempPath()) "DemoLauncherValidation-$([guid]::NewGuid())"
$script:process = $null
$script:output = ''
$script:errors = $null

function Assert-PortFree([int] $Port) {
    if ([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners().Port -contains $Port) {
        throw "Port $Port is occupied. These checks require unused MCP ports and will not stop existing servers."
    }
}

function Start-Launcher([switch] $Build, [switch] $SkipMenu) {
    $info = [System.Diagnostics.ProcessStartInfo]::new('dotnet')
    $info.ArgumentList.Add($launcherDll)
    if (-not $Build) {
        $info.ArgumentList.Add('--no-build')
    }
    $info.WorkingDirectory = $fixture
    $info.UseShellExecute = $false
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $script:process = [System.Diagnostics.Process]::Start($info)
    $script:errors = $script:process.StandardError.ReadToEndAsync()
    $script:output = ''
    if (-not $SkipMenu) {
        if ($Build) { Wait-Text 'Building all examples once.' }
        Wait-Text 'Choose an example: '
    }
}

function Wait-Text([string] $Text) {
    $deadline = [datetime]::UtcNow.AddSeconds(30)
    $buffer = [char[]]::new(1)
    while (-not $script:output.Contains($Text)) {
        $read = $script:process.StandardOutput.ReadAsync($buffer, 0, 1)
        $remaining = [int][Math]::Max(1, ($deadline - [datetime]::UtcNow).TotalMilliseconds)
        if (-not $read.Wait($remaining)) {
            throw "Timed out waiting for '$Text'. Output: $script:output"
        }
        if ($read.Result -eq 0) {
            throw "Launcher exited while waiting for '$Text'. Output: $script:output Errors: $($script:errors.GetAwaiter().GetResult())"
        }
        $script:output += $buffer[0]
    }
    $script:output = ''
}

function Send-Line([string] $Text) {
    $script:process.StandardInput.WriteLine($Text)
    $script:process.StandardInput.Flush()
}

function Stop-Launcher {
    if ($script:process) {
        try {
            if (-not $script:process.HasExited) {
                $script:process.Kill($true)
            }
            $script:process.WaitForExit()
        }
        finally {
            $script:process.Dispose()
            $script:process = $null
        }
    }
}

try {
    Assert-PortFree 5285
    Assert-PortFree 5404
    dotnet build $launcherProject --nologo -v quiet
    if ($LASTEXITCODE -ne 0) { throw 'Launcher build failed.' }

    New-Item -ItemType Directory -Path (Join-Path $fixture 'client'), (Join-Path $fixture 'server'), (Join-Path $fixture 'cancellation'), (Join-Path $fixture 'menu') | Out-Null
    @'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
'@ | Set-Content (Join-Path $fixture 'client\Client.csproj')
    @'
Console.WriteLine($"FIXTURE cwd={Environment.CurrentDirectory}");
Console.WriteLine($"FIXTURE snack={Environment.GetEnvironmentVariable("SNACK_SERVER_URL")}");
Console.WriteLine("FIXTURE ready");
if (Environment.GetEnvironmentVariable("DEMO_LAUNCHER_TEST_WAIT_FILE") is { } readyFile)
{
    File.WriteAllText(readyFile, "ready");
    await Task.Delay(Timeout.Infinite);
}
return Console.ReadLine() == "fail" ? 7 : 0;
'@ | Set-Content (Join-Path $fixture 'client\Program.cs')
    @'
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
'@ | Set-Content (Join-Path $fixture 'server\Server.csproj')
    @'
if (Environment.GetEnvironmentVariable("DEMO_LAUNCHER_TEST_FAIL_SERVER") == "1")
    throw new InvalidOperationException("FIXTURE server startup failure");
if (Environment.GetEnvironmentVariable("DEMO_LAUNCHER_TEST_DELAY_SERVER") == "1")
    await Task.Delay(TimeSpan.FromSeconds(30));
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
app.MapGet("/pid", () => Environment.ProcessId);
app.Run();
'@ | Set-Content (Join-Path $fixture 'server\Program.cs')
    @'
<Solution>
  <Folder Name="/Example 01 - Console fixture/">
    <Project Path="client/Client.csproj" />
  </Folder>
  <Folder Name="/Example 15 - MCP fixture/">
    <Project Path="server/Server.csproj" />
    <Project Path="client/Client.csproj" />
  </Folder>
  <Folder Name="/Example 24 - Authenticated MCP fixture/">
    <Project Path="server/Server.csproj" />
    <Project Path="client/Client.csproj" />
  </Folder>
</Solution>
'@ | Set-Content (Join-Path $fixture 'exercises.slnx')
    Copy-Item (Join-Path $fixture 'client\Client.csproj') (Join-Path $fixture 'cancellation\Cancellation.csproj')
    @'
using System.Reflection;

var assembly = Assembly.LoadFrom(args[0]);
var root = args[1];
var example = Activator.CreateInstance(assembly.GetType("DemoLauncher.Example")!,
    15, "Cancellation fixture", Path.Combine(root, "client", "Client.csproj"),
    Path.Combine(root, "server", "Server.csproj"), new Uri("http://localhost:5285"))!;
var runMethod = assembly.GetType("DemoLauncher.DemoRunner")!.GetMethod("RunAsync")!;
Task Run(CancellationToken token) => (Task)runMethod.Invoke(null, new object[] { example, token })!;

var readyFile = Path.Combine(root, "client-ready");
Environment.SetEnvironmentVariable("DEMO_LAUNCHER_TEST_WAIT_FILE", readyFile);
using (var cancellation = new CancellationTokenSource(TimeSpan.FromSeconds(30)))
{
    var run = Run(cancellation.Token);
    while (!File.Exists(readyFile))
    {
        if (run.IsCompleted)
            throw new InvalidOperationException("Example exited before the cancellation check.");
        await Task.Delay(50, cancellation.Token);
    }
    cancellation.Cancel();
    try { await run; throw new InvalidOperationException("Running example was not cancelled."); }
    catch (OperationCanceledException) when (cancellation.IsCancellationRequested) { }
}
Environment.SetEnvironmentVariable("DEMO_LAUNCHER_TEST_DELAY_SERVER", "1");
using (var cancellation = new CancellationTokenSource(TimeSpan.FromSeconds(1)))
{
    try { await Run(cancellation.Token); throw new InvalidOperationException("Startup was not cancelled."); }
    catch (OperationCanceledException) when (cancellation.IsCancellationRequested) { }
}
Console.WriteLine("Cancellation cleanup checks passed.");
'@ | Set-Content (Join-Path $fixture 'cancellation\Program.cs')
    @'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Spectre.Console.Testing" Version="0.57.2" />
  </ItemGroup>
</Project>
'@ | Set-Content (Join-Path $fixture 'menu\Menu.csproj')
    @'
using System.Collections;
using System.Reflection;
using Spectre.Console;
using Spectre.Console.Testing;

var assembly = Assembly.LoadFrom(args[0]);
var exampleType = assembly.GetType("DemoLauncher.Example")!;
var examples = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(exampleType))!;
foreach (var number in Enumerable.Range(1, 27))
    examples.Add(Activator.CreateInstance(exampleType, number,
        number == 1 ? "Console [literal]" : $"Example {number:00}", "client.csproj",
        number is 15 or 24 ? "server.csproj" : null, null));
var createPrompt = assembly.GetType("DemoLauncher.LauncherMenu")!
    .GetMethod("CreatePrompt", BindingFlags.NonPublic | BindingFlags.Static)!;

void Check(int expected, Action<TestConsole> input)
{
    using var console = new TestConsole();
    console.Profile.Capabilities.Interactive = true;
    console.Profile.Width = 120;
    input(console);
    var prompt = (SelectionPrompt<int>)createPrompt.Invoke(null, new object[] { examples })!;
    var actual = console.Prompt(prompt);
    if (actual != expected)
        throw new InvalidOperationException($"Menu selected {actual} instead of {expected}.");
    if (expected == 1 && !console.Output.Contains("Console [literal]"))
        throw new InvalidOperationException("Example titles were interpreted as markup.");
    if (expected == 15 && !console.Output.Contains("[MCP server]"))
        throw new InvalidOperationException("MCP server badge is missing.");
}

Check(1, console => console.Input.PushKey(ConsoleKey.Enter));
Check(15, console =>
{
    for (var index = 0; index < 14; index++)
        console.Input.PushKey(ConsoleKey.DownArrow);
    console.Input.PushKey(ConsoleKey.Enter);
});
Check(27, console =>
{
    for (var index = 0; index < 26; index++)
        console.Input.PushKey(ConsoleKey.DownArrow);
    console.Input.PushKey(ConsoleKey.Enter);
});
Check(24, console =>
{
    console.Input.PushText("24");
    console.Input.PushKey(ConsoleKey.Enter);
});
Check(0, console =>
{
    console.Input.PushKey(ConsoleKey.UpArrow);
    console.Input.PushKey(ConsoleKey.Enter);
});
Console.WriteLine("Spectre menu checks passed: navigation, paging, search, exit, MCP badges, and literal titles.");
'@ | Set-Content (Join-Path $fixture 'menu\Program.cs')
    dotnet run --project (Join-Path $fixture 'menu\Menu.csproj') -- $launcherDll
    if ($LASTEXITCODE -ne 0) { throw 'Spectre menu checks failed.' }
    foreach ($project in @('client\Client.csproj', 'server\Server.csproj')) {
        dotnet build (Join-Path $fixture $project) --nologo -v quiet
        if ($LASTEXITCODE -ne 0) { throw "Fixture build failed: $project" }
    }

    $solutionPath = Join-Path $fixture 'exercises.slnx'
    $clientSourcePath = Join-Path $fixture 'client\Program.cs'
    $serverSourcePath = Join-Path $fixture 'server\Program.cs'
    $originalSolution = Get-Content $solutionPath -Raw
    $originalClient = Get-Content $clientSourcePath -Raw
    $originalServer = Get-Content $serverSourcePath -Raw
    New-Item -ItemType Directory -Path (Join-Path $fixture 'excluded') | Out-Null
    Copy-Item (Join-Path $fixture 'client\Client.csproj') (Join-Path $fixture 'excluded\Excluded.csproj')
    '#error The running launcher project must not be built.' | Set-Content (Join-Path $fixture 'excluded\Program.cs')
    try {
        @'
<Solution>
  <Folder Name="/Example 15 - Startup build fixture/">
    <Project Path="server/Server.csproj" />
    <Project Path="client/Client.csproj" />
  </Folder>
  <Folder Name="/Demo Launcher/">
    <Project Path="excluded/Excluded.csproj" />
  </Folder>
</Solution>
'@ | Set-Content $solutionPath
        $originalClient.Replace('FIXTURE ready', 'FIXTURE startup-built ready') | Set-Content $clientSourcePath
        Start-Launcher -Build
        '#error Selected examples must not be rebuilt.' | Add-Content $clientSourcePath
        '#error MCP servers must not be rebuilt.' | Add-Content $serverSourcePath
        foreach ($attempt in 1..2) {
            Send-Line '15'
            Wait-Text 'MCP server ready.'
            Wait-Text 'FIXTURE startup-built ready'
            Send-Line 'quit'
            Wait-Text 'Example 15 exited with code 0.'
            Wait-Text 'MCP server stopped.'
            Wait-Text 'Choose an example: '
        }
        Send-Line '0'
        if (-not $script:process.WaitForExit(10000)) { throw 'Launcher did not exit after startup-build checks.' }
        if ($script:process.ExitCode -ne 0) { throw 'Startup-build launcher failed.' }
        Stop-Launcher

        Start-Launcher -Build -SkipMenu
        $failedBuildOutput = $script:process.StandardOutput.ReadToEndAsync()
        if (-not $script:process.WaitForExit(30000)) { throw 'Failed startup build did not exit.' }
        if ($script:process.ExitCode -eq 0 -or $failedBuildOutput.GetAwaiter().GetResult().Contains('Choose an example: ')) {
            throw 'The launcher must fail before showing the menu when its startup build fails.'
        }
        if (-not $script:errors.GetAwaiter().GetResult().Contains('Example build failed.')) {
            throw 'The startup build failure was not reported.'
        }
        Stop-Launcher
    }
    finally {
        Stop-Launcher
        $originalSolution | Set-Content $solutionPath
        $originalClient | Set-Content $clientSourcePath
        $originalServer | Set-Content $serverSourcePath
        dotnet build (Join-Path $fixture 'client\Client.csproj') --nologo -v quiet
        if ($LASTEXITCODE -ne 0) { throw 'Could not restore the client fixture.' }
    }

    Start-Launcher
    Send-Line 'invalid'
    Wait-Text 'Enter an example number'
    Wait-Text 'Choose an example: '
    Send-Line '1'
    Wait-Text "FIXTURE cwd=$(Join-Path $fixture 'client')"
    Wait-Text 'FIXTURE ready'
    Send-Line 'fail'
    Wait-Text 'Example 01 exited with code 7.'
    Wait-Text 'Choose an example: '

    foreach ($example in @(15, 24)) {
        Send-Line "$example"
        Wait-Text 'MCP server ready.'
        if ($example -eq 24) { Wait-Text 'FIXTURE snack=http://localhost:5404/' }
        Wait-Text 'FIXTURE ready'
        Send-Line 'quit'
        Wait-Text "Example $example exited with code 0."
        Wait-Text 'MCP server stopped.'
        Wait-Text 'Choose an example: '
        Assert-PortFree $(if ($example -eq 15) { 5285 } else { 5404 })
    }

    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 5285)
    $listener.Start()
    try {
        Send-Line '15'
        Wait-Text 'Choose an example: '
        # stderr is asynchronous, so inspect it after exiting the launcher.
        Send-Line '0'
        if (-not $script:process.WaitForExit(10000)) { throw 'Launcher did not exit.' }
        if (-not $script:errors.GetAwaiter().GetResult().Contains('Port 5285 is already in use')) {
            throw 'The occupied port was not reported.'
        }
        if (-not $listener.Server.IsBound) { throw 'The existing listener was disturbed.' }
    }
    finally { $listener.Stop() }
    Stop-Launcher

    Start-Launcher
    Send-Line '15'
    Wait-Text 'MCP server ready.'
    Wait-Text 'FIXTURE ready'
    $serverPid = Invoke-RestMethod 'http://localhost:5285/pid' -NoProxy
    Stop-Process -Id $serverPid
    Wait-Text 'MCP server stopped.'
    Wait-Text 'Choose an example: '
    Assert-PortFree 5285
    Send-Line '0'
    if (-not $script:process.WaitForExit(10000)) { throw 'Launcher did not exit after server failure.' }
    if (-not $script:errors.GetAwaiter().GetResult().Contains('MCP server exited unexpectedly')) {
        throw 'Unexpected server termination was not reported.'
    }
    Stop-Launcher

    $env:DEMO_LAUNCHER_TEST_FAIL_SERVER = '1'
    try {
        Start-Launcher
        Send-Line '15'
        Wait-Text 'MCP server stopped.'
        Wait-Text 'Choose an example: '
        Send-Line '0'
        if (-not $script:process.WaitForExit(10000)) { throw 'Launcher did not exit after startup failure.' }
        $errors = $script:errors.GetAwaiter().GetResult()
        if (-not $errors.Contains('FIXTURE server startup failure') -or -not $errors.Contains('exited during startup')) {
            throw 'Server startup failure and diagnostic output were not reported.'
        }
    }
    finally { Remove-Item Env:\DEMO_LAUNCHER_TEST_FAIL_SERVER }
    Assert-PortFree 5285
    Assert-PortFree 5404
    Stop-Launcher
    dotnet run --project (Join-Path $fixture 'cancellation\Cancellation.csproj') -- $launcherDll $fixture
    if ($LASTEXITCODE -ne 0) { throw 'Cancellation cleanup checks failed.' }
    Assert-PortFree 5285
    Assert-PortFree 5404
    Write-Host 'Demo launcher checks passed: one-time startup build, launcher exclusion, build failure handling, build-free repeat launches, skip flag, menu, working directory, child exit codes, both MCP lifecycles, port conflicts, unexpected server exit, startup diagnostics, and cancellation cleanup.'
}
finally {
    Stop-Launcher
    if (Test-Path -LiteralPath $fixture) {
        Remove-Item -LiteralPath $fixture -Recurse -Force
    }
}
