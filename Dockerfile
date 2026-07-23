# ═══════════════════════════════════════════════════════════════════════════════
# ancplua-skills Dockerfile
# Multi-stage build for .NET 10 Nuke build system
# ═══════════════════════════════════════════════════════════════════════════════

FROM mcr.microsoft.com/dotnet/sdk:10.0@sha256:ed034a8bf0b24ded0cbbac07e17825d8e9ebfe21e308191d0f7421eaf5ad4664 AS build
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
FROM mcr.microsoft.com/dotnet/runtime:10.0@sha256:ed5d539b27842d656a06a5984dbcb5114d3e885fbada612a49a5a7c3c3a44e1c AS runtime
WORKDIR /app

# Copy generated SKILLS.md and skills registry
COPY --from=build /src/SKILLS.md .
COPY --from=build /src/skills/ skills/

# Default command shows help
CMD ["cat", "SKILLS.md"]
