# MEMORY — 记忆库 schema 与维护协议

> 本文件是记忆库的「操作系统」。它告诉任何接手的 agent（包括未来的自己）记忆怎么组织、怎么记、怎么忆、怎么忘、怎么迁移。它是**自描述**的：迁移后读一遍本文件即可学会使用整套记忆。

## 三层结构（沿用 LLM Wiki 约定）

- `raw/` —— 不可变源材料。只读，永不修改，作为记忆的「证据来源」。
- 分类页目录（`identity/ user/ skills/ decisions/ projects/ concepts/`）—— **agent 拥有并维护**的、互相链接的 markdown 记忆页。
- `SOUL.md` + `MEMORY.md` + `BOOTSTRAP.md` —— 元记忆（schema）。`SOUL.md` 定义人格，`MEMORY.md`（本文件）定义维护协议，`BOOTSTRAP.md` 记录铸魂进度。

## 文件职责

| 文件 | 性质 | 内容 |
|---|---|---|
| `SOUL.md` | 人格（用户主导） | 我是谁、性格、价值观、沟通风格、与用户的关系、边界 |
| `BOOTSTRAP.md` | 铸魂清单 | 安装后灵魂定义/身份确认的进度；complete 前优先于常规任务 |
| `MEMORY.md` | schema（本文件） | 目录、分级、衰减、遗忘、迁移、工作流 |
| `index.md` | 内容目录 | **路由表**：每页一行 —— 链接 + 一句话摘要（≤ 80 字）+ `salience` 标记。长内容留在页面里 |
| `log.md` | 时间线 | append-only，每条 `## [YYYY-MM-DD] <kind> \| <title>`，可 grep 解析 |
| `identity/` | 自我 | agent 的持久自我认知、能力边界、工作方式 |
| `user/` | 关于用户 | profile（稳定事实）、preferences（偏好/风格） |
| `skills/` | 程序性 | 工具用法、环境坑、用户偏好的工作流 |
| `decisions/` | 决策 | 决策 + 理由 + 当时上下文 + 后续结果（复盘用） |
| `projects/active` / `archive` | 项目 | 进行中 / 已归档的项目记忆 |
| `concepts/` | 概念 | 术语、概念页（可选，wiki 风格） |
| `raw/` | 源材料 | 只读，见上 |

## 记忆分级（salience）

每个页面 frontmatter 用 `salience` 标注热度，驱动**启动加载优先级**与**衰减**：

| salience | 含义 | 处理 |
|---|---|---|
| `1` 热 | 每次启动都应加载（身份、当前项目、关键偏好） | 常驻工作记忆 |
| `2` 温 | 需要时按 index drill 进 | 正常 |
| `3` 冷 | 长期未访问的历史 | 候选归档/删除 |

衰减规则：`salience: 3` 且 `last_access` 距今超过 **90 天** → 整理时建议归档或删除；`salience: 2` 超过 180 天未访问 → 降级为 3。优先归档，删除需谨慎。

## 工作流

### remember（记）
读源 → 提取关键事实 → 新建/更新相关页 → **补 1–3 条「相关页面」互链（相对路径）** → 标注矛盾 → 更新 `index.md` → 追加 `log.md`。一次 ingest 常 touch 多页。

> 互链不是装饰：`index.md` 是目录（谁存在），页间链接是**关系**（谁和谁有关）。图谱、跨页综合、未来的检索都建立在这层关系上——写页时顺手补两三行，比事后补一个功能有用。

### recall（忆）
先读 `index.md` 定位，再钻页综合；好的答案可回写为新页（让探索复利累积）。

### consolidate（整理 / lint）
定期检查：页间矛盾、被新事实取代的旧声明、孤儿页、缺页的重要概念、缺交叉引用、该归档的冷页、可合并的重复页。工具：`dsh-memory lint`。

### forget（忘）
- 显式：用户要求删除/修正 → 立即执行，改 `index.md`、记 `log.md`。
- 自动：按 salience + last_access 衰减，优先归档。

## frontmatter 约定

```yaml
---
title: 页面标题
date: 2026-08-18
type: identity | user | fact | decision | skill | concept | project
salience: 2            # 1 热 / 2 温 / 3 冷
last_access: 2026-08-18
tags: []
sources: []            # 指向 raw/ 或外部
---
```

- 页面用**相对 markdown 链接**互相引用。
- 新信息与旧声明矛盾时：改旧页、在新页标注、`log.md` 记变更。
- `last_access` 由插件**自动维护**：会话启动时把 boot 块实际引用的页面戳为当天，也可用 `dsh-memory touch <pages...>` 手动补记。写页时保持该字段存在即可，不必逐日手改。
- `index.md` 是**路由表**：一行一页、一句话摘要，不写状态流水。它会被完整注入会话，膨胀的代价是挤掉其他记忆——一行写不下，就说明该拆页或该把细节移进正文。
- 每个页面用 frontmatter `summary:` 声明一句话摘要（≤ 100 字）——index 行由它派生，`dsh-memory index --write` 负责同步，`--sync-frontmatter` 可把已写在 index 里的摘要回填到页面。

## 迁移协议

- 记忆 = 纯 markdown + git + 自描述 schema。迁移 = 拷贝目录（或 `dsh-memory pack` / `unpack`），详见 docs/MIGRATION.md。
- 目标环境能力降级兼容：全量（整个目录）/ 精简（index + 高频页摘要）/ 最低配（SOUL + MEMORY + index 三段即可恢复人格与目录）。

## 规则（硬约束）

1. 启动必读 `SOUL.md` + `MEMORY.md` + `index.md`（本插件已自动注入）。
2. **会话收尾前必须做 digest 沉淀**（写回页面 + index.md + 追加 log.md），否则记忆不更新；插件注入的 digest 提醒消息必须立即执行，确无内容时在 log.md 记「无新增」解除提醒。
3. `raw/` 只读，绝不修改。
4. 删除前优先归档；显式遗忘立即执行。
5. 冲突以本文件为准。
