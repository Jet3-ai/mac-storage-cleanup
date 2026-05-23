# mac-storage-cleanup

`mac-storage-cleanup` is a Codex skill for investigating and safely cleaning macOS disk usage.

It is designed for cases where macOS Storage Settings reports large "Applications", "System Data", chat apps, Docker, local model folders, Git repositories, browser model caches, APFS snapshots, or other confusing space usage. The skill keeps the agent evidence-first: measure, classify risk, ask before deleting, and verify after cleanup.

## What This Skill Does

- Runs read-only macOS storage audits before any cleanup.
- Separates app bundle size from real app data in containers, caches, and support folders.
- Ranks cleanup candidates by risk instead of blindly deleting caches.
- Guides safe handling for Docker, Ollama, Chrome model data, chat-app files, Git pack garbage, and APFS snapshots.
- Requires explicit user confirmation before touching anything that could contain user data.
- Reports before/after sizes and integrity checks after cleanup.

## Install In Codex

Clone this repository into your Codex skills directory:

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/<owner>/mac-storage-cleanup.git ~/.codex/skills/mac-storage-cleanup
```

Replace `<owner>` with the repository owner shown in the GitHub URL, or use the clone URL from GitHub's **Code** button.

Restart Codex after installing the skill so it can be discovered.

Then invoke it naturally, for example:

```text
Use $mac-storage-cleanup to audit my Mac storage and tell me the safest cleanup candidates.
```

## Direct Audit Script

The bundled script is read-only. From the repository root:

```bash
bash scripts/mac_storage_audit.sh
```

For a slower but broader ranking pass:

```bash
bash scripts/mac_storage_audit.sh --deep
```

The script prints system volume usage, major macOS data roots, large app containers, common local-AI and Docker locations, Time Machine local snapshots, APFS Data snapshots, and Chrome model-related hints.

## Safety Model

The skill uses four cleanup tiers:

- **Safe to clear after confirmation**: rebuildable caches, temporary files, interrupted Git pack files, old app updater caches, browser-downloaded models.
- **Move to archive**: old media projects, installers, duplicate ZIP files that have already been extracted, inactive project folders.
- **Ask before touching**: chat-app files, cloud drive folders, Photos/Music libraries, NAS sync folders, downloaded files and videos.
- **Do not touch by default**: chat databases, keychains, account settings, system volumes, Time Machine snapshots, normal Git pack files, active project folders.

The skill deliberately avoids broad commands such as deleting all of `~/Library/Caches` or recursively removing large folders just because they look suspicious.

## Typical Workflow

1. Run a read-only audit.
2. Identify the largest verified folders.
3. Explain what each folder likely contains.
4. Classify risk: cache, user data, app state, system snapshot, or unknown.
5. Ask for approval before cleanup.
6. Delete only the approved targets.
7. Verify before/after directory sizes and system free space.
8. Explain APFS or Time Machine delayed space accounting if visible free space does not update immediately.

## Files

```text
SKILL.md                         Codex skill instructions
agents/openai.yaml               Codex catalog metadata
scripts/mac_storage_audit.sh     Read-only macOS storage audit helper
```

## Privacy

This repository does not include personal machine paths, account data, local scan outputs, or cleanup logs. The audit script prints local paths only when you run it on your own machine.

Before publishing or sharing your own fork, do not commit:

- audit outputs from your machine
- chat databases or app containers
- screenshots from Storage Settings
- logs containing usernames, emails, or private folder names

## CyberUnion Note

This skill follows the CyberUnion style of practical agent work: local-first, evidence-first, and small enough to trust. The idea is simple: a useful AI workflow should leave you with clearer judgment, not a messier computer.

If you are building personal automation, research agents, or local-first AI workflows, CyberUnion treats small skills like this as reusable building blocks: each one solves a real problem, documents its safety boundary, and becomes part of a larger operating system for creative work.

## License

MIT. See [LICENSE](LICENSE).
