---
name: mac-storage-cleanup
description: |
  Use when a user asks to investigate or clean macOS disk space, especially when Storage Settings show oversized apps, chat apps, Docker, local LLMs, browser models, Git repositories, APFS snapshots, or "System Data" consuming unexpected space. Guides Codex through evidence-first scanning, safe cleanup tiers, macOS container paths, and post-cleanup verification.
---

# macOS Storage Cleanup

This skill helps Codex safely diagnose and clean macOS disk usage. It is for hands-on local cleanup where accuracy matters and accidental data loss would be expensive.

## Core Rules

- Start read-only: measure before deleting.
- Treat app bundle size and real app data size as separate things. On macOS, large "Applications" entries often come from `~/Library/Containers`, `~/Library/Application Support`, caches, or app-managed cloud/offline files.
- Never delete user documents, chat history databases, NAS sync roots, cloud folders, or app libraries unless the user explicitly asks for that exact scope.
- Prefer targeted deletion of rebuildable caches, temporary files, generated artifacts, and known garbage over broad cache purges.
- Before deleting Git internals, verify they are garbage and that no Git process is running.
- After each cleanup, verify with both directory-level checks and system-level free-space checks.
- Explain APFS/Time Machine delayed space accounting when deleted files do not immediately appear as available space.

## Fast Audit

Run a compact read-only audit first:

```bash
df -h / /System/Volumes/Data
du -xhd 1 /System/Volumes/Data 2>/dev/null | sort -h
du -sh ~/Library/Containers/* 2>/dev/null | sort -h | tail -30
du -sh ~/Library/Application\ Support/* 2>/dev/null | sort -h | tail -30
du -sh /Applications/*.app 2>/dev/null | sort -h | tail -30
```

If this skill's helper script is available, prefer:

```bash
scripts/mac_storage_audit.sh
```

For a slower ranking pass after the quick read, run:

```bash
scripts/mac_storage_audit.sh --deep
```

## Cleanup Tiers

Use these tiers when reporting candidates:

- **Safe to clear after confirmation**: rebuildable caches, temp files, incomplete Git pack files, Docker disk image when the user wants to wipe Docker state, old app update caches, browser downloaded models.
- **Move to NAS/archive**: old media projects, installers, duplicated zip files already extracted, historical proposals, inactive project folders.
- **Ask before touching**: chat app files, WeDrive/WeCom Drive, WeChat file folders, Photos/Music libraries, cloud sync folders, NAS sync folders.
- **Do not touch by default**: chat databases, keychains, app settings, system volumes, Time Machine snapshots, `.git` normal packs, active project folders.

## Known macOS Hotspots

### App Containers

Check app data under:

```bash
~/Library/Containers
~/Library/Group Containers
~/Library/Application Support
~/Library/Caches
```

Useful examples:

- WPS Office may store cloud file cache under `~/Library/Containers/com.kingsoft.wpsoffice.mac`.
- WeChat personal data is usually under `~/Library/Containers/com.tencent.xinWeChat`.
- WeCom/Enterprise WeChat data is usually under `~/Library/Containers/com.tencent.WeWorkMac`.
- Docker Desktop stores VM data under `~/Library/Containers/com.docker.docker`.
- Ollama stores model blobs under `~/.ollama/models`.
- Some local AI apps store Ollama-compatible models under their own `Application Support` folders.
- Chrome may download local optimization or on-device AI models under `~/Library/Application Support/Google/Chrome`.

### Chat Apps

For chat apps, separate these categories:

- caches and thumbnails: usually rebuildable
- downloaded files/videos/images: user-visible and should be deleted only when explicitly requested
- databases/config/accounts: do not delete by default
- cloud drive folders such as WeDrive: ask before touching

When the user says "delete videos but keep images", filter by directory and file type carefully and verify image counts remain.

### Docker

If the user asks to clear Docker usage, explain that deleting Docker VM data removes images, containers, volumes, and local databases inside Docker. Then target Docker's VM data rather than random folders.

Common check:

```bash
du -sh ~/Library/Containers/com.docker.docker 2>/dev/null
du -sh ~/Library/Containers/com.docker.docker/Data/vms/*/data/* 2>/dev/null
```

### Git Object Pack Garbage

Large `.git/objects/pack` folders can be normal, but `tmp_pack_*` files are usually interrupted Git operation leftovers when Git itself reports them as garbage.

Check:

```bash
du -sh /path/to/repo/.git/objects/pack
git -C /path/to/repo count-objects -vH
find /path/to/repo/.git/objects/pack -maxdepth 1 -type f -name 'tmp_pack_*' | wc -l
find /path/to/repo/.git/objects/pack -maxdepth 1 -type f -name 'tmp_pack_*' -print0 | xargs -0 du -ch 2>/dev/null | tail -1
LC_ALL=C ps -axo pid=,comm=,args= | awk '$2 ~ /\/(git|git-lfs|gh)$/ || $2 ~ /(^|\/)(git|git-lfs|gh)$/ {print}'
```

Only delete `tmp_pack_*` after confirming:

- the path is inside the intended repository's `.git/objects/pack`
- `git count-objects -vH` reports those files as garbage or the files clearly match `tmp_pack_*`
- no Git operation is running
- the user has approved cleanup

Delete only the temporary files:

```bash
find /path/to/repo/.git/objects/pack -maxdepth 1 -type f -name 'tmp_pack_*' -delete
```

Verify:

```bash
find /path/to/repo/.git/objects/pack -maxdepth 1 -type f -name 'tmp_pack_*' | wc -l
du -sh /path/to/repo/.git/objects/pack /path/to/repo/.git /path/to/repo
git -C /path/to/repo fsck --no-progress --connectivity-only
df -h /System/Volumes/Data
```

`dangling` objects from `git fsck` are not automatically corruption; they are usually unreachable objects that Git can prune later.

### APFS and Time Machine Snapshots

If a large deletion does not immediately increase visible free space:

```bash
tmutil listlocalsnapshots / 2>/dev/null || true
diskutil apfs listSnapshots /System/Volumes/Data 2>/dev/null
diskutil apfs list
diskutil info /System/Volumes/Data | egrep 'Volume Used Space|Container Free Space|APFS Snapshot'
```

Important explanation:

- APFS snapshots use shared blocks, so they do not behave like normal folders.
- Finder/System Settings/`df` may disagree for a while.
- Time Machine local snapshots can preserve deleted large files until macOS purges or thins them.
- Do not delete or thin snapshots unless the user explicitly asks. A user may not realize Time Machine was previously configured.

## Reporting Format

For each scan or cleanup, report:

- **What was found**: path, size, why it is large.
- **Risk level**: safe cache, user data, app state, system snapshot, unknown.
- **Recommended action**: delete, archive to NAS, leave alone, or investigate.
- **What was changed**: exact paths touched.
- **Verification**: before/after sizes and any integrity checks.
- **Remaining candidates**: next best targets, without pressuring the user into risky cleanup.

## Safety Boundaries

- Do not use `rm -rf` on broad roots such as `~/Library`, `~/Documents`, `~/Downloads`, `/Applications`, or `/System/Volumes/Data`.
- Do not clean personal and enterprise chat apps interchangeably; confirm bundle/container names.
- Do not assume a storage bar category is the real root cause. Verify on disk.
- Do not delete NAS sync local folders unless the user confirms the NAS copy is complete and recoverable.
