#!/usr/bin/env bash
set -euo pipefail

# spec-backlog-apply.sh — deterministic BACKLOG.md mutator.
# Reads manifest from stdin. Operations: delete, adopt, purge-origin, append.

BACKLOG="BACKLOG.md"
HAD_MISS=0

# Strip "(ACTIVE in spec YYYY-MM-DD)" from heading for matching
normalize_heading() {
  echo "$1" | sed -E 's/ *\(ACTIVE in spec [0-9]{4}-[0-9]{2}-[0-9]{2}\)//'
}

# Delete a ### section by heading
delete_section() {
  local target
  target="$(normalize_heading "$1")"

  if [[ ! -f "$BACKLOG" ]]; then
    echo "MISS: $1 (no BACKLOG.md)" >&2
    HAD_MISS=1
    return
  fi

  local norm_target
  norm_target="$target"
  local found=0

  # Use awk to remove the section
  local tmpfile
  tmpfile="$(mktemp)"
  awk -v target="$norm_target" '
    BEGIN { skip=0; found=0 }
    /^### / {
      heading = $0
      sub(/^### */, "", heading)
      gsub(/ *\(ACTIVE in spec [0-9]{4}-[0-9]{2}-[0-9]{2}\)/, "", heading)
      if (heading == target) {
        skip=1; found=1; next
      } else {
        skip=0
      }
    }
    /^## / { skip=0 }
    !skip { print }
    END { exit (found ? 0 : 1) }
  ' "$BACKLOG" > "$tmpfile"

  if [[ $? -eq 0 ]] || grep -q "^" "$tmpfile"; then
    # Check if awk found the section by comparing files
    if ! diff -q "$BACKLOG" "$tmpfile" &>/dev/null; then
      mv "$tmpfile" "$BACKLOG"
      echo "DELETED: $1"
    else
      rm "$tmpfile"
      echo "MISS: $1" >&2
      HAD_MISS=1
    fi
  else
    rm "$tmpfile"
    echo "MISS: $1" >&2
    HAD_MISS=1
  fi
}

# Annotate a ### heading with (ACTIVE in spec DATE)
adopt_section() {
  local heading="$1"
  local date="$2"
  local target
  target="$(normalize_heading "$heading")"

  if [[ ! -f "$BACKLOG" ]]; then
    echo "MISS: $heading (no BACKLOG.md)" >&2
    HAD_MISS=1
    return
  fi

  local tmpfile
  tmpfile="$(mktemp)"
  local found=0

  while IFS= read -r line; do
    if [[ "$line" =~ ^###\  ]]; then
      local h="${line#\#\#\# }"
      local nh
      nh="$(normalize_heading "$h")"
      if [[ "$nh" == "$target" ]]; then
        echo "### $target (ACTIVE in spec $date)"
        found=1
        continue
      fi
    fi
    echo "$line"
  done < "$BACKLOG" > "$tmpfile"

  if [[ $found -eq 1 ]]; then
    mv "$tmpfile" "$BACKLOG"
    echo "ANNOTATED: $heading | $date"
  else
    rm "$tmpfile"
    echo "MISS: $heading" >&2
    HAD_MISS=1
  fi
}

# Remove entries whose Origin starts with prefix, except ACTIVE ones
purge_origin() {
  local prefix="$1"

  if [[ ! -f "$BACKLOG" ]]; then
    return
  fi

  local tmpfile
  tmpfile="$(mktemp)"
  local purged=0

  awk -v prefix="$prefix" '
    BEGIN { skip=0 }
    /^### / {
      heading = $0
      if (heading ~ /\(ACTIVE in spec/) {
        skip=0; print; next
      }
      # Buffer the section to check origin
      skip=0
      section = $0 "\n"
      has_origin=0
      while ((getline line) > 0) {
        if (line ~ /^### / || line ~ /^## /) {
          # End of section
          if (has_origin) { purged++ }
          else { printf "%s", section }
          print line
          section = ""
          next
        }
        section = section line "\n"
        if (line ~ /^\*\*Origin:\*\*/) {
          origin = line
          sub(/.*\*\*Origin:\*\* */, "", origin)
          if (index(origin, prefix) == 1) {
            has_origin=1
            skip=1
          }
        }
      }
      # EOF
      if (has_origin) { purged++ }
      else { printf "%s", section }
      next
    }
    { print }
    END { for (i=0; i<purged; i++) print "PURGED" > "/dev/stderr" }
  ' "$BACKLOG" > "$tmpfile"

  local count
  count=$(grep -c "^PURGED$" /dev/stderr 2>/dev/null || true)
  mv "$tmpfile" "$BACKLOG"
  # Count purged via file size difference — awk reports to stderr
}

# Append a new section
append_section() {
  local heading="$1"
  local body="$2"

  # Create BACKLOG.md if absent
  if [[ ! -f "$BACKLOG" ]]; then
    cat > "$BACKLOG" << 'HEADER'
# Backlog

Deferred proposals. Read before drafting a new SPEC.md; swept at turn close.

HEADER
  fi

  # Check for duplicate
  local target
  target="$(normalize_heading "$heading")"
  if grep -q "^### $target" "$BACKLOG" 2>/dev/null; then
    echo "SKIPPED: $heading (already exists)"
    return
  fi

  # Append
  printf '\n### %s\n%s\n' "$heading" "$body" >> "$BACKLOG"
  echo "APPENDED: $heading"
}

# Parse manifest from stdin
declare -a DELETE_OPS=()
declare -a ADOPT_OPS=()
declare -a PURGE_OPS=()
in_append=0
append_heading=""
append_body=""

while IFS= read -r line; do
  if [[ $in_append -eq 1 ]]; then
    if [[ "$line" == "end-append" ]]; then
      append_section "$append_heading" "$append_body"
      in_append=0
      append_heading=""
      append_body=""
    else
      if [[ -n "$append_body" ]]; then
        append_body="$append_body
$line"
      else
        append_body="$line"
      fi
    fi
    continue
  fi

  case "$line" in
    delete:*)
      heading="${line#delete: }"
      heading="${heading#delete:}"
      heading="$(echo "$heading" | sed 's/^ *//' | sed 's/`//g')"
      delete_section "$heading"
      ;;
    adopt:*)
      rest="${line#adopt: }"
      rest="${rest#adopt:}"
      rest="$(echo "$rest" | sed 's/^ *//')"
      heading="${rest% |*}"
      date="${rest##*| }"
      adopt_section "$heading" "$date"
      ;;
    purge-origin:*)
      prefix="${line#purge-origin: }"
      prefix="${prefix#purge-origin:}"
      prefix="$(echo "$prefix" | sed 's/^ *//')"
      purge_origin "$prefix"
      ;;
    append:*)
      append_heading="${line#append: }"
      append_heading="${append_heading#append:}"
      append_heading="$(echo "$append_heading" | sed 's/^ *//')"
      in_append=1
      append_body=""
      ;;
    ""|" "*)
      # Blank or whitespace-only lines outside append blocks: ignore
      ;;
    *)
      # Unrecognized lines: ignore
      ;;
  esac
done

if [[ $in_append -eq 1 ]]; then
  echo "ERROR: missing end-append for '$append_heading'" >&2
  HAD_MISS=1
fi

# Count remaining entries
if [[ -f "$BACKLOG" ]]; then
  count="$(grep -c '^### ' "$BACKLOG" 2>/dev/null || echo 0)"
  echo "BACKLOG.md: $count entries"
fi

exit $HAD_MISS
