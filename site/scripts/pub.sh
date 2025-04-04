#!/bin/bash
source "$(dirname "$0")/helpers.sh"

file="$1"

if [[ -z "$file" ]]; then
  echo "Select a draft to publish:"
  mapfile -t files < <(list_recent_files "unpublished" "modified")

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No drafts available."
    exit 0
  fi

  display_menu_items "${files[@]}"
  read -rp "Enter number: " selection
  index=$((selection - 1))
  file="${files[$index]}"
fi

if [[ ! -f "$file" ]]; then
  echo "File not found: $file"
  exit 1
fi

# Update draft = true -> false
sed -i 's/^draft *= *true/draft = false/' "$file"
echo "✅ Published: $file"
