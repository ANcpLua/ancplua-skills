#!/usr/bin/env bash
# Runs a command in a CPU- and memory-limited container with one build-cache volume per checkout.
#
#   sandbox-run.sh <checkout> <image> <cache-path> [KEY=VALUE ...] -- <command...>
#
# The checkout is mounted at /src. The cache volume is named from the checkout's
# absolute path and mounted at <cache-path>, so two checkouts get two caches.
#
# Environment:
#   SANDBOX_CPUS     CPU limit (default 4)
#   SANDBOX_MEMORY   memory limit (default 6g)
#   SANDBOX_SHARED   <volume>:<path> for a download cache that checkouts may share
#
# Example:
#   SANDBOX_SHARED=cargo-registry:/usr/local/cargo/registry \
#     sandbox-run.sh . rust:1.96.1 /cache CARGO_TARGET_DIR=/cache/target -- cargo test -p my_crate
set -euo pipefail

usage() {
  sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
}

[ "$#" -ge 5 ] || usage
checkout=$(cd "$1" && pwd -P)
image=$2
cache_path=$3
shift 3

env_args=()
while [ "$#" -gt 0 ] && [ "$1" != "--" ]; do
  env_args+=(-e "$1")
  shift
done
[ "${1:-}" = "--" ] || usage
shift
[ "$#" -gt 0 ] || usage

if command -v sha256sum >/dev/null 2>&1; then
  key=$(printf '%s' "$checkout" | sha256sum | cut -c1-12)
else
  key=$(printf '%s' "$checkout" | shasum -a 256 | cut -c1-12)
fi
name=$(printf '%s' "$(basename "$checkout")" | tr -c 'A-Za-z0-9_.-' '-')
volume="sandbox-$name-$key"

shared_args=()
if [ -n "${SANDBOX_SHARED:-}" ]; then
  shared_args=(-v "$SANDBOX_SHARED")
fi

exec docker run --rm \
  --cpus "${SANDBOX_CPUS:-4}" --memory "${SANDBOX_MEMORY:-6g}" \
  -v "$checkout":/src -w /src \
  -v "$volume":"$cache_path" \
  ${shared_args[@]+"${shared_args[@]}"} \
  ${env_args[@]+"${env_args[@]}"} \
  "$image" "$@"
