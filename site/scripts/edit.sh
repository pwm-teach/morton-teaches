#!/bin/bash
source "$(dirname "$0")/helpers.sh"

echo "Select filter:"
echo "1) Published"
echo "2) Unpublished"
echo "3) All"
read -rp "Your choice: " choice

case "$choice" in
  1) filter="published" ;;
  2) filter="unpublished" ;;
  3) filter="all" ;;
  *) echo "Invalid option"; exit 1 ;;
esac

mapfile -t files < <(list_recent_files "$filter" "modified")

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No matching files found."
  exit 0
fi

echo ""
echo "Select a file to edit:"
display_menu_items "${files[@]}"
read -rp "Enter number: " selection

index=$((selection - 1))
selected_file="${files[$index]}"

if [[ -n "$selected_file" && -f "$selected_file" ]]; then
  nano "$selected_file"

  echo ""
  read -rp "Would you like to publish this file now? [y/N]: " publish_now
  if [[ "$publish_now" =~ ^[Yy]$ ]]; then
    "$(dirname "$0")/pub.sh" "$selected_file"
  fi
else
  echo "Invalid selection or file missing."
  exit 1
fi
