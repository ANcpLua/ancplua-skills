using System;
using Nuke.Common;
using Nuke.Common.IO;
using Serilog;
using SkillsFramework;

class Build : NukeBuild
{
    /// Support plugins are available for:
    ///   - JetBrains ReSharper        https://nuke.build/resharper
    ///   - JetBrains Rider            https://nuke.build/rider
    ///   - Microsoft VisualStudio     https://nuke.build/visualstudio
    ///   - Microsoft VSCode           https://nuke.build/vscode

    public static int Main() => Execute<Build>(x => x.Compile);

    [Parameter("Configuration to build - Default is 'Debug' (local) or 'Release' (server)")]
    readonly Configuration Configuration = IsLocalBuild ? Configuration.Debug : Configuration.Release;

    // Paths
    AbsolutePath SkillsDirectory => RootDirectory / "skills";
    AbsolutePath SkillsOutputPath => RootDirectory / "SKILLS.md";

    Target Clean => _ => _
        .Before(Restore)
        .Executes(() =>
        {
            Log.Information("Cleaning build artifacts...");
        });

    Target Restore => _ => _
        .Executes(() =>
        {
            Log.Information("Restoring dependencies...");
        });

    Target Compile => _ => _
        .DependsOn(Restore)
        .Executes(() =>
        {
            Log.Information("Compiling...");
        });

    /// <summary>
    /// Generate SKILLS.md from skills-registry.yaml and templates
    /// </summary>
    Target GenerateSkills => _ => _
        .Description("Generate SKILLS.md from YAML registry and templates")
        .Executes(() =>
        {
            Log.Information("=== Template-based SKILLS.md Generation ===");
            Log.Information("Generating SKILLS.md from registry and templates...");

            try
            {
                var (skillCount, outputPath) = SkillsGenerator.Generate(
                    SkillsDirectory,
                    SkillsOutputPath);

                Log.Information("✅ SKILLS.md generated successfully at {OutputPath}", outputPath);
                Log.Information("📊 Generated SKILLS.md with {SkillCount} active skills", skillCount);
            }
            catch (Exception ex)
            {
                Log.Error(ex, "❌ Error generating SKILLS.md");
                throw;
            }
        });

    /// <summary>
    /// Validate skills registry YAML files
    /// </summary>
    Target ValidateSkills => _ => _
        .Description("Validate skills-registry.yaml and skills-categories.yaml")
        .Executes(() =>
        {
            Log.Information("Validating skills registry...");

            var registryPath = SkillsDirectory / "skills-registry.yaml";
            var categoriesPath = SkillsDirectory / "skills-categories.yaml";

            if (!registryPath.FileExists())
            {
                Log.Error("❌ skills-registry.yaml not found at {Path}", registryPath);
                throw new Exception("Registry file not found");
            }

            if (!categoriesPath.FileExists())
            {
                Log.Error("❌ skills-categories.yaml not found at {Path}", categoriesPath);
                throw new Exception("Categories file not found");
            }

            Log.Information("✅ All skill files validated successfully");
        });

    /// <summary>
    /// Full generation pipeline: validate + generate
    /// </summary>
    Target Skills => _ => _
        .Description("Full skills pipeline: validate and generate SKILLS.md")
        .DependsOn(ValidateSkills)
        .DependsOn(GenerateSkills)
        .Executes(() =>
        {
            Log.Information("✅ Skills pipeline completed successfully");
        });
}
