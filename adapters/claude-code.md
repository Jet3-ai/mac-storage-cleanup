# Claude Code 适配

## 安装为 Claude Code skill

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git ~/.claude/skills/mac-storage-cleanup
```

如果 Claude Code 没有立刻加载，重启 Claude Code。

## 作为普通项目使用

也可以直接 clone 后在 Claude Code 中打开本仓库：

```bash
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git
cd mac-storage-cleanup
```

Claude Code 作为项目打开时，请读取：

- `CLAUDE.md`
- `SKILL.md`

## 触发示例

```text
请使用 mac-storage-cleanup，先只读审计我的 Mac 磁盘空间，然后按风险列出清理候选项。
```

## 注意

- 这个仓库包含一个 shell 审计脚本，但脚本是只读的。
- 删除动作必须由用户明确批准。
- 不要把聊天数据库、云盘目录、照片库或系统快照当成普通缓存。
