#!/usr/bin/env bash
# 大肥鱼 DSH 启动器（bash 版，供 Git Bash / 定时任务用）
# 用法：~/bin/start-dsh.sh   （可用 --no-open 等 dsh 参数）
set -euo pipefail
export PATH="$HOME/.node24:$PATH"

# 加载凭据：只提取 SET 开头的行转成 export，避免 Key 出现在命令行/历史里
if [ -f "$HOME/.dsh/secrets.env" ]; then
  eval "$(sed -n 's/^SET /export /p' "$HOME/.dsh/secrets.env")"
fi

cd "$HOME"
exec dsh web "$@"
