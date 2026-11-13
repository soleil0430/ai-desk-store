#!/bin/bash
# characters/*/ 의 character.json + meta.json 을 합쳐 index.json 을 다시 만든다 (신규순)
set -euo pipefail
cd "$(dirname "$0")/.."
for d in characters/*/; do
  d=${d%/}; id=$(basename "$d")
  [[ "$id" =~ ^[a-z0-9-]+$ ]] && [ -f "$d/character.json" ] && [ -f "$d/meta.json" ] || continue
  files=$(cd "$d" && ls -1 | grep -v '^meta\.json$' | jq -R . | jq -s .)
  size=$(find "$d" -type f ! -name meta.json -exec cat {} + | wc -c | tr -d ' ')
  jq -n --arg id "$id" --argjson files "$files" --argjson size "$size" \
     --slurpfile c "$d/character.json" --slurpfile m "$d/meta.json" \
     '{id:$id, name:$c[0].name, source:$c[0].source, states:$c[0].states, lines:($c[0].lines // {}),
       author:$m[0].author, addedAt:$m[0].addedAt, updatedAt:$m[0].updatedAt, files:$files, size:$size}'
done | jq -s '{characters: (sort_by(.addedAt) | reverse)}' > index.json
echo "index.json: $(jq '.characters | length' index.json)개"
