#!/bin/bash
# 올리기 PR 검사: 캐릭터 폴더 하나만, 자기 것만, 그림 파일만, 20MB 이하.
# 통과하면 캐릭터 id 를 출력하고, 아니면 이유를 출력하고 1 로 끝난다. 저장소 맨 위 폴더에서 실행한다.
# 사용: check-pr.sh <올린 사람> <바뀐 파일 목록: "상태 경로" 줄들> <PR 적용 뒤 폴더 목록: "이름 크기" 줄들>
set -uo pipefail
author=$1; changes=$2; listing=$3
fail() { echo "$1"; exit 1; }

ids=$(awk '{ n = split($2, p, "/"); print (p[1] == "characters" && n == 3) ? p[2] : "!" }' "$changes" | sort -u)
[ -n "$ids" ] && [ "$(printf '%s\n' "$ids" | wc -l | tr -d ' ')" = 1 ] && [ "$ids" != "!" ] \
  || fail "캐릭터 폴더 하나(characters/<id>/ 바로 아래 파일)만 바꿀 수 있습니다"
id=$ids
[[ "$id" =~ ^[a-z0-9-]+$ ]] || fail "폴더 이름은 영문 소문자·숫자·- 만 쓸 수 있습니다: $id"
awk '{print $2}' "$changes" | grep -q '/meta\.json$' && fail "meta.json 은 자동으로 만들어집니다"
if [ -f "characters/$id/meta.json" ]; then
  owner=$(jq -r .author "characters/$id/meta.json")
  [ "$owner" = "$author" ] || fail "다른 사람(@$owner)이 올린 캐릭터입니다"
fi
total=0; has_def=0
while read -r name size; do
  [ -z "$name" ] || [ "$name" = meta.json ] && continue
  case "$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')" in
    character.json) has_def=1 ;;
    *.svg|*.webp|*.png|*.apng|*.gif) ;;
    *) fail "올릴 수 없는 파일: $name" ;;
  esac
  total=$((total + size))
done < "$listing"
[ $has_def = 1 ] || fail "character.json 이 없습니다"
[ $total -le 20000000 ] || fail "캐릭터가 20MB 를 넘습니다 ($total 바이트)"
echo "$id"
