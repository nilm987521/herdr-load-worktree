# herdr-load-worktree

Herdr plugin：把目前 repo 底下已存在、但尚未在 herdr 開成 workspace 的 git worktree 一鍵全部開啟。

## 背景

`herdr worktree list` 回傳的是 git 底層實際存在的 worktree 清單，但 herdr 側邊欄只顯示**已開啟成 workspace** 的項目（`open_workspace_id` 非空）。新增或 clone 專案時常見到 worktree 存在於磁碟上，卻沒出現在側邊欄——這個 plugin 就是自動把缺的那些補開起來。

## 需求

- herdr `min_herdr_version` 需求見 [`herdr-plugin.toml`](./herdr-plugin.toml)
- `jq`（`brew install jq`）

## 安裝

本機開發用 `link`：

```bash
herdr plugin link /Users/daniel/Documents/Personal/herdr-load-worktree
```

或直接從 GitHub 安裝：

```bash
herdr plugin install nilm987521/herdr-load-worktree --yes
```

修改腳本或 manifest 後不需要重新 link；`install` 來源則需重新執行 `herdr plugin install` 才會抓到最新 commit。

### 快捷鍵

`herdr-plugin.toml` 裡雖然宣告了 `[[keys.command]]`，但目前實測（herdr 0.8.2）**plugin manifest 裡的 keybinding 不會被載入進實際按鍵表**，按下去沒反應。要讓快捷鍵生效，請把同樣內容手動加進 `~/.config/herdr/config.toml`：

```toml
[[keys.command]]
key         = "prefix+t"
type        = "plugin_action"
command     = "nilm987521.herdr-load-worktree.open-all"
description = "open all worktrees"
```

改完執行 `herdr server reload-config`，再按 `prefix+?` 確認 `open-all` 出現在 `custom` 清單裡即可。

## 使用

- 快捷鍵：`prefix+t`（見上方「快捷鍵」章節設定；預設 prefix 為 `ctrl+b`）
- 或手動觸發 action：
  ```bash
  herdr plugin action invoke nilm987521.herdr-load-worktree.open-all
  ```

觸發後會開啟一個 popup pane，列出並開啟每個尚未開啟的 worktree，完成後按任意鍵關閉 popup。

## 運作方式

`herdr-load-worktree.sh`：

1. 以目前所在目錄呼叫 `herdr worktree list --cwd "$PWD"`，取得該 repo 的所有 worktree
2. 用 `jq` 篩出 `open_workspace_id == null`（尚未開啟）的項目
3. 對每一個執行 `herdr worktree open --path <path> --label <branch> --no-focus`，以分支名稱作為 label，並保留目前使用者的焦點不被搶走

## 檔案

| 檔案 | 用途 |
|---|---|
| `herdr-plugin.toml` | plugin manifest：定義 popup pane、action、快捷鍵綁定 |
| `herdr-load-worktree.sh` | 實際執行的腳本 |

## 解除安裝

```bash
herdr plugin unlink nilm987521.herdr-load-worktree
```
