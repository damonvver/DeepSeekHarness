---
title: Windows 沙箱写入被拒（工作区 ACL）→ 跑修复脚本
date: 2026-10-30
type: skill
salience: 2
last_access: 2026-10-30
summary: pwsh 所有命令报 SetNamedSecurityInfoW failed (Win32 5) grantWrite(D:\workspace) 时，用 diagnose-windows-sandbox-acl 脚本一次性诊断+修复，需 danger-full-access 批准。
tags: [windows, sandbox, acl, dsh]
sources: []
---

# Windows 沙箱写入被拒（工作区 ACL）

## 症状

`pwsh` 任何命令（哪怕只是 `Write-Output`）都直接失败：

```
Error: SetNamedSecurityInfoW failed (Win32 5): grantWrite(D:\workspace)
```

这是沙箱在**给工作区授写权限**这一步就挂了，命令根本没跑起来。不是命令本身的问题，换写法/换工作目录都没用。

## 处理流程

1. 加载 skill `diagnose-windows-sandbox-acl`。
2. **一条命令**同时诊断 + 修复（不要拆成两次），需要审批，用 `sandbox_permissions: danger-full-access`，justification 用大白话说清楚（改的是 Windows 文件权限、不动文件内容和所有者、会打印撤销命令）：

```powershell
& 'C:\Users\ADMINI~1\AppData\Local\Temp\dsh-acl-skill-BIRZXs\scripts\diagnose-windows-sandbox-acl.ps1' -Path 'D:\workspace' -AllowRoot 'D:\workspace' -Out 'D:\dsh-acl-recovery'
exit $LASTEXITCODE
```

3. 看输出尾部 `RECAP` / `nextAction`：`verify_original_confined_operation` = 修好了，回去重跑原命令（回到 workspace-write 模式）。
4. 失败/被拒就**停**，不要重试或手工改 ACL；把报告路径和撤销命令告诉豆芽，请他切「完全权限」。

## 本次实况（2026-10-30）

- `D:\workspace` owner 是当前用户、WRITE_DAC=true 但 **WRITE_OWNER=false** → 判定 PRECONDITION。
- 脚本备份 DACL 后补了一条 FullControl ACE，复检 writeOwner=true，verification=verified。
- 恢复目录/报告：`D:\dsh-acl-recovery`（含 `acl-backup-*.json` + 同名 `.ps1` 撤销脚本）。
- 修完原命令一次跑通，未再复发。

## 额外坑：写文件的目标目录

沙箱只放行会话工作区（`D:\workspace`）和部分临时区。要往 `C:\Users\...\.dsh-qqbot\media` 这类目录复制文件，得单独一次 `danger-full-access` 批准。

## 相关页面

- [QQ 通道能发什么](../skills/qq-channel-delivery-limits.md)
