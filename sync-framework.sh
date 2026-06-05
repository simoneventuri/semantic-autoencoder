#!/usr/bin/env bash
#
# sync-framework.sh — review and pull upstream semantic-autoencoder framework updates.
#
# semantic-autoencoder is a GitHub *template* repository. A project created from it is an
# independent repo with NO shared git history, so a normal `git pull` cannot carry
# framework improvements across. This script bridges that gap:
#
#   1. clones the latest upstream framework into a temp dir
#   2. diffs each framework file (listed in framework-files.txt) against this project's copy
#   3. lets you review and apply each change selectively — it never merges automatically
#
# Usage:
#   ./sync-framework.sh                 # interactive, file-by-file review
#   ./sync-framework.sh --patch-only    # write framework-sync.patch to apply by hand (hunk-level)
#   ./sync-framework.sh --list          # list the framework files tracked by the manifest
#   ./sync-framework.sh --help
#
# Environment overrides:
#   SAE_UPSTREAM_URL   upstream git URL  (default: canonical GitHub repo)
#   SAE_UPSTREAM_REF   branch or tag     (default: main)

set -uo pipefail

UPSTREAM_URL="${SAE_UPSTREAM_URL:-https://github.com/simoneventuri/semantic-autoencoder.git}"
UPSTREAM_REF="${SAE_UPSTREAM_REF:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR")"
MANIFEST="$PROJECT_ROOT/framework-files.txt"

die() { echo "error: $*" >&2; exit 1; }

[[ -f "$MANIFEST" ]] || die "manifest not found: $MANIFEST"

# Read the manifest, dropping comments and blank lines (portable; no mapfile/bash 4 needed).
FRAMEWORK_FILES=()
while IFS= read -r line; do
  [[ -n "$line" ]] && FRAMEWORK_FILES+=("$line")
done < <(grep -vE '^[[:space:]]*(#|$)' "$MANIFEST")
[[ ${#FRAMEWORK_FILES[@]} -gt 0 ]] || die "no framework files listed in $MANIFEST"

mode="review"
case "${1:-}" in
  --list)       printf '%s\n' "${FRAMEWORK_FILES[@]}"; exit 0 ;;
  --patch-only) mode="patch" ;;
  --help|-h)    sed -n '3,22p' "${BASH_SOURCE[0]}"; exit 0 ;;
  "")           ;;
  *)            die "unknown option: $1 (try --help)" ;;
esac

command -v git >/dev/null || die "git is required"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
UP="$TMP/upstream"

echo "Cloning $UPSTREAM_URL ($UPSTREAM_REF) …"
git clone --quiet --depth 1 --branch "$UPSTREAM_REF" "$UPSTREAM_URL" "$UP" \
  || die "clone failed (check SAE_UPSTREAM_URL / SAE_UPSTREAM_REF and your network)"

PATCH="$PROJECT_ROOT/framework-sync.patch"
[[ "$mode" == "patch" ]] && : > "$PATCH"

changed=0; applied=0; added=0; gone=0

for rel in "${FRAMEWORK_FILES[@]}"; do
  up="$UP/$rel"
  proj="$PROJECT_ROOT/$rel"

  # File retired upstream.
  if [[ ! -f "$up" ]]; then
    echo "⚠  no longer in upstream: $rel (left untouched)"
    gone=$((gone + 1))
    continue
  fi

  # New framework file not present locally.
  if [[ ! -f "$proj" ]]; then
    added=$((added + 1))
    if [[ "$mode" == "patch" ]]; then
      diff -u -L /dev/null -L "b/$rel" /dev/null "$up" >> "$PATCH"
      continue
    fi
    echo
    echo "＋ new framework file: $rel"
    read -r -p "    create it from upstream? [y/N] " ans </dev/tty || ans=n
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      mkdir -p "$(dirname "$proj")" && cp "$up" "$proj" && { echo "    ✓ created"; applied=$((applied + 1)); }
    else
      echo "    ✗ skipped"
    fi
    continue
  fi

  # Identical — nothing to do.
  if diff -q "$proj" "$up" >/dev/null 2>&1; then
    continue
  fi

  changed=$((changed + 1))

  if [[ "$mode" == "patch" ]]; then
    { echo "diff --git a/$rel b/$rel"; diff -u -L "a/$rel" -L "b/$rel" "$proj" "$up"; } >> "$PATCH"
    continue
  fi

  # Interactive, file-level review.
  echo
  echo "════════ $rel ════════"
  diff -u -L "current ($rel)" -L "upstream ($rel)" "$proj" "$up" | sed -n '1,240p'
  echo "════════════════════════"
  read -r -p "apply upstream version of $rel? [y/N/q] " ans </dev/tty || ans=n
  case "$ans" in
    [Yy]) cp "$up" "$proj" && { echo "  ✓ applied"; applied=$((applied + 1)); } ;;
    [Qq]) echo "  stopping early."; break ;;
    *)    echo "  ✗ skipped" ;;
  esac
done

echo
if [[ "$mode" == "patch" ]]; then
  if [[ -s "$PATCH" ]]; then
    echo "Wrote $PATCH"
    echo "Review it, then apply selectively from the project root:"
    echo "    patch -p1 < framework-sync.patch        # hunk-level, interactive-friendly"
    echo "    # or: git apply --reject framework-sync.patch"
  else
    rm -f "$PATCH"
    echo "Framework is up to date — no differences."
  fi
else
  echo "Summary: $changed changed · $applied applied · $added new · $gone retired upstream."
  echo "Nothing was committed. Review with 'git diff', keep what you want, and commit."
fi
