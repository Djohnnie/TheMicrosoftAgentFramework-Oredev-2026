using Spectre.Console;

namespace DemoLauncher;

internal static class LauncherMenu
{
    public static Example? Choose(IReadOnlyList<Example> examples)
    {
        var interactive = AnsiConsole.Profile.Capabilities.Interactive && !Console.IsInputRedirected && !Console.IsOutputRedirected;
        if (interactive)
            AnsiConsole.Clear();

        AnsiConsole.WriteLine();
        AnsiConsole.Write(new FigletText("Øredev")
            .Centered()
            .Color(Color.FromHex("#dbf536")));
        AnsiConsole.WriteLine();
        AnsiConsole.Write(new Panel(new Rows(
                new Markup("[bold #dbf536]ENABLE GenAI IN YOUR APPLICATIONS[/]"),
                new Markup($"[grey]{examples.Count} examples | .NET / Azure / Microsoft Agent Framework[/]"),
                new Markup("[grey]MCP servers start and stop automatically where needed.[/]")))
            .Header("[bold] DEMO LAUNCHER [/]")
            .Border(BoxBorder.Rounded)
            .BorderStyle(new Style(Color.FromHex("#dbf536")))
            .Padding(2, 1)
            .Expand());
        AnsiConsole.WriteLine();

        if (interactive)
        {
            AnsiConsole.MarkupLine("[grey]Up/Down to browse, type to search, Enter to launch.[/]");
            var number = AnsiConsole.Prompt(CreatePrompt(examples));
            return number == 0 ? null : examples.Single(example => example.Number == number);
        }

        foreach (var example in examples)
            Console.WriteLine($"  {example.Number,2}. {example.Title}{(example.ServerProject is null ? "" : " [managed MCP server]")}");
        Console.WriteLine("\n   0. Exit");
        while (true)
        {
            Console.Write("\nChoose an example: ");
            var input = Console.ReadLine();
            if (input is null || input.Trim() == "0" || input.Trim().Equals("quit", StringComparison.OrdinalIgnoreCase))
                return null;

            if (int.TryParse(input, out var number) && examples.SingleOrDefault(example => example.Number == number) is { } selected)
                return selected;

            Console.WriteLine("Enter an example number from the menu, or 0 to exit.");
        }
    }

    private static SelectionPrompt<int> CreatePrompt(IReadOnlyList<Example> examples) =>
        new SelectionPrompt<int>()
            .Title("[bold]Choose an example[/]")
            .PageSize(15)
            .WrapAround()
            .EnableSearch()
            .DefaultValue(examples[0].Number)
            .HighlightStyle(new Style(Color.Black, Color.FromHex("#dbf536"), Decoration.Bold))
            .MoreChoicesText("[grey](More examples above/below)[/]")
            .UseConverter(number =>
            {
                if (number == 0)
                    return "00  Exit launcher";

                var example = examples.Single(example => example.Number == number);
                return Markup.Escape($"{example.Number:00}  {example.Title}{(example.ServerProject is null ? "" : " [MCP server]")}");
            })
            .AddChoices(examples.Select(example => example.Number).Append(0));
}
