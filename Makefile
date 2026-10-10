# Ship a change of this plugin to every Claude Code that installs it from GitHub.
#
# Claude Code keeps one installed copy per version and refreshes it only when
# .claude-plugin/plugin.json carries a higher number. A pushed commit without
# a bump changes nothing and warns nobody. This target does the whole chain:
# bump, commit, push, refresh the marketplace clone, update the installed copy.
#
#   make release                   patch bump of the current version
#   make release VERSION=1.1.0     explicit version
#   make release MSG="..."         also drops the line under [Unreleased] / ### Changed

PLUGIN   := ancplua-skills
MANIFEST := .claude-plugin/plugin.json
CURRENT  := $(shell jq -r .version $(MANIFEST))
VERSION  ?= $(shell echo $(CURRENT) | awk -F. '{printf "%d.%d.%d", $$1, $$2, $$3 + 1}')

.PHONY: release
release: export RELEASE_MSG := $(MSG)
release:
	@if [ -z "$$(git status --porcelain)" ] && [ "$$(git rev-list --count @{u}..HEAD)" = 0 ] && [ -z "$$RELEASE_MSG" ]; then \
		echo "release: nothing changed since $(CURRENT)"; exit 1; fi
	@if [ -n "$$RELEASE_MSG" ]; then \
		awk '{ print } /^### Changed/ && !done { print "- " ENVIRON["RELEASE_MSG"]; done = 1 }' CHANGELOG.md > CHANGELOG.md.tmp \
		&& mv CHANGELOG.md.tmp CHANGELOG.md; fi
	@jq --arg v "$(VERSION)" '.version = $$v' $(MANIFEST) > $(MANIFEST).tmp && mv $(MANIFEST).tmp $(MANIFEST)
	@git add -A
	@git commit -q -m "Release $(VERSION)"
	@git push -q origin HEAD
	@claude plugin marketplace update $(PLUGIN)
	@claude plugin update $(PLUGIN)@$(PLUGIN)
	@echo "released $(PLUGIN) $(VERSION); restart Claude Code to load it"
