#!/usr/bin/env bash
# 把目前 repo 底下尚未開啟成 herdr workspace 的 git worktree 逐一開啟。
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

if ! command -v jq >/dev/null 2>&1; then
  echo "需要 jq，請先安裝 (brew install jq)" >&2
  exit 1
fi

worktree_json=$("$herdr" worktree list --cwd "$PWD")

echo "$worktree_json" | jq -r '
  .result.worktrees[]
  | select(.open_workspace_id == null)
  | [.path, .branch] | @tsv
' | while IFS=$'\t' read -r path branch; do
  echo "開啟 worktree: $branch ($path)"
  "$herdr" worktree open --path "$path" --label "$branch" --no-focus
done

echo "完成。按任意鍵關閉。"
read -r -n1 -s || true
