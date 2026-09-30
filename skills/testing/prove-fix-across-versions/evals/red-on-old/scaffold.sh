#!/usr/bin/env bash
# Offline TUnit fixture (both 1.68.0 and 1.68.17 pre-restored by the _smoke scaffold), already
# bumped to 1.68.17, with a stub changelog entry. No git history: inside the sandbox git dies
# on the Xcode xcrun shim (it cannot write its cache under /var/folders), which only burns turns.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$here/../_smoke/scaffold.sh"

cat > CHANGELOG.md <<'TXT'
# Changelog

## [1.68.17]

- Bumped TUnit and TUnit.Mocks to 1.68.17.

## [1.68.0]

- Pinned TUnit and TUnit.Mocks to 1.68.0.
- `PricingTests.Configured_price_is_returned`: interface mock returns a configured price.
TXT
