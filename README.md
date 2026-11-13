# AI Desk 캐릭터 스토어

[AI Desk](https://github.com/soleil0430/ai-desk-releases) 앱의 **설정 → 캐릭터 → 스토어 가기**에서 보이는 캐릭터들입니다.

- `characters/<id>/`: 캐릭터 하나 (`character.json` + 상태별 그림 + `meta.json`)
- `index.json`: 앱이 읽는 목록. `scripts/build-index.sh`로 다시 만듭니다
- `meta.json`과 `index.json`은 손으로 고치지 않습니다

## 올리기

앱의 스토어 창 → **올리기**로 올립니다. 앱이 PR 을 열면 `.github/workflows/upload.yml` 이 검사해 바로 머지하고 목록을 갱신합니다 (사람 승인 없음).

- 캐릭터 폴더 하나(`characters/<id>/`)만 바꿀 수 있습니다
- 이미 있는 폴더는 처음 올린 사람만 고칠 수 있습니다
- `character.json` 과 그림 파일(svg, webp, png, apng, gif)만, 20MB 이하
- 검사 규칙: `scripts/check-pr.sh` (시험: `scripts/test/test-check-pr.sh`)
