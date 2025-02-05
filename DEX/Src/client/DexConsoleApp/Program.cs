using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using System;
using System.Configuration;

//Define the path to the text file
string logFilePath = "console_log.txt";

static void ReadAllSettings()
{
    try
    {
        var appSettings = ConfigurationManager.AppSettings;
        if (appSettings.Count == 0)
        {
            Console.WriteLine("AppSettings is empty.");
        }
        else
        {
            foreach (var key in appSettings.AllKeys)
            {
                Console.WriteLine("Key: {0} Value: {1}", key, appSettings[key]);
            }
        }
    }
    catch (ConfigurationErrorsException)
    {
        Console.WriteLine("Error reading app settings");
    }
}

static string ReadSetting(string key)
{
    try
    {
        var appSettings = ConfigurationManager.AppSettings;
        string result = appSettings[key] ?? "Not Found";
        return result;
    }
    catch (ConfigurationErrorsException)
    {
        Console.WriteLine("Error reading app settings");
        return "";
    }
}

//Create a StreamWriter to write logs to a text file
using (StreamWriter logFileWriter = new StreamWriter(logFilePath, append: true))
{
    //Create an ILoggerFactory
    ILoggerFactory loggerFactory = LoggerFactory.Create(builder =>
    {
        //Add console output
        builder.AddSimpleConsole(options =>
        {
            options.IncludeScopes = true;
            options.SingleLine = true;
            options.TimestampFormat = "HH:mm:ss ";
        });

        //Add a custom log provider to write logs to text files
        builder.AddProvider(new CustomFileLoggerProvider(logFileWriter));
    });

    //Create an ILogger
    ILogger<Program> logger = loggerFactory.CreateLogger<Program>();

    // Output some text on the console
    using (logger.BeginScope("[scope is enabled]"))
    {
        logger.LogInformation("Hello World!");
        logger.LogInformation("Logs contain timestamp and log level.");
        logger.LogInformation("Each log message is fit in a single line.");
    }

    using HttpClient client = new();
    client.DefaultRequestHeaders.Accept.Clear();
    client.DefaultRequestHeaders.Accept.Add(
        new MediaTypeWithQualityHeaderValue("application/vnd.github.v3+json"));
    client.DefaultRequestHeaders.Add("User-Agent", ".NET Foundation Repository Reporter");

    var repositories = await ProcessRepositoriesAsync(client);

    foreach (var repo in repositories)
    {
        //Console.WriteLine($"Name: {repo.Name}");
        //Console.WriteLine($"Homepage: {repo.Homepage}");
        //Console.WriteLine($"GitHub: {repo.GitHubHomeUrl}");
        //Console.WriteLine($"Description: {repo.Description}");
        //Console.WriteLine($"Watchers: {repo.Watchers:#,0}");
        //Console.WriteLine($"{repo.LastPush}");
        //Console.WriteLine();

        logger.LogInformation($"Name: {repo.Name}");
        logger.LogInformation($"Homepage: {repo.Homepage}");
        logger.LogInformation($"GitHub: {repo.GitHubHomeUrl}");
        logger.LogInformation($"Description: {repo.Description}");
        logger.LogInformation($"Watchers: {repo.Watchers:#,0}");
        logger.LogInformation($"{repo.LastPush}");

        ReadAllSettings();
        string strVal;
        strVal = ReadSetting("Setting1");
        logger.LogInformation($"The value of  Setting1 is {strVal}");

        strVal = ReadSetting("NotValid");
        logger.LogInformation($"The value of  Setting1 is {strVal}");
    }


}



static async Task<List<Repository>> ProcessRepositoriesAsync(HttpClient client)
{
    await using Stream stream =
        await client.GetStreamAsync("https://api.github.com/orgs/dotnet/repos");
    var repositories =
        await JsonSerializer.DeserializeAsync<List<Repository>>(stream);
    return repositories ?? new();
}

// Customized ILoggerProvider, writes logs to text files
public class CustomFileLoggerProvider : ILoggerProvider
{
    private readonly StreamWriter _logFileWriter;

    public CustomFileLoggerProvider(StreamWriter logFileWriter)
    {
        _logFileWriter = logFileWriter ?? throw new ArgumentNullException(nameof(logFileWriter));
    }

    public ILogger CreateLogger(string categoryName)
    {
        return new CustomFileLogger(categoryName, _logFileWriter);
    }

    public void Dispose()
    {
        _logFileWriter.Dispose();
    }
}

// Customized ILogger, writes logs to text files
public class CustomFileLogger : ILogger
{
    private readonly string _categoryName;
    private readonly StreamWriter _logFileWriter;

    public CustomFileLogger(string categoryName, StreamWriter logFileWriter)
    {
        _categoryName = categoryName;
        _logFileWriter = logFileWriter;
    }

    public IDisposable BeginScope<TState>(TState state)
    {
        return null;
    }

    public bool IsEnabled(LogLevel logLevel)
    {
        // Ensure that only information level and higher logs are recorded
        return logLevel >= LogLevel.Information;
    }

    public void Log<TState>(
        LogLevel logLevel,
        EventId eventId,
        TState state,
        Exception exception,
        Func<TState, Exception, string> formatter)
    {
        // Ensure that only information level and higher logs are recorded
        if (!IsEnabled(logLevel))
        {
            return;
        }

        // Get the formatted log message
        var message = formatter(state, exception);

        //Write log messages to text file
        _logFileWriter.WriteLine($"[{logLevel}] [{_categoryName}] {message}");
        _logFileWriter.Flush();
    }
}