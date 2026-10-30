---
title: QQ 通道能发什么（onebot vs 官方 bot）
date: 2026-10-30
type: skill
salience: 1
last_access: 2026-10-30
summary: 当前 QQ 会话走 dsh-onebot-channel（NapCat），只能发文字；qqbot_send_file 属官方 bot 且要 openid，qq_collect_face 的 file= 被 NapCat 按本地相对路径解析，都不通。文字里带本机路径会被审计拦截。
tags: [qq, onebot, napcat, 发图, 审计]
sources: []
---

# QQ 通道能发什么

## 结论先给

- **当前会话的 QQ 通道 = `dsh-onebot-channel`（协议端 NapCat）**，工具是 `qq_send / qq_pass / qq_remember / qq_msg_history / qq_collect_face / qq_face_preview / qq_emoji_search / qq_qzone_post` 这套。
- 这套**只有文字**：`outbound.js` 里没有任何 image / CQ 码处理，`qq_send` 也不能附图。想"发一张图给豆芽"在 QQ 上做不到。

## 踩过的三条死路

1. `qqbot_send_file`：属于**另一个插件** `@tencent-connect/dsh-qqbot`（官方 bot），
   - `target` 要 `c2c:<openid>`，填 QQ 号 → `请求的资源不存在(用户/群已注销)`；
   - 文件路径有白名单：`MEDIA_ROOT(~/.dsh-qqbot/media)` + 插件 cwd + `sendFile.extraRoots`，工作区文件要先复制进 `.dsh-qqbot\media`。
2. `qq_collect_face file=<本地路径>`：
   - 插件把路径转成 `file:///D:/...`，NapCat 却仍按**自己的 cwd（D:\napcat）** 解析 → `stat 'D:\napcat\file:D:...'` ENOENT；
   - 改传 `http://127.0.0.1:xxx/a.png` 同样被当相对路径 → `stat 'D:\napcat\http:\...'`。
   - 也就是说这条路的 `file=` 只接受 NapCat 能直接读到的本地路径，而插件总会加 `file:` 前缀，二者矛盾；`base64://` 前缀会被原样透传，理论可行但没验证过。
3. 临时起本地 HTTP 服务给 NapCat 抓图：没用，因为第 2 条根本不发 HTTP 请求。

## 文字里的审计红 line

`qq_send` 内容里出现本机路径（如 `D:\...`）会被审计拦：`回复内容被审计拦截：本机路径`，消息不会发出去。
→ 改说「工作区 avatar 目录 / 文件名」，不写盘符和反斜杠。

## 可以用的替代交付

- 图片/文件类交付走 **DSH Web GUI 的 `present`**（文件卡片），QQ 里只说明+指引。
- 表情可以发：`qq_send` 的 `emoji`（经典表情名/编号）、`custom_emoji`（收藏夹关键词）。
- 生成图片本身没问题：`Add-Type -AssemblyName System.Drawing` + `System.Drawing.Bitmap` 手绘 PNG，写在 `D:\workspace\avatar\`。

## 相关页面

- [Windows 沙箱写入被拒](windows-sandbox-workspace-acl.md)
