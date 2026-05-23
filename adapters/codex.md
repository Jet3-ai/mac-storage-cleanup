# Codex 适配

## 安装

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git ~/.codex/skills/mac-storage-cleanup
```

重启 Codex 后，skill 会被读取。`agents/openai.yaml` 只是 Codex 的展示/卡片元数据，真正的工作协议在 `SKILL.md`。

## 触发示例

```text
Use $mac-storage-cleanup to audit my Mac storage and rank safe cleanup candidates.
```

或中文：

```text
用 $mac-storage-cleanup 检查我的 Mac 磁盘空间，先只读审计，再告诉我哪些能安全清理。
```

## 注意

- 默认先运行 `scripts/mac_storage_audit.sh`。
- 用户确认前不要删除任何文件。
- 清理后报告 before/after 和验证命令。
