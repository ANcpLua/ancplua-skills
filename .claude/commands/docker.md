---
description: Docker operations
argument-hint: "[build|run|push]"
allowed-tools:
  - Bash(docker:*)
  - Bash(docker compose:*)
  - Read
---

# Docker Command

Build and manage Docker containers.

## Arguments
- `$ARGUMENTS` - Action: build, run, or push

## Actions

### build
Run `docker build -t ancplua/ancplua-skills .`

### run
Run `docker compose up` using compose.yaml

### push
Build and push to Docker Hub (requires DOCKERHUB_TOKEN)

## Files
- `Dockerfile` - Container definition
- `compose.yaml` - Docker Compose configuration
- `.dockerignore` - Build exclusions
