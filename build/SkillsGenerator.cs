using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace SkillsFramework;

/// <summary>
/// Template-based SKILLS.md generator
/// Pattern inspired by awesome-claude-code's generate_readme.py
/// </summary>
public static class SkillsGenerator
{
    #region YAML Models

    public class SkillsRegistry
    {
        public List<Skill> Skills { get; set; } = new();
    }

    public class CategoriesFile
    {
        public List<Category> Categories { get; set; } = new();
    }

    public class Skill
    {
        public string Id { get; set; } = "";
        public string Name { get; set; } = "";
        public string Category { get; set; } = "";
        public string? Subcategory { get; set; }
        public string Scope { get; set; } = "session";
        public int Priority { get; set; } = 99;
        public string Trigger { get; set; } = "user_request";
        public string Activation { get; set; } = "manual";
        public string Description { get; set; } = "";
        public List<string> Capabilities { get; set; } = new();
        public bool Active { get; set; } = true;
    }

    public class Category
    {
        public string Id { get; set; } = "";
        public string Name { get; set; } = "";
        public string Prefix { get; set; } = "";
        public string Icon { get; set; } = "";
        public string Scope { get; set; } = "session";
        public string Description { get; set; } = "";
        public int Order { get; set; } = 99;
        public List<Subcategory>? Subcategories { get; set; }
    }

    public class Subcategory
    {
        public string Id { get; set; } = "";
        public string Name { get; set; } = "";
    }

    #endregion

    /// <summary>
    /// Generate SKILLS.md from registry and template
    /// </summary>
    public static (int skillCount, string outputPath) Generate(
        string skillsDir,
        string outputPath)
    {
        var registryPath = Path.Combine(skillsDir, "skills-registry.yaml");
        var categoriesPath = Path.Combine(skillsDir, "skills-categories.yaml");
        var templatePath = Path.Combine(skillsDir, "templates", "SKILLS.template.md");

        // Load YAML files
        var deserializer = new DeserializerBuilder()
            .WithNamingConvention(UnderscoredNamingConvention.Instance)
            .Build();

        var registry = deserializer.Deserialize<SkillsRegistry>(
            File.ReadAllText(registryPath));

        var categoriesFile = deserializer.Deserialize<CategoriesFile>(
            File.ReadAllText(categoriesPath));

        var template = File.ReadAllText(templatePath);

        // Filter to active skills only
        var activeSkills = registry.Skills.Where(s => s.Active).ToList();

        // Generate sections
        var statsTable = GenerateStatsTable(activeSkills);
        var toc = GenerateTableOfContents(categoriesFile.Categories, activeSkills);
        var bodySections = GenerateBodySections(categoriesFile.Categories, activeSkills);

        // Replace placeholders
        var output = template
            .Replace("{{STATS_TABLE}}", statsTable)
            .Replace("{{TABLE_OF_CONTENTS}}", toc)
            .Replace("{{BODY_SECTIONS}}", bodySections)
            .Replace("{{GENERATION_TIMESTAMP}}", DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss UTC"))
            .Replace("{{TOTAL_SKILLS}}", activeSkills.Count.ToString())
            .Replace("{{TOTAL_CATEGORIES}}", categoriesFile.Categories.Count.ToString());

        // Write output
        File.WriteAllText(outputPath, output);

        return (activeSkills.Count, outputPath);
    }

    private static string GenerateStatsTable(List<Skill> skills)
    {
        var sb = new StringBuilder();

        var scopes = new[] { "global", "domain", "session" };
        foreach (var scope in scopes)
        {
            var active = skills.Count(s => s.Scope == scope);
            var total = skills.Count(s => s.Scope == scope);
            sb.AppendLine($"| {char.ToUpper(scope[0]) + scope[1..]} | {active} | {total} |");
        }

        return sb.ToString().TrimEnd();
    }

    private static string GenerateTableOfContents(List<Category> categories, List<Skill> skills)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<details open>");
        sb.AppendLine("<summary>Table of Contents</summary>");
        sb.AppendLine();

        var scopes = new[] { "global", "domain", "session" };
        foreach (var scope in scopes)
        {
            var scopeCategories = categories
                .Where(c => c.Scope == scope)
                .OrderBy(c => c.Order)
                .ToList();

            if (!scopeCategories.Any()) continue;

            var scopeTitle = scope switch
            {
                "global" => "Global Skills (Always Loaded)",
                "domain" => "Domain Skills (Project-Scoped)",
                "session" => "Session Skills (On-Demand)",
                _ => scope
            };

            sb.AppendLine($"- **{scopeTitle}**");

            foreach (var cat in scopeCategories)
            {
                var anchor = cat.Name.ToLower().Replace(" ", "-").Replace("&", "").Replace("/", "");
                var skillCount = skills.Count(s => s.Category == cat.Id);

                if (skillCount == 0) continue;

                sb.AppendLine($"  - [{cat.Icon} {cat.Name}](#{anchor}) ({skillCount})");

                if (cat.Subcategories?.Any() == true)
                {
                    foreach (var sub in cat.Subcategories)
                    {
                        var subSkillCount = skills.Count(s =>
                            s.Category == cat.Id && s.Subcategory == sub.Id);

                        if (subSkillCount > 0)
                        {
                            var subAnchor = sub.Name.ToLower()
                                .Replace(" ", "-")
                                .Replace("&", "")
                                .Replace("/", "");
                            sb.AppendLine($"    - [{sub.Name}](#{subAnchor}) ({subSkillCount})");
                        }
                    }
                }
            }

            sb.AppendLine();
        }

        sb.AppendLine("</details>");
        return sb.ToString().TrimEnd();
    }

