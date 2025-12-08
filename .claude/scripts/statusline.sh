#!/bin/bash
# Status line for ancplua-skills

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
RESET=$'\033[0m'

# Git branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")

# Dirty indicator
[ -n "$(git status --porcelain 2>/dev/null)" ] && DIRTY="${RED}*${RESET}" || DIRTY=""

# .NET SDK version
SDK=$(dotnet --version 2>/dev/null | cut -d. -f1-2 || echo "?")

# Skills count
SKILLS=$(grep -c '^  - id:' skills/skills-registry.yaml 2>/dev/null || echo "0")

printf "${CYAN}%s${RESET}%s | .NET ${GREEN}%s${RESET} | ${YELLOW}%s skills${RESET}\n" "$BRANCH" "$DIRTY" "$SDK" "$SKILLS"
