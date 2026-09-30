#!/usr/bin/env bash
# Runs as the user OUTSIDE the eval sandbox, with HOME remapped to <temp>/home and
# cwd = the run's workspace. Prepares a TUnit fixture that builds offline inside the
# sandbox. Shared by other cases: `bash "$here/../_smoke/scaffold.sh"`.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fixture="$here/../_fixtures/tunit-mini"
real_home="$(eval echo "~$(id -un)")"      # tilde uses the passwd entry, not $HOME

# Everything below rewrites $HOME's NuGet config and the cwd; outside the harness that is
# the user's real config and repository, so refuse before the first write.
if [ "${HOME%/}" = "${real_home%/}" ]; then
  echo "scaffold.sh: HOME is not remapped ($HOME); run it only through the eval harness" >&2
  exit 1
fi

cp -R "$fixture/." .

# 1. The first dotnet command below does the first-run setup (sentinels + NuGet migrations)
#    here, outside the sandbox: inside it, the "NuGet-Migrations" named mutex needs /tmp,
#    which the sandbox denies. The check after the restores asserts the marker exists.
export DOTNET_NOLOGO=1 DOTNET_CLI_TELEMETRY_OPTOUT=1
# The run gets no XDG_* vars, so NuGet resolves its data dir from HOME; match that here.
unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
mkdir -p "$HOME/.local/share/NuGet/Migrations"
touch "$HOME/.local/share/NuGet/Migrations/1"

# 2. Offline package feed: the user-level NuGet.Config in the remapped HOME points only at
#    the remapped global packages folder, so restore inside the sandbox never hits the network.
mkdir -p "$HOME/.nuget/NuGet" "$HOME/.nuget/packages"
seed_config="$(mktemp -d)/NuGet.Config"
cat > "$seed_config" <<XML
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="seed" value="$real_home/.nuget/packages" />
  </packageSources>
</configuration>
XML

# 3. Pre-restore NEW (the fixture as-is) and OLD (a throwaway copy pinned to 1.68.0), so the
#    agent can pin either version offline.
dotnet restore Shop.Tests.csproj --configfile "$seed_config" -v q
old="$(mktemp -d)"
cp Shop.Tests.csproj "$old/"
sed -i.bak 's/Version="1.68.17"/Version="1.68.0"/g' "$old/Shop.Tests.csproj"   # BSD and GNU sed
rm "$old/Shop.Tests.csproj.bak"
dotnet restore "$old/Shop.Tests.csproj" --configfile "$seed_config" -v q
rm -rf "$old" "$(dirname "$seed_config")"
test -f "$HOME/.local/share/NuGet/Migrations/1"

cat > "$HOME/.nuget/NuGet/NuGet.Config" <<XML
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="local" value="$HOME/.nuget/packages" />
  </packageSources>
</configuration>
XML
rm -rf obj   # the agent restores for itself
