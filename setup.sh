#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Missing prerequisite: Homebrew" >&2
  exit 1
fi

echo "==> Installing packages from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

echo "==> Setup complete."
