@echo off
REM ============================================================
REM 大肥鱼 DSH 启动器（工作电脑主实例）
REM 用法：双击运行，或在 cmd 里执行 start-dsh.cmd
REM 功能：加载 node24、读取凭据文件、启动 dsh web
REM ============================================================
setlocal
set "PATH=%USERPROFILE%\.node24;%PATH%"

REM 加载凭据（ARK Agent Plan Key / QQ Bot 凭据）
if exist "%USERPROFILE%\.dsh\secrets.env" call "%USERPROFILE%\.dsh\secrets.env"

cd /d "%USERPROFILE%"
echo [start-dsh] 启动 DeepSeek Harness web ...
dsh web %*

endlocal
