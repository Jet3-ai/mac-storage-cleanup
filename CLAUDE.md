# Claude Code 项目说明

当 Claude Code 把本仓库作为项目打开时，请先读取 `SKILL.md`，并把它作为 macOS 磁盘清理任务的主协议。

## 执行要求

- 先只读审计，后清理。
- 任何删除动作都必须等待用户确认。
- 避免宽泛的 `rm -rf`，只操作用户明确批准的具体路径。
- 报告每个候选项的路径、大小、风险等级和推荐动作。
- 清理后运行验证命令，并说明 APFS/Time Machine 可能导致的空间显示延迟。

## 推荐命令

```bash
bash scripts/mac_storage_audit.sh
bash scripts/mac_storage_audit.sh --deep
```
