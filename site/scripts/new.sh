#!/bin/bash
source "$(dirname "$0")/helpers.sh"

read -rp "Enter a title for your new post: " title

# Generate slug from title (lowercase, hyphens, no special chars)
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]+/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//')

# Check for duplicates
existing=$(find content/posts -type f -name "$slug.md")
if [[ -n "$existing" ]]; then
  echo "❌ A post with that slug already exists: $existing"
  exit 1
fi

# Determine year and term folder
now=$(date +%s)
year=$(date +%y)
month=$(date +%m)
day=$(date +%d)

if (( 10#$month >= 9 )); then
  academic_year_start="$year"
else
  academic_year_start=$((year - 1))
fi

academic_year_end=$((10#$academic_year_start + 1))
academic_year="${academic_year_start}-${academic_year_end}"

# Determine term
term="mich"
if (( 10#$month >= 1 && 10#$month < 4 )); then
  term="lent"
elif (( 10#$month >= 4 && 10#$month < 7 )); then
  term="east"
elif (( 10#$month >= 7 && 10#$month < 9 )); then
  term="sum"
fi

dir="content/posts/${academic_year}/${term}"
mkdir -p "$dir"

filename="${slug}.md"
filepath="${dir}/${filename}"

# Create front matter
cat <<EOF > "$filepath"
+++
title = "${title}"
date = "$(date -Iseconds)"
draft = true
tags = []
url = "/${slug}/"
+++

EOF

nano "$filepath"

# Ask to publish
echo ""
read -rp "Publish this post now? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  "$(dirname "$0")/pub.sh" "$filepath"
fi
