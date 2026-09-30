Serilog.Log.Logger = new Serilog.LoggerConfiguration().WriteTo.Console().CreateLogger();
Serilog.Log.Information("hello");
