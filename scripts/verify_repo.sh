#!/usr/bin/env bash
# Eligibility check for a candidate repo.
# Usage: bash scripts/verify_repo.sh owner/repo
# Checks: restricted list, actual code-file count (>=200), last commit date.
# Uses a blobless shallow clone (tree only, no file contents) so it is fast even for huge repos.
set -u
repo="${1:?usage: verify_repo.sh owner/repo}"
root="$(cd "$(dirname "$0")/.." && pwd)"
cache="$root/_repos/.verify"
mkdir -p "$cache"

echo "== $repo"
if grep -v '^\s*#' "$root/restricted-repos.txt" | grep -qix "$repo"; then
  echo "RESTRICTED: $repo is on the restricted list -> REJECT"; exit 1
fi
echo "restricted list: not listed"

d="$cache/${repo//\//__}"
rm -rf "$d"
if ! git -c http.sslBackend=schannel clone -q --filter=blob:none --no-checkout --depth 1 \
     "https://github.com/$repo.git" "$d" 2>/dev/null; then
  echo "CLONE FAILED: repo missing, private, or network issue -> REJECT"; exit 1
fi

echo "default branch:  $(git -C "$d" rev-parse --abbrev-ref HEAD)"
echo "HEAD commit:     $(git -C "$d" rev-parse HEAD)"
echo "last commit:     $(git -C "$d" log -1 --format=%cs)"

counts=$(git -C "$d" ls-tree -r --name-only HEAD \
  | grep -Ev '(^|/)(node_modules|vendor|third_party|thirdparty|3rdparty|dist|build)/' \
  | grep -Eo '\.(py|js|jsx|ts|tsx|mjs|cjs|go|rs|java|kt|kts|scala|rb|php|cs|fs|c|cc|cpp|h|hpp|swift|m|vue|svelte|ex|exs|erl|dart|lua|sh)$' \
  | sort | uniq -c | sort -rn)
total=$(echo "$counts" | awk '{s+=$1} END{print s+0}')
echo "code files by extension (vendored dirs excluded):"
echo "$counts" | head -8 | awk '{printf "  %-8s %s\n", $2, $1}'
echo "TOTAL code files: $total"
if [ "$total" -ge 200 ]; then echo "RESULT: PASS (>=200 code files)"; else echo "RESULT: FAIL (<200 code files)"; exit 1; fi
echo "Reminder: also check category (no container engines, databases/storage engines, observability pipelines, dev tooling/emulators, UI frameworks, utility libraries)."
