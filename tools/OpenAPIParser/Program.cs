// This program runs the parser from Microsoft.OpenApi.Readers package
// and fails if the parsing fails.

using System.Diagnostics;
using Microsoft.OpenApi.Readers;

if (args.Length == 0)
{
    Console.WriteLine("Usage: OpenAPIParser.exe <file-or-url>");
    Environment.Exit(1);
}

var stopwatch = new Stopwatch();
stopwatch.Start();
Console.WriteLine("Parsing OpenAPI file");
var reader = new OpenApiStreamReader();

Stream stream;
if (args[0].StartsWith("https"))
{
    using var httpClient = new HttpClient();
    stream = await httpClient.GetStreamAsync(args[0]);
}
else
{
    stream = new FileStream(args[0], System.IO.FileMode.Open);
}

var doc = reader.Read(stream, out var diag);
if (diag.Errors.Count > 0)
{
    Console.WriteLine("Parsing failed!");
    foreach (var error in diag.Errors)
    {
        Console.WriteLine(error.ToString());
    }

    Environment.Exit(1);
}

stopwatch.Stop();
Console.WriteLine($"Parsing took {stopwatch.ElapsedMilliseconds}ms");
Console.WriteLine($"Found {doc.Paths.Count} paths");