    private static string GenerateBodySections(List<Category> categories, List<Skill> skills)
    {
        var sb = new StringBuilder();

        var scopes = new[] { "global", "domain", "session" };

        foreach (var scope in scopes)
        {
            var scopeCategories = categories
                .Where(c => c.Scope == scope)
                .OrderBy(c => c.Order)
                .ToList();

            if (!scopeCategories.Any()) continue;

            var scopeIcon = scope switch
            {
                "global" => "🌍",
                "domain" => "📦",
                "session" => "⚡",
                _ => "📋"
            };

            var scopeTitle = scope switch
            {
                "global" => "Global Skills",
                "domain" => "Domain Skills",
                "session" => "Session Skills",
                _ => scope
            };

            sb.AppendLine($"## {scopeIcon} {scopeTitle}");
            sb.AppendLine();

            foreach (var cat in scopeCategories)
            {
                var categorySkills = skills
                    .Where(s => s.Category == cat.Id)
                    .OrderBy(s => s.Priority)
                    .ToList();

                if (!categorySkills.Any()) continue;

                sb.AppendLine("<details open>");
                sb.AppendLine($"<summary><h3>{cat.Icon} {cat.Name}</h3></summary>");
                sb.AppendLine();

                if (!string.IsNullOrWhiteSpace(cat.Description))
                {
                    sb.AppendLine(cat.Description.Trim());
                    sb.AppendLine();
                }

                if (cat.Subcategories?.Any() == true)
                {
                    var mainSkills = categorySkills.Where(s => string.IsNullOrEmpty(s.Subcategory)).ToList();
                    if (mainSkills.Any())
                    {
                        foreach (var skill in mainSkills)
                        {
                            sb.AppendLine(FormatSkillEntry(skill));
                            sb.AppendLine();
                        }
                    }

                    foreach (var sub in cat.Subcategories)
                    {
                        var subSkills = categorySkills
                            .Where(s => s.Subcategory == sub.Id)
                            .ToList();

                        if (!subSkills.Any()) continue;

                        sb.AppendLine($"#### {sub.Name}");
                        sb.AppendLine();

                        foreach (var skill in subSkills)
                        {
                            sb.AppendLine(FormatSkillEntry(skill));
                            sb.AppendLine();
                        }
                    }
                }
                else
                {
                    foreach (var skill in categorySkills)
                    {
                        sb.AppendLine(FormatSkillEntry(skill));
                        sb.AppendLine();
                    }
                }

                sb.AppendLine("</details>");
                sb.AppendLine();
            }
        }

        return sb.ToString().TrimEnd();
    }

    private static string FormatSkillEntry(Skill skill)
    {
        var sb = new StringBuilder();

        var activationBadge = skill.Activation == "automatic" ? "🤖 Auto" : "👆 Manual";
        var priorityBadge = $"P{skill.Priority}";

        sb.AppendLine($"**`{skill.Name}`** &nbsp; `{skill.Id}` &nbsp; {activationBadge} &nbsp; {priorityBadge}");
        sb.AppendLine();

        if (!string.IsNullOrWhiteSpace(skill.Description))
        {
            sb.AppendLine(skill.Description.Trim());
            sb.AppendLine();
        }

        if (skill.Capabilities.Any())
        {
            sb.AppendLine("<details>");
            sb.AppendLine("<summary>Capabilities</summary>");
            sb.AppendLine();
            foreach (var cap in skill.Capabilities)
            {
                sb.AppendLine($"- `{cap}`");
            }
            sb.AppendLine();
            sb.AppendLine("</details>");
        }

        sb.AppendLine($"> **Trigger:** `{skill.Trigger}`");

        return sb.ToString();
    }
}
