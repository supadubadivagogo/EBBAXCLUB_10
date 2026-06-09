#!/usr/bin/env bash
# 로컬 빌드 산출물(site 전체)을 한 덩어리로 gpg 암호화 → dist.tar.gz.gpg.
# 빌드는 평소처럼 로컬에서 끝낸 뒤, site repo 루트에서 실행한다.
#
# 사용법 (패스프레이즈는 절대 파일/히스토리에 남기지 말 것):
#   SITE_GPG_PASSPHRASE='고른-암호' bash _encrypt_dist.sh
#
# 그 다음:
#   git add dist.tar.gz.gpg
#   git commit -m "site 생성물 암호화본 갱신" && git push
# 가 끝나면 Actions 가 복호화→배포한다.
set -euo pipefail

: "${SITE_GPG_PASSPHRASE:?SITE_GPG_PASSPHRASE 환경변수로 패스프레이즈를 주세요}"

# 배포할 평문 생성물 목록 (디렉터리 + 루트 파일)
ITEMS=(arena blog community wiki index.html .nojekyll)
for it in "${ITEMS[@]}"; do
  if [ ! -e "$it" ]; then echo "경고: '$it' 가 없습니다 (빌드 먼저 확인)"; fi
done

tar -czf dist.tar.gz "${ITEMS[@]}"
gpg --batch --yes --symmetric --cipher-algo AES256 \
    --passphrase "$SITE_GPG_PASSPHRASE" \
    -o dist.tar.gz.gpg dist.tar.gz
rm -f dist.tar.gz

echo "✅ dist.tar.gz.gpg 생성 완료 ($(du -h dist.tar.gz.gpg | cut -f1))"
echo "   이제: git add dist.tar.gz.gpg && git commit && git push"
