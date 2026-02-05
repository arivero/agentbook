#!/usr/bin/env bash
set -euo pipefail

output="${1:-combined.md}"

chapter_glob="book/chapters/*-*.md"

strip_yaml_front_matter() {
  awk 'NR==1 && $0=="---" {in_yaml=1; next}
       in_yaml && $0=="---" {in_yaml=0; next}
       in_yaml {next}
       {print}' "$1"
}

: > "$output"

printf '%s\n' $chapter_glob | LC_ALL=C sort | while read -r chapter; do
  strip_yaml_front_matter "$chapter" >> "$output"
  printf "\n\n" >> "$output"
done
