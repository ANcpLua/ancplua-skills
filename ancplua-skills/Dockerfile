FROM mcr.microsoft.com/dotnet/runtime:10.0 AS base
USER $APP_UID
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["ancplua-skills/ancplua-skills.csproj", "ancplua-skills/"]
RUN dotnet restore "ancplua-skills/ancplua-skills.csproj"
COPY . .
WORKDIR "/src/ancplua-skills"
RUN dotnet build "./ancplua-skills.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./ancplua-skills.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ancplua-skills.dll"]
