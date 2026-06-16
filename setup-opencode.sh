#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORVENTET_DIR="$REPO_DIR/.opencode"

echo "🔍 Sjekker OPENCODE_CONFIG_DIR..."

if [[ -z "${OPENCODE_CONFIG_DIR:-}" ]]; then
    echo "❌ OPENCODE_CONFIG_DIR er ikke satt."
elif [[ "$OPENCODE_CONFIG_DIR" != "$FORVENTET_DIR" ]]; then
    echo "⚠️  OPENCODE_CONFIG_DIR peker på feil sted."
    echo "   Nåværende verdi: $OPENCODE_CONFIG_DIR"
    echo "   Forventet:       $FORVENTET_DIR"
else
    echo "✅ Alt er i orden! OPENCODE_CONFIG_DIR peker på riktig sted."
    exit 0
fi

echo ""
echo "Legg til følgende i ~/.zshrc:"
echo ""
echo "────────────────────────────────────────────────────────────"
echo "export OPENCODE_CONFIG_DIR=\"$FORVENTET_DIR\""
echo "────────────────────────────────────────────────────────────"
echo ""
echo "Deretter kjør:  source ~/.zshrc"

exit 1
