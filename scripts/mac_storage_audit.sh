#!/usr/bin/env bash
set -u

home_dir="${HOME:-$(cd ~ && pwd)}"
deep=0
if [[ "${1:-}" == "--deep" ]]; then
  deep=1
fi

section() {
  printf '\n== %s ==\n' "$1"
}

section "Volumes"
df -h / /System/Volumes/Data 2>/dev/null || df -h /

section "APFS Data Volume"
diskutil info /System/Volumes/Data 2>/dev/null | \
  egrep 'Volume Used Space|Container Total Space|Container Free Space|APFS Snapshot' || true

section "Largest Applications"
du -sh /Applications/*.app 2>/dev/null | sort -h | tail -30 || true

section "Known Hotspots"
du -sh \
  "$home_dir"/Library/Containers/com.kingsoft.wpsoffice.mac \
  "$home_dir"/Library/Containers/com.tencent.xinWeChat \
  "$home_dir"/Library/Containers/com.tencent.WeWorkMac \
  "$home_dir"/Library/Containers/com.docker.docker \
  "$home_dir"/.ollama \
  "$home_dir"/Library/Application\ Support/Google \
  "$home_dir"/Library/Application\ Support/Google/Chrome \
  "$home_dir"/Downloads \
  "$home_dir"/Movies \
  "$home_dir"/Documents \
  2>/dev/null | sort -h || true

if [[ "$deep" -eq 1 ]]; then
  section "Major Data Roots"
  du -sh /System/Volumes/Data/Users \
    /System/Volumes/Data/Applications \
    /System/Volumes/Data/Library \
    /System/Volumes/Data/private \
    /System/Volumes/Data/System \
    /System/Volumes/Data/opt 2>/dev/null | sort -h || true

  section "Largest User Containers"
  du -sh "$home_dir"/Library/Containers/* 2>/dev/null | sort -h | tail -30 || true

  section "Largest Application Support"
  du -sh "$home_dir"/Library/Application\ Support/* 2>/dev/null | sort -h | tail -30 || true

  section "Largest User Folders"
  du -sh "$home_dir"/* 2>/dev/null | sort -h | tail -30 || true
fi

section "Local Time Machine Snapshots"
tmutil listlocalsnapshots / 2>/dev/null || true

section "APFS Data Snapshots"
diskutil apfs listSnapshots /System/Volumes/Data 2>/dev/null || true

section "Docker / Ollama / Chrome Model Hints"
find "$home_dir/Library/Application Support/Google/Chrome" -maxdepth 3 \
  \( -iname '*model*' -o -iname '*weights*' \) -print 2>/dev/null | sed -n '1,80p' || true
