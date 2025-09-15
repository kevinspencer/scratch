#!/usr/bin/env bash
set -euo pipefail

# gen-pr-list.sh <PREFIX>
# Finds files in the current directory that start with PREFIX and were modified today,
# then calls the matching parse-list-<prefix>.pl script.

if [ $# -ne 1 ]; then
  echo "Usage: $0 <prefix>"
  exit 1
fi

PREFIX="$1"
TODAY=$(date +%Y-%m-%d)
OUTPUT="${PREFIX}_combined_${TODAY}.csv"

# Lowercase version of prefix (for parse-list script name)
PREFIX_LOWER=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')

# collect matching files into a bash array safely (null-delimited)
files=()
while IFS= read -r -d '' f; do
  # exclude the output file in case its name matches the pattern
  if [ "$f" = "./$OUTPUT" ] || [ "$f" = "$OUTPUT" ]; then
    continue
  fi
  files+=("$f")
done < <(
  find . -maxdepth 1 -type f -name "${PREFIX}*" \
    -newermt "$TODAY 00:00:00" ! -newermt "$TODAY 23:59:59" -print0
)

if [ ${#files[@]} -eq 0 ]; then
  echo "No files found for prefix '$PREFIX' today ($TODAY)."
  exit 0
fi

# create/empty the output file
: > "$OUTPUT"

# concatenate: keep header from the first file, skip first line in the rest
first=1
for f in "${files[@]}"; do
  if [ $first -eq 1 ]; then
    cat "$f" >> "$OUTPUT"
    first=0
  else
    tail -n +2 "$f" >> "$OUTPUT"
  fi
done

echo "Created '$OUTPUT' with ${#files[@]} files:"
for f in "${files[@]}"; do
  printf '  %s\n' "$f"
done

# call the parse script
PARSE_SCRIPT="./parse-list-${PREFIX_LOWER}.pl"

if [ -x "$PARSE_SCRIPT" ]; then
  echo "Running $PARSE_SCRIPT $OUTPUT"
  "$PARSE_SCRIPT" "$OUTPUT"
else
  echo "Warning: $PARSE_SCRIPT not found or not executable."
fi
