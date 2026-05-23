# KimiClaw 适配

KimiClaw / kimi-claw 通常更接近 OpenClaw 插件或扩展生态，不应直接等同于 Codex 或 Claude Code 的 skill 安装目录。

## 推荐方式

如果 KimiClaw 绑定在 OpenClaw 环境里，优先把本仓库作为 OpenClaw 可读取的自定义 skill：

```bash
mkdir -p ~/clawd/skills
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git ~/clawd/skills/mac-storage-cleanup
```

然后在 KimiClaw 的 agent/system prompt 中引用：

```text
当用户要求检查或清理 macOS 磁盘空间时，读取 ~/clawd/skills/mac-storage-cleanup/SKILL.md。先只读审计，列出候选项和风险等级；没有用户确认不得删除文件。
```

## 如果 KimiClaw 有自己的插件/扩展目录

把整个仓库作为一个独立资料包放入对应目录，并确保 agent 能读取：

- `SKILL.md`
- `adapters/kimiclaw.md`
- `scripts/mac_storage_audit.sh`

## 触发示例

```text
用 mac-storage-cleanup 看一下我的 Mac 磁盘空间，先只读，不要删。
```

## 注意

- KimiClaw 的 bot token、OpenClaw 配置和插件安装状态都属于用户本地环境，不应写入本仓库。
- 如果 agent 需要通过 OpenClaw 网关执行命令，仍要先确认权限和删除边界。
