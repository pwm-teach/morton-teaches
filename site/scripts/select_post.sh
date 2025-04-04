#!/bin/bash

# $1 = filter (draft|published|all)

filter="${1:-all}"
content_dir="../content/posts"

# Get list of files based on filter
if [[ "$filter" == "draft" ]]; then
  files=$(grep -rl 'draft = true' "$content_dir")
elif [[ "$filter" == "published" ]]; then
  files=$(grep -rl 'draft = false' "$content_dir")
else
  files=$(find "$content_dir" -name "*.md")
fi

# Limit and format output
files_sorted=$(echo "$files" | xargs stat --format '%Y %n' 2>/dev/null | sort -nr | head -n 30 | cut -d' ' -f2-)

# If none, exit
if [[ -z "$files_sorted" ]]; then
  echo "No posts found for filter: $filter"
  exit 1
fi

# Show numbered menu
echo "Select a file to edit:"
select file in $files_sorted; do
  if [[ -n "$file" ]]; then
    echo "$file"
    break
  fi
done
