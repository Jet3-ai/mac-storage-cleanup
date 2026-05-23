# WorkBuddy 适配

WorkBuddy 如果支持自定义 skill 或项目知识库，可以把本仓库作为一个独立资料包注册。

## 推荐注册内容

- 名称：`mac-storage-cleanup`
- 描述：macOS 磁盘空间只读审计、安全清理候选排序、清理后验证
- 主说明文件：`SKILL.md`
- 辅助脚本：`scripts/mac_storage_audit.sh`

## 如果 WorkBuddy 不支持 SKILL.md 自动发现

把下面这段放进 WorkBuddy 的 agent 指令、项目说明或知识库入口：

```text
当用户要求检查或清理 macOS 磁盘空间时，先读取 mac-storage-cleanup 仓库中的 SKILL.md。默认只读审计，不删除文件。输出每个候选路径的大小、原因、风险等级和推荐动作。任何删除动作都必须先得到用户明确确认。清理后必须验证目录大小和系统可用空间。
```

## 触发示例

```text
用 mac-storage-cleanup 帮我看一下 Mac 空间被什么占了，先只读检查。
```

## 注意

- 不要把“缓存”当成一定可删；先确认是不是用户可见文件、云盘文件或聊天文件。
- WorkBuddy 如果有长期记忆/知识库功能，不要保存用户本机审计输出，除非用户明确要求。
