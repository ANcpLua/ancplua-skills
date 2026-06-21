# ═══════════════════════════════════════════════════════════════════════════════
# ancplua-skills Dockerfile
# Multi-stage build for .NET 10 Nuke build system
# ═══════════════════════════════════════════════════════════════════════════════

FROM mcr.microsoft.com/dotnet/sdk:10.0@sha256:548d93f8a18a1acbe6cc127bc4f47281430d34a9e35c18afa80a8d6741c2adc3 AS build
WORKDIR /src

# Copy project files
COPY build/build.csproj build/
COPY build/Directory.Build.props build/
COPY build/Directory.Build.targets build/
COPY .nuke/ .nuke/

# Restore dependencies
RUN dotnet restore build/build.csproj

# Copy source files
COPY build/ build/
COPY skills/ skills/

# Build and run skills generation
RUN dotnet build build/build.csproj -c Release --no-restore
RUN dotnet run --project build/build.csproj -- GenerateSkills

# ─────────────────────────────────────────────────────────────────────────────────
# Runtime stage - minimal image with generated artifacts
# ─────────────────────────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/runtime:10.0@sha256:58318ab0733b63d3ac0d7609c46f2718244e623a176f45991ee01fad46fbf880 AS runtime
WORKDIR /app

# Copy generated SKILLS.md and skills registry
COPY --from=build /src/SKILLS.md .
COPY --from=build /src/skills/ skills/

# Default command shows help
CMD ["cat", "SKILLS.md"]
