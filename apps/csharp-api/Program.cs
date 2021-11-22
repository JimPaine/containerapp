var builder = WebApplication.CreateBuilder(args);

string? nextHop = Environment.GetEnvironmentVariable("nextHop");
string response = $"{Environment.GetEnvironmentVariable("responseMessage") ?? "Hello from C# link"} - Version: {Environment.GetEnvironmentVariable("version")}";

HttpClient? httpClient = nextHop != null ? new HttpClient() : null;

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.MapGet("/", async () => {
    return new {
        response = response,
        nestedResponse = httpClient != null ? await httpClient.GetFromJsonAsync<dynamic>(nextHop) : null
    };
});

app.Run();