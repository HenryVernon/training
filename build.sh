#!/usr/bin/env bash
#
# Builds the public website from the landing page source.
#
#   landing/index.html  →  docs/index.html
#
# The source is written as page content only (no <html>/<head>), the way the
# Claude Artifact preview expects. GitHub Pages needs a full document, so this
# wraps it in one and drops the preview-only meta tag.
#
# Usage:  ./build.sh   then commit and push; GitHub Pages serves /docs.

set -euo pipefail
cd "$(dirname "$0")"

mkdir -p docs

{
  cat <<'HEAD'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta property="og:title" content="Train With Henry">
<meta property="og:description" content="Private one-on-one training. Book a free session.">
<meta property="og:type" content="website">
<style>
  /* Base reset the preview used to supply */
  :root { padding-top: env(safe-area-inset-top, 0px); padding-bottom: env(safe-area-inset-bottom, 0px); }
  body  { margin: 0; }
  img   { max-width: 100%; }
  [hidden] { display: none !important; }
</style>
HEAD

  # Everything through the first </style> (title, meta, fonts, styles) belongs
  # in <head>, so link previews in iMessage pick up the title. The rest is body.
  source=$(grep -v 'name="claude:' landing/index.html)
  split=$(printf '%s\n' "$source" | grep -n '</style>' | head -1 | cut -d: -f1)

  printf '%s\n' "$source" | head -n "$split"
  printf '</head>\n<body>\n'
  printf '%s\n' "$source" | tail -n +"$((split + 1))"

  printf '\n</body>\n</html>\n'
} > docs/index.html

echo "Built docs/index.html"
