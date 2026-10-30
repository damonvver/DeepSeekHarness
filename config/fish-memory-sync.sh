#!/usr/bin/env bash
set -euo pipefail
MEM_DIR="${FISH_MEMORY_DIR:-$HOME/fish-memory}"
LOG="$HOME/.local/log/fish-memory-sync.log"

mkdir -p "$(dirname "$LOG")"
cd "$MEM_DIR"

ts() { date '+%Y-%m-%d %H:%M:%S'; }

# 本地有未提交改动就先提交（插件自带 autoCommit，这里是兜底）
if ! git diff --quiet --ignore-submodules -- 2>/dev/null || [ -n "$(git status --porcelain)" ]; then
  echo "[$(ts)] committing local changes" >> "$LOG"
  git add -A
  git commit -m "chore: sync from $(hostname) $(ts)" >> "$LOG" 2>&1 || true
fi

# 拉取远端。rebase 保持线性，避免记忆仓库里堆满 merge commit
if git pull --rebase --autostash origin "$(git branch --show-current)" >> "$LOG" 2>&1; then
  echo "[$(ts)] pull ok" >> "$LOG"
else
  echo "[$(ts)] pull FAILED — 需人工处理冲突" >> "$LOG"
  git rebase --abort 2>/dev/null || true
  exit 1
fi

git push origin "$(git branch --show-current)" >> "$LOG" 2>&1 || {
  echo "[$(ts)] push failed (下次重试)" >> "$LOG"
}
