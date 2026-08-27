#!/usr/bin/env bash
# 把目前 repo 底下尚未開啟成 herdr workspace 的 git worktree 逐一開啟。
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

if ! command -v jq >/dev/null 2>&1; then
  echo "需要 jq，請先安裝 (brew install jq)" >&2
  exit 1
fi

cwd=$(printf '%s' "${HERDR_PLUGIN_CONTEXT_JSON:-}" | jq -r '.workspace_cwd // .focused_pane_cwd // empty')
cwd="${cwd:-$PWD}"
worktree_json=$("$herdr" worktree list --cwd "$cwd")

pending=$(echo "$worktree_json" | jq -r '
  .result.worktrees[]
  | select(.open_workspace_id == null)
  | [.path, .branch] | @tsv
')

if [ -z "$pending" ]; then
  echo "沒有尚未開啟的 worktree，全部都已經開好了。"
else
  echo "$pending" | while IFS=$'\t' read -r path branch; do
    printf '開啟 %-20s ... ' "$branch"
    if "$herdr" worktree open --cwd "$cwd" --path "$path" --label "$branch" --no-focus >/dev/null; then
      echo "完成"
    else
      echo "失敗"
    fi
  done
fi

echo
echo "按任意鍵關閉。"
read -r -n1 -s || true
