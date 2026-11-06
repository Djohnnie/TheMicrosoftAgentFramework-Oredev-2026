using System.ComponentModel;
using DemoLauncher;
using Spectre.Console;

if (args.Any(argument => argument != "--no-build"))
{
    Console.Error.WriteLine("Usage: DemoLauncher [--no-build]");
    return 1;
}

var noBuild = args.Contains("--no-build");
var root = FindRepositoryRoot();
var examples = ExampleCatalog.Load(root);

if (!noBuild)
{
    using var cancellation = new CancellationTokenSource();
    ConsoleCancelEventHandler cancelHandler = (_, eventArgs) =>
    {
        eventArgs.Cancel = true;
        cancellation.Cancel();
    };
    Console.CancelKeyPress += cancelHandler;
    try
    {
        var exitCode = await DemoRunner.BuildAsync(root, examples, cancellation.Token);
        if (exitCode != 0)
        {
            Console.Error.WriteLine("Example build failed. Fix the build errors before starting the presentation.");
            return exitCode;
        }
    }
    catch (OperationCanceledException) when (cancellation.IsCancellationRequested)
    {
        Console.Error.WriteLine("Example build cancelled.");
        return 130;
    }
    catch (Exception exception) when (exception is InvalidOperationException or IOException or Win32Exception)
    {
        Console.Error.WriteLine($"Could not build examples: {exception.Message}");
        return 1;
    }
    finally
    {
        Console.CancelKeyPress -= cancelHandler;
    }
}

while (true)
{
    var selected = LauncherMenu.Choose(examples);
    if (selected is null)
        return 0;

    using var cancellation = new CancellationTokenSource();
    ConsoleCancelEventHandler cancelHandler = (_, eventArgs) =>
    {
        eventArgs.Cancel = true;
        cancellation.Cancel();
    };
    Console.CancelKeyPress += cancelHandler;
    try
    {
        AnsiConsole.WriteLine();
        AnsiConsole.Write(new Rule($"[bold #dbf536]Example {selected.Number:00}: {Markup.Escape(selected.Title)}[/]")
            .RuleStyle("#dbf536")
            .LeftJustified());
        AnsiConsole.MarkupLine("[grey]Exit the example normally or press Ctrl+C to return to the menu.[/]\n");
        await DemoRunner.RunAsync(selected, cancellation.Token);
    }
    catch (OperationCanceledException) when (cancellation.IsCancellationRequested)
    {
        AnsiConsole.MarkupLine("\n[yellow]Example stopped.[/]");
    }
    catch (Exception exception) when (exception is InvalidOperationException or IOException or Win32Exception or TimeoutException)
    {
        Console.Error.WriteLine($"\nCould not run example {selected.Number:00}: {exception.Message}");
    }
    finally
    {
        Console.CancelKeyPress -= cancelHandler;
    }
}

static string FindRepositoryRoot()
{
    foreach (var start in new[] { Environment.CurrentDirectory, AppContext.BaseDirectory })
    {
        for (var directory = new DirectoryInfo(start); directory is not null; directory = directory.Parent)
        {
            if (File.Exists(Path.Combine(directory.FullName, "exercises.slnx")))
                return directory.FullName;
        }
    }

    throw new DirectoryNotFoundException("Cannot find exercises.slnx. Run the launcher from this repository.");
}
