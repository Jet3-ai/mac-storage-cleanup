# Agent 使用说明

本仓库是一个可被多种 agent 读取的 macOS 磁盘清理 skill。无论运行环境是 Codex、Claude Code、OpenClaw、WorkBuddy 还是 KimiClaw，agent 都应把 `SKILL.md` 当作最高优先级的任务协议。

## 工作边界

- 默认先运行只读审计，不做删除。
- 不要在未经用户确认时删除文件。
- 不要删除聊天数据库、账号配置、钥匙串、照片库、音乐库、云盘/NAS 同步目录、系统卷或 Time Machine 快照。
- 遇到不确定路径时，先解释风险和需要用户确认的问题。
- 删除前后必须验证路径大小和系统空间变化。

## 推荐启动方式

用户可以这样触发：

```text
使用 mac-storage-cleanup 检查我的 Mac 磁盘空间，先只读审计，列出安全清理候选项。
```

如果当前 agent 不支持自动发现 `SKILL.md`，请在系统提示词或项目说明中明确写入：

```text
先读取本仓库的 SKILL.md，再按其中的 macOS Storage Cleanup 流程工作。
```

## 适配说明

不同 agent 的安装与触发方式见：

- `adapters/codex.md`
- `adapters/claude-code.md`
- `adapters/openclaw.md`
- `adapters/workbuddy.md`
- `adapters/kimiclaw.md`
