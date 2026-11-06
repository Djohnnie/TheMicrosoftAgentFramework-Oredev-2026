using System.Text.RegularExpressions;
using System.Xml.Linq;

namespace DemoLauncher;

internal sealed record Example(int Number, string Title, string ClientProject, string? ServerProject, Uri? ServerUrl);

internal static class ExampleCatalog
{
    public static List<Example> Load(string root)
    {
        var examples = new List<Example>();
        var solution = XDocument.Load(Path.Combine(root, "exercises.slnx"));
        foreach (var folder in solution.Root!.Elements("Folder"))
        {
            var match = Regex.Match((string?)folder.Attribute("Name") ?? "", @"^/Example (\d+) - (.+)/$");
            if (!match.Success)
                continue;

            var number = int.Parse(match.Groups[1].Value);
            var projects = folder.Elements("Project")
                .Select(project => Path.GetFullPath(Path.Combine(root,
                    ((string?)project.Attribute("Path")
                        ?? throw new InvalidDataException("A solution project has no path."))
                    .Replace('/', Path.DirectorySeparatorChar))))
                .ToList();
            foreach (var project in projects)
            {
                if (!File.Exists(project))
                    throw new FileNotFoundException("Example project not found.", project);
            }

            var server = projects.SingleOrDefault(project => new DirectoryInfo(Path.GetDirectoryName(project)!).Name == "server");
            var client = projects.Single(project => project != server);
            Uri? serverUrl = number switch
            {
                15 => new("http://localhost:5285"),
                24 => new("http://localhost:5404"),
                _ => null
            };
            if (server is not null && serverUrl is null)
                throw new InvalidDataException($"Configure an MCP server URL for example {number:00}.");

            examples.Add(new Example(number, match.Groups[2].Value, client, server, serverUrl));
        }

        if (examples.Count == 0)
            throw new InvalidDataException("No example folders were found in exercises.slnx.");
        return examples.OrderBy(example => example.Number).ToList();
    }
}
