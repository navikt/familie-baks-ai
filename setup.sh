#!/usr/bin/env bash
# Links team Copilot settings (agents, skills, prompts, instructions)
# into ~/.copilot so they work alongside personal settings.
# Safe to re-run — existing personal files are never overwritten.

set -euo pipefail

TEAM_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$TEAM_REPO/.github"
DST="$HOME/.copilot"

link_file() {
  local type="$1"
  local src_file="$SRC/$type"

  [ -f "$src_file" ] || return 0
  mkdir -p "$DST"

  ln -sf "$src_file" "$DST/$type"
  echo "  LINK  $type"
}

remove_stale_baks_files() {
  local type="$1"
  local dst_dir="$DST/$type"

  [ -d "$dst_dir" ] || return 0

  for item in "$dst_dir"/baks-*; do
    [ -e "$item" ] || continue
    local name
    name="$(basename "$item")"
    rm -f "$item"
    echo "  CLEAN $type/$name (fjerner utdatert baks-fil)"
  done
}

link_files() {
  local type="$1"
  local src_dir="$SRC/$type"
  local dst_dir="$DST/$type"

  [ -d "$src_dir" ] || return 0
  mkdir -p "$dst_dir"

  for item in "$src_dir"/*; do
    [ -e "$item" ] || continue
    local name
    name="$(basename "$item")"
    local target="$dst_dir/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "  SKIP  $type/$name (personal file exists — not overwriting)"
    else
      ln -sf "$item" "$target"
      echo "  LINK  $type/$name"
    fi
  done
}

echo "Linking team Copilot settings from $TEAM_REPO"
remove_stale_baks_files agents
remove_stale_baks_files skills
remove_stale_baks_files instructions
link_files agents
link_files skills
link_files instructions
link_file copilot-instructions.md
echo "Done."
