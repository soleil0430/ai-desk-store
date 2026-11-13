#!/bin/bash
# check-pr.sh 시험: 통과 1건 + 거절 8건. 임시 폴더에 가짜 저장소를 만들어 돌린다
set -uo pipefail
here=$(cd "$(dirname "$0")/.." && pwd); t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
mkdir -p "$t/characters/taken" && echo '{"author":"bob"}' > "$t/characters/taken/meta.json"
cd "$t"; bad=0
try() { # 기대(ok/거절 문구 일부) 바뀐파일 목록
  printf '%b' "$2" > c.txt; printf '%b' "$3" > l.txt
  out=$("$here/check-pr.sh" alice c.txt l.txt); code=$?
  if [ "$1" = ok ]; then [ $code = 0 ] || { echo "❌ 통과해야 함: $out"; bad=1; }
  else [ $code = 1 ] && [[ "$out" == *"$1"* ]] || { echo "❌ '$1' 기대, 받음: $out"; bad=1; }; fi
}
L='character.json 100\nidle.webp 2000\n'
try ok          'added characters/pen/character.json\nadded characters/pen/idle.webp\n' "$L"
try "폴더 하나"  'added characters/pen/idle.webp\nadded characters/cat/idle.webp\n' "$L"
try "폴더 하나"  'added README.md\n' "$L"
try "영문"       'added characters/Pen/idle.webp\n' "$L"
try "meta.json" 'added characters/pen/meta.json\n' "$L"
try "다른 사람"  'modified characters/taken/idle.webp\n' "$L"
try "올릴 수 없는" 'added characters/pen/run.sh\n' "character.json 1\nrun.sh 5\n"
try "character.json 이 없"  'added characters/pen/idle.webp\n' "idle.webp 5\n"
try "20MB"      'added characters/pen/idle.webp\n' "character.json 1\nidle.webp 20000001\n"
[ $bad = 0 ] && echo "✅ check-pr.sh 시험 통과" || exit 1
