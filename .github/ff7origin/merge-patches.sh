#!/usr/bin/env bash
# Merge upstream's current master, then every branch of this fork listed in
# $PATCHES, into the checked-out tree. A branch that is gone (merged upstream
# and deleted) is skipped. Writes what was merged to notes.md, which each
# build ships as PATCHES.md.
#
# Needs: UPSTREAM (the upstream repository URL), PATCHES (branch names,
# separated by spaces), and a checkout with full history.
set -euo pipefail

git config user.name "FF7 Origin build"
git config user.email "ff7origin-build@users.noreply.github.com"
git fetch --no-tags "$UPSTREAM" master
git merge --no-edit FETCH_HEAD
{
  echo "Upstream master: $(git rev-parse --short FETCH_HEAD)"
  for branch in $PATCHES; do
    if git fetch --no-tags origin "$branch"; then
      git merge --no-edit FETCH_HEAD
      echo "- $branch: $(git rev-parse --short FETCH_HEAD)"
    else
      echo "- $branch: not found, skipped"
    fi
  done
} | tee notes.md
