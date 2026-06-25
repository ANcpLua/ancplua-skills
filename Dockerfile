# ═══════════════════════════════════════════════════════════════════════════════
# ancplua-skills Dockerfile
# Multi-stage build for .NET 10 Nuke build system
# ═══════════════════════════════════════════════════════════════════════════════

FROM mcr.microsoft.com/dotnet/sdk:10.0@sha256:ea8bde36c11b6e7eec2656d0e59101d4462f6bd630730f2c8201ed0572b295d5 AS build
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
FROM mcr.microsoft.com/dotnet/runtime:10.0@sha256:6a40d375e9c8432fcf4adebae05d7e0a276e9a90dd01174df6709a090771bebc AS runtime
WORKDIR /app

# Copy generated SKILLS.md and skills registry
COPY --from=build /src/SKILLS.md .
COPY --from=build /src/skills/ skills/

# Default command shows help
CMD ["cat", "SKILLS.md"]
