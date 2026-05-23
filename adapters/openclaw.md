# OpenClaw 适配

OpenClaw 的实际 skill 目录可能因安装方式不同而变化。常见形态是系统内置 skills、扩展内 skills，以及用户自己的自定义 skills 目录。

## 推荐方式

优先把本仓库放入用户自定义 skills 目录，不建议直接改包管理器安装的 OpenClaw 内置目录。

```bash
mkdir -p ~/clawd/skills
git clone https://github.com/Jet3-ai/mac-storage-cleanup.git ~/clawd/skills/mac-storage-cleanup
```

如果你的 OpenClaw 配置使用其他自定义目录，请放到那个目录。

## 如果没有自动发现

在 OpenClaw 的 agent/system prompt 或项目说明中加入：

```text
当用户要求检查或清理 macOS 磁盘空间时，读取 mac-storage-cleanup/SKILL.md，先只读审计，再按风险分级给出清理候选项。未经用户确认不得删除文件。
```

## 触发示例

```text
调用 mac-storage-cleanup 检查我的 Mac 磁盘空间，先不要删除，只列出安全清理候选。
```

## 注意

- OpenClaw 插件/扩展和 Claude/Codex 的 skill 目录不是同一种机制。
- 如果某个 OpenClaw 插件自带 skills，请不要覆盖它；把本仓库作为独立 skill 包引用。
- 如果通过网关或定时任务运行，仍必须遵守“删除前确认”的边界。
