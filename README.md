# mac-storage-cleanup

一个面向 macOS 的磁盘空间诊断与安全清理 skill，可用于 Codex、Claude Code、OpenClaw、WorkBuddy、KimiClaw 等不同 agent 环境。

它的核心目标不是“帮你一键删东西”，而是让 agent 先把磁盘占用看清楚，再按风险分级给出可确认的清理方案。适合处理 macOS 储存空间里常见的“应用程序很大”“系统数据异常”“Docker 很占空间”“本地模型太多”“聊天软件/网盘缓存膨胀”“Git 仓库里有异常 pack 文件”“APFS 快照导致空间没释放”等问题。

## 适合什么场景

- macOS 储存空间显示某类占用异常，但 Finder 里看不出来。
- 想知道 Docker、Ollama、Chrome 本地模型、WPS、微信、企业微信等到底占了多少空间。
- 想让 agent 找出可以安全清理的缓存、临时文件、构建产物或中断下载残留。
- 想清理 Git 仓库里的 `tmp_pack_*` 等明确垃圾，但不想误删正常 Git 对象。
- 想解释为什么删了大文件以后，macOS 可用空间没有立刻上涨。

## 设计原则

- **先审计，再清理**：默认先只读扫描，不直接删除。
- **区分应用本体和应用数据**：macOS 的“应用程序很大”经常来自 `~/Library/Containers`、`Application Support`、缓存或离线文件。
- **不要碰用户数据**：文档、聊天数据库、照片库、音乐库、云盘/NAS 同步目录默认不删。
- **只做定向清理**：优先清理可重建缓存、临时文件、生成物、明确垃圾，不做粗暴全局清缓存。
- **每一步都要确认**：凡是可能影响用户数据、登录状态、聊天记录、Docker 状态的动作，都需要用户明确确认。
- **清理后必须验证**：报告清理前后目录大小、系统可用空间，以及必要的完整性检查。

## 仓库结构

```text
SKILL.md                         通用 skill 行为协议，各 agent 都应该优先读取
AGENTS.md                        面向通用 coding/local agent 的项目级说明
CLAUDE.md                        Claude Code 作为项目打开时的补充说明
agents/openai.yaml               Codex/OpenAI skill catalog 展示配置
adapters/                        各 agent 的安装和触发适配卡
scripts/mac_storage_audit.sh     只读 macOS 磁盘审计脚本
```

## 快速使用

只想先看机器哪里占空间，可以直接运行只读审计脚本：

```bash
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git
cd mac-storage-cleanup
bash scripts/mac_storage_audit.sh
```

更深入一点的排行扫描：

```bash
bash scripts/mac_storage_audit.sh --deep
```

脚本不会删除文件，只会输出磁盘、容器、应用支持目录、常见热点、Time Machine 本地快照和 APFS 快照线索。

## 多 Agent 适配

本仓库把“通用行为协议”和“不同 agent 的安装方式”分开：

- `SKILL.md` 是所有 agent 都应该遵守的核心说明。
- `adapters/*.md` 是不同 agent 的安装路径、触发话术和注意事项。
- 如果某个 agent 原生支持 `SKILL.md`，直接把整个目录放进它的 skill 目录。
- 如果某个 agent 不支持 skill 自动发现，就在系统提示词、项目说明或 agent 配置里引用 `SKILL.md` 和对应适配卡。

### Codex

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git ~/.codex/skills/mac-storage-cleanup
```

重启 Codex 后使用：

```text
Use $mac-storage-cleanup to audit my Mac storage and rank safe cleanup candidates.
```

更多说明见 [adapters/codex.md](adapters/codex.md)。

### Claude Code

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git ~/.claude/skills/mac-storage-cleanup
```

也可以把本仓库作为普通项目打开，Claude Code 会看到 `CLAUDE.md` 与 `SKILL.md`。

更多说明见 [adapters/claude-code.md](adapters/claude-code.md)。

### OpenClaw

OpenClaw 环境中常见两种方式：

```bash
mkdir -p ~/clawd/skills
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git ~/clawd/skills/mac-storage-cleanup
```

如果你的 OpenClaw 版本使用其他自定义 skills 目录，请把仓库放到该目录，或在 agent/system prompt 中引用本仓库的 `SKILL.md`。

更多说明见 [adapters/openclaw.md](adapters/openclaw.md)。

### WorkBuddy

WorkBuddy 如果支持自定义 skill 目录，把本仓库注册为 `mac-storage-cleanup`。如果只支持工作区/项目提示词，把 [adapters/workbuddy.md](adapters/workbuddy.md) 的内容加入该 agent 的项目说明，并要求它读取 `SKILL.md`。

### KimiClaw

KimiClaw 通常更接近 OpenClaw 插件/扩展生态：不要把它和 Claude/Codex 的目录机制混为一谈。建议把本仓库作为 KimiClaw 可读取的 skill 资料包，或放入它绑定的 OpenClaw 自定义 skills 目录，再在 KimiClaw agent prompt 中引用 `SKILL.md`。

更多说明见 [adapters/kimiclaw.md](adapters/kimiclaw.md)。

## 安全分级

agent 在给出清理建议时，应按下面四档说明风险：

- **确认后可安全清理**：可重建缓存、临时文件、中断下载残留、明确的 Git 临时 pack、旧更新缓存、浏览器下载的本地模型。
- **建议迁移/归档**：旧媒体工程、安装包、已解压的重复压缩包、历史项目文件夹。
- **必须先问清楚**：聊天软件文件、微信/企业微信文件目录、云盘文件、照片/音乐库、NAS 同步目录。
- **默认不碰**：聊天数据库、钥匙串、账号设置、系统卷、Time Machine 快照、正常 Git pack、活跃项目目录。

## 典型工作流

1. 运行只读审计。
2. 找出最大且可解释的目录。
3. 判断每个目录是什么：缓存、用户数据、应用状态、系统快照还是未知。
4. 给出清理建议和风险等级。
5. 等用户确认后，只删除被确认的路径。
6. 清理后验证目录大小、系统可用空间和必要的完整性检查。
7. 如果空间没有立即释放，解释 APFS / Time Machine 快照的延迟计量。

## 隐私说明

仓库不包含任何本机扫描结果、账号数据、聊天数据、缓存样本或个人路径。审计脚本只会在用户自己的机器上运行时输出本地路径。

如果你 fork 或二次发布，请不要提交：

- 本机审计输出
- 聊天数据库或应用容器
- 储存空间截图
- 带有用户名、邮箱、token、cookie、私有目录名的日志

## CyberUnion

这个 skill 遵循 CyberUnion 的 agent 工作观：local-first、evidence-first、small enough to trust。

我们更关心 agent 是否能把现实问题拆成可验证的小动作，而不是制造一个“看起来很智能”的黑箱。磁盘清理是一个很好的例子：真正有用的 agent 不应该急着删文件，而应该先帮你恢复判断力。

如果你也在构建个人自动化、研究 agent、本地优先的 AI 工作流，可以把这类小 skill 当成积木：每一个都解决一个真实问题，写清楚安全边界，再逐步组合成自己的工作系统。

## License

MIT. See [LICENSE](LICENSE).
