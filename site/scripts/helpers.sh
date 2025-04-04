#!/bin/bash

# --- Configuration ---
POSTS_DIR="../content/posts"
MAX_RECENT_FILES=20

# --- Determine academic subdirectory based on current date ---
get_academic_directory() {
  local year=$(date +%Y)
  local month=$(date +%m)
  local now_ts=$(date +%s)

  # Adjust academic year
  if (( month < 9 )); then
    local start_year=$((year - 1))
    local end_year=$((year))
  else
    local start_year=$((year))
    local end_year=$((year + 1))
  fi

  local acad_year="$(printf "%02d-%02d" $((${start_year} % 100)) $((${end_year} % 100)))"

  # Determine term
  if (( now_ts >= $(date -d "$year-09-01" +%s) )); then
    term="1-mich"
  elif (( now_ts >= $(date -d "$year-04-01" +%s) )); then
    term="3-east"
  elif (( now_ts >= $(date -d "$year-01-01" +%s) )); then
    term="2-lent"
  else
    term="4-sum"
  fi

  echo "$acad_year/$term"
}

# --- Generate full path for a new post ---
get_post_path() {
  local slug="$1"
  local dir="$(get_academic_directory)"
  echo "$POSTS_DIR/$dir/$slug.md"
}

# --- Extract title from front matter ---
extract_title() {
  grep '^title' "$1" | sed 's/title *= *"\(.*\)"/\1/'
}

# --- Extract date from front matter ---
extract_date() {
  grep '^date' "$1" | sed 's/date *= *"\(.*\)"/\1/'
}

# --- Extract draft status from front matter ---
extract_draft() {
  grep '^draft' "$1" | sed 's/draft *= *\(.*\)/\1/'
}

# --- List recent Markdown files by modified or created date ---
list_recent_files() {
  local filter="$1"   # "published" | "unpublished" | "all"
  local sort_by="${2:-modified}"  # "created" or "modified"

  local sort_flag
  if [[ "$sort_by" == "created" ]]; then
    sort_flag="--time=ctime"
  else
    sort_flag="--time=mtime"
  fi

  # Find markdown files, filter by draft status
  find "$POSTS_DIR" -name '*.md' -print0 |
    while IFS= read -r -d '' file; do
      local draft=$(extract_draft "$file")
      if [[ "$filter" == "published" && "$draft" == "true" ]]; then continue; fi
      if [[ "$filter" == "unpublished" && "$draft" != "true" ]]; then continue; fi
      echo "$file"
    done |
    xargs -0 ls -t $sort_flag 2>/dev/null |
    head -n "$MAX_RECENT_FILES"
}

# --- Clean display of files for menu ---
display_menu_items() {
  local files=("$@")
  local index=1
  for file in "${files[@]}"; do
    local title=$(extract_title "$file")
    local date=$(extract_date "$file")
    echo "$index) [$date] $title"
    ((index++))
  done
}